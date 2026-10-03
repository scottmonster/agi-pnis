# Flyweight

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.11
- **Aliases:** None
- **Definition:** Share immutable common state across many fine-grained objects. It can reduce duplication but separates intrinsic from contextual state, which may increase cognitive cost.
- **Why it matters:** Flyweight can make code easier to maintain when many objects repeat the same immutable data, because updates to shared data happen in one place. It also makes the boundary between shared intrinsic state and per-instance contextual state explicit, which improves readability when that boundary is stable and well named.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A map renderer draws thousands of trees. Each tree has unique coordinates, but many trees share the same species name, color, and sprite.

### 2.2 Good form

```ts
type TreeSpeciesKey = string;

class TreeType {
  constructor(
    readonly species: string,
    readonly color: string,
    readonly spritePath: string,
  ) {}

  render(x: number, y: number): string {
    return `Draw ${this.color} ${this.species} at (${x}, ${y}) using ${this.spritePath}`;
  }
}

class TreeTypeFactory {
  private readonly cache = new Map<TreeSpeciesKey, TreeType>();

  getTreeType(species: string, color: string, spritePath: string): TreeType {
    const key = `${species}|${color}|${spritePath}`;
    const existing = this.cache.get(key);

    if (existing) {
      return existing;
    }

    const created = new TreeType(species, color, spritePath);
    this.cache.set(key, created);
    return created;
  }

  countSharedTypes(): number {
    return this.cache.size;
  }
}

class Tree {
  constructor(
    private readonly x: number,
    private readonly y: number,
    private readonly type: TreeType,
  ) {}

  render(): string {
    return this.type.render(this.x, this.y);
  }
}

class Forest {
  private readonly trees: Tree[] = [];
  private readonly treeTypes = new TreeTypeFactory();

  plantTree(
    x: number,
    y: number,
    species: string,
    color: string,
    spritePath: string,
  ): void {
    const type = this.treeTypes.getTreeType(species, color, spritePath);
    this.trees.push(new Tree(x, y, type));
  }

  render(): string[] {
    return this.trees.map((tree) => tree.render());
  }

  countSharedTypes(): number {
    return this.treeTypes.countSharedTypes();
  }
}

function renderForest(): string[] {
  const forest = new Forest();

  forest.plantTree(10, 20, "Oak", "green", "/sprites/oak.png");
  forest.plantTree(15, 25, "Oak", "green", "/sprites/oak.png");
  forest.plantTree(40, 50, "Pine", "dark-green", "/sprites/pine.png");

  return forest.render();
}

const renderedTrees = renderForest();
console.log(renderedTrees);
```

### 2.3 Less maintainable form

```ts
class Tree {
  constructor(
    private readonly x: number,
    private readonly y: number,
    private readonly species: string,
    private readonly color: string,
    private readonly spritePath: string,
  ) {}

  render(): string {
    return `Draw ${this.color} ${this.species} at (${this.x}, ${this.y}) using ${this.spritePath}`;
  }
}

class Forest {
  private readonly trees: Tree[] = [];

  plantTree(
    x: number,
    y: number,
    species: string,
    color: string,
    spritePath: string,
  ): void {
    this.trees.push(new Tree(x, y, species, color, spritePath));
  }

  render(): string[] {
    return this.trees.map((tree) => tree.render());
  }
}

function renderForest(): string[] {
  const forest = new Forest();

  forest.plantTree(10, 20, "Oak", "green", "/sprites/oak.png");
  forest.plantTree(15, 25, "Oak", "green", "/sprites/oak.png");
  forest.plantTree(40, 50, "Pine", "dark-green", "/sprites/pine.png");

  return forest.render();
}

const renderedTrees = renderForest();
console.log(renderedTrees);
```

### 2.4 Why this difference matters

The good form separates intrinsic state from contextual state. `TreeType` holds immutable shared data such as species, color, and sprite path, while `Tree` holds only per-tree coordinates and a reference to the shared type. This makes repeated tree data explicit and centralized, so changing the sprite for a species or checking how many species variants are loaded does not require reasoning about every individual tree.

The less maintainable form preserves the same behavior, but every `Tree` carries its own copy of the species data. When thousands of trees repeat the same values, the duplicated state obscures which data is actually unique to a tree and which data is common across many trees.

### 2.5 Structural references

```text
Good: forest-renderer > rendering > forest.ts > renderForest > TreeTypeFactory
Less maintainable: forest-renderer > rendering > forest.ts > renderForest > Tree
```

The structural difference is that the good form introduces a shared flyweight lookup target, `TreeTypeFactory`, between tree creation and tree rendering. The less maintainable form sends all intrinsic and contextual state directly into each `Tree`, so no structure represents the shared immutable tree type.

## 3. Boundaries and distinctions

Flyweight applies when many fine-grained objects repeat the same immutable state and that shared state can be cleanly separated from per-instance context. It is less useful when there are only a few objects, when the repeated data is small and unlikely to change, or when the supposed shared state must vary independently per object.

The less maintainable form can be appropriate for simple code, tests, prototypes, or small collections where introducing a factory and a shared type would add more cognitive cost than it removes. Flyweight should not be used just to avoid normal object allocation if duplication is not a real readability, memory, or maintenance concern.

Flyweight differs from ordinary caching because its main design concern is modeling shared intrinsic state for many object instances, not merely speeding up expensive computation. It also differs from object pooling: pooling reuses whole object instances over time, while Flyweight shares immutable internal data across many active objects at the same time.
