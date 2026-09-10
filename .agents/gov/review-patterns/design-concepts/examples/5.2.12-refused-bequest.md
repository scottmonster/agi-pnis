# Refused Bequest

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.2.12
- **Aliases:** None
- **Definition:** A subclass inherits behavior or data it does not need or cannot honor. The hierarchy advertises a false substitutability relationship.
- **Why it matters:** It makes the type hierarchy harder to read because the inheritance relationship promises capabilities that the subclass rejects. Maintainers must remember exceptions to the superclass contract, add defensive checks, and risk breaking subclasses when shared behavior changes.
- **Related concepts:** Replace Superclass with Delegate

## 2. Example

### 2.1 Scenario

A dashboard renders normal resizable panels and fixed-aspect image thumbnails. Panels can change width and height independently, but thumbnails must keep their aspect ratio.

### 2.2 Good form

```ts
class Box {
  constructor(private width: number, private height: number) {}

  setSize(width: number, height: number): void {
    this.width = width;
    this.height = height;
  }

  getSize(): { width: number; height: number } {
    return { width: this.width, height: this.height };
  }
}

class ReportPanel {
  private readonly box: Box;

  constructor(width: number, height: number) {
    this.box = new Box(width, height);
  }

  resizeTo(width: number, height: number): void {
    this.box.setSize(width, height);
  }

  render(): string {
    const size = this.box.getSize();
    return `panel:${size.width}x${size.height}`;
  }
}

class FixedAspectThumbnail {
  private readonly box: Box;

  constructor(
    private readonly imageUrl: string,
    width: number,
    private readonly aspectRatio: number,
  ) {
    this.box = new Box(width, width / aspectRatio);
  }

  scaleToWidth(width: number): void {
    this.box.setSize(width, width / this.aspectRatio);
  }

  render(): string {
    const size = this.box.getSize();
    return `thumbnail:${this.imageUrl}:${size.width}x${size.height}`;
  }
}

function renderDashboard(): string[] {
  const panel = new ReportPanel(640, 480);
  panel.resizeTo(800, 500);

  const thumbnail = new FixedAspectThumbnail("chart.png", 160, 16 / 9);
  thumbnail.scaleToWidth(320);

  return [panel.render(), thumbnail.render()];
}
```

### 2.3 Less maintainable form

```ts
class ResizableBox {
  constructor(protected width: number, protected height: number) {}

  setWidth(width: number): void {
    this.width = width;
  }

  setHeight(height: number): void {
    this.height = height;
  }

  getSize(): { width: number; height: number } {
    return { width: this.width, height: this.height };
  }
}

class ReportPanel extends ResizableBox {
  render(): string {
    const size = this.getSize();
    return `panel:${size.width}x${size.height}`;
  }
}

class FixedAspectThumbnail extends ResizableBox {
  constructor(
    private readonly imageUrl: string,
    width: number,
    private readonly aspectRatio: number,
  ) {
    super(width, width / aspectRatio);
  }

  override setWidth(width: number): void {
    super.setWidth(width);
    super.setHeight(width / this.aspectRatio);
  }

  override setHeight(_height: number): void {
    throw new Error("FixedAspectThumbnail cannot change height independently.");
  }

  scaleToWidth(width: number): void {
    this.setWidth(width);
  }

  render(): string {
    const size = this.getSize();
    return `thumbnail:${this.imageUrl}:${size.width}x${size.height}`;
  }
}

function renderDashboard(): string[] {
  const panel = new ReportPanel(640, 480);
  panel.setWidth(800);
  panel.setHeight(500);

  const thumbnail = new FixedAspectThumbnail("chart.png", 160, 16 / 9);
  thumbnail.scaleToWidth(320);

  return [panel.render(), thumbnail.render()];
}
```

### 2.4 Why this difference matters

In the good form, `FixedAspectThumbnail` reuses sizing storage through a contained `Box`, but it exposes only the operations it can truthfully support. The public API says that thumbnails scale by width and keep their aspect ratio.

In the less maintainable form, `FixedAspectThumbnail` inherits the `ResizableBox` contract, including `setHeight`, but cannot honor it. Any code that receives a `ResizableBox` expects independent width and height resizing, so the subclass creates a false substitutability relationship. Future changes to `ResizableBox` also risk leaking more unsupported behavior into thumbnails.

### 2.5 Structural references

```text
Good: Thumbnail > SizePolicy.dimensions
Less maintainable: Thumbnail extends ImageAsset > inherited resize method
```

The relevant structural difference is that the good version uses delegation to share box sizing without inheriting the resizable API. The less maintainable version places the thumbnail under the resizable superclass, so the thumbnail must reject part of the inherited interface.

## 3. Boundaries and distinctions

Refused Bequest does not apply merely because a subclass uses only some inherited implementation details internally. It applies when the inherited public or protected contract suggests that the subclass supports behavior or state that it does not need or cannot honor.

The less maintainable form may be temporarily acceptable when constrained by a legacy framework or external API that requires subclassing, but the unsupported inherited behavior should be isolated and documented.

This differs from ordinary specialization, where a subclass narrows implementation choices while still honoring the superclass contract. It is also distinct from Replace Superclass with Delegate: Refused Bequest is the smell, while Replace Superclass with Delegate is a common refactoring that removes the false inheritance relationship.
