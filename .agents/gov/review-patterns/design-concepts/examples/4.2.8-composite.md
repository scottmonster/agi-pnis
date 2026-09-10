# Composite

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.8
- **Aliases:** None
- **Definition:** Treat individual and composed objects through a common interface. It simplifies client traversal of tree-like structures when the common operations are real.
- **Why it matters:** Composite keeps client code focused on the operation it wants to perform instead of on whether each object is a leaf or a container, which makes tree traversal easier to read, understand, and extend.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A document export tool needs to count words in both individual text blocks and sections that contain nested blocks or subsections.

### 2.2 Good form

```ts
interface DocumentPart {
  wordCount(): number;
}

class TextBlock implements DocumentPart {
  constructor(private readonly text: string) {}

  wordCount(): number {
    return this.text.trim() === "" ? 0 : this.text.trim().split(/\s+/).length;
  }
}

class Section implements DocumentPart {
  private readonly children: DocumentPart[] = [];

  constructor(private readonly title: string) {}

  add(part: DocumentPart): void {
    this.children.push(part);
  }

  wordCount(): number {
    const titleWords = this.title.trim() === "" ? 0 : this.title.trim().split(/\s+/).length;
    return titleWords + this.children.reduce((total, child) => total + child.wordCount(), 0);
  }
}

function countDocumentWords(part: DocumentPart): number {
  return part.wordCount();
}

const introduction = new Section("Getting Started");
introduction.add(new TextBlock("Install the package."));
introduction.add(new TextBlock("Run the setup command."));

const guide = new Section("User Guide");
guide.add(introduction);
guide.add(new TextBlock("Review the generated report."));

console.log(countDocumentWords(guide));
```

### 2.3 Less maintainable form

```ts
type TextBlockData = {
  kind: "text";
  text: string;
};

type SectionData = {
  kind: "section";
  title: string;
  children: DocumentPartData[];
};

type DocumentPartData = TextBlockData | SectionData;

function countWordsInText(text: string): number {
  return text.trim() === "" ? 0 : text.trim().split(/\s+/).length;
}

function countDocumentWords(part: DocumentPartData): number {
  if (part.kind === "text") {
    return countWordsInText(part.text);
  }

  const titleWords = countWordsInText(part.title);
  const childWords = part.children.reduce((total, child) => total + countDocumentWords(child), 0);
  return titleWords + childWords;
}

const guide: DocumentPartData = {
  kind: "section",
  title: "User Guide",
  children: [
    {
      kind: "section",
      title: "Getting Started",
      children: [
        { kind: "text", text: "Install the package." },
        { kind: "text", text: "Run the setup command." }
      ]
    },
    { kind: "text", text: "Review the generated report." }
  ]
};

console.log(countDocumentWords(guide));
```

### 2.4 Why this difference matters

In the good form, both `TextBlock` and `Section` implement `DocumentPart`, so the client can call `wordCount()` without checking whether the current item is an individual block or a composed section. The recursive behavior belongs to the composite object itself: `Section` knows how to aggregate its children, while `TextBlock` knows how to count its own words.

In the less maintainable form, traversal logic and type discrimination are pushed into the client function. Every operation over the document tree must repeat the same `kind` checks and recursion shape. Adding another document part, such as a table or generated summary, requires revisiting each traversal function instead of adding another implementation of the shared interface.

### 2.5 Structural references

```text
Good: countDocumentWords > DocumentPart.wordCount
Less maintainable: countDocumentWords > part.kind === "text" dispatch
```

The good form targets a common document-part interface, so traversal code depends on the shared operation. The less maintainable form targets a discriminated data shape, so traversal code must inspect each node type before deciding how to continue.

## 3. Boundaries and distinctions

Composite fits when clients need to apply the same real operation to both individual objects and object groups, especially when the structure is tree-like and recursive. It does not help when leaves and containers do not share meaningful behavior, or when forcing a common interface would create fake methods that some objects cannot honestly implement.

The less maintainable form can be appropriate for small, fixed data structures, serialization boundaries, or cases where a simple discriminated union is clearer than introducing object behavior. If the tree has only one or two operations and the set of variants is stable, explicit type checks may be acceptable.

Composite differs from a general recursive function because the recursive behavior is distributed across objects through a common interface. It also differs from merely storing children in an array: the key idea is not containment alone, but treating leaves and composites uniformly through the same operation.
