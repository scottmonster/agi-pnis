# Memento

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.17
- **Aliases:** None
- **Definition:** Capture and restore an object's state without exposing its internals. It localizes undo/history mechanics and preserves encapsulation.
- **Why it matters:** It keeps state restoration logic close to the object that owns the state, so readers do not need to understand or duplicate internal representation details across undo/history code.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A note editor supports typing text, moving the cursor, and undoing to a previous state. The undo history should restore editor state without depending on how the editor stores that state internally.

### 2.2 Good form

```ts
type EditorMemento = {
  readonly savedAt: Date;
};

class NoteEditor {
  private text = "";
  private cursor = 0;

  type(value: string): void {
    this.text =
      this.text.slice(0, this.cursor) +
      value +
      this.text.slice(this.cursor);
    this.cursor += value.length;
  }

  moveCursor(position: number): void {
    this.cursor = Math.max(0, Math.min(position, this.text.length));
  }

  read(): string {
    return `${this.text}\n${" ".repeat(this.cursor)}^`;
  }

  createMemento(): EditorMemento {
    const text = this.text;
    const cursor = this.cursor;

    return {
      savedAt: new Date(),
      restore: undefined as never,
      getState: undefined as never,
      __restoreTo: (editor: NoteEditor) => {
        editor.text = text;
        editor.cursor = cursor;
      },
    } as EditorMemento & {
      __restoreTo(editor: NoteEditor): void;
    };
  }

  restore(memento: EditorMemento): void {
    const restorable = memento as EditorMemento & {
      __restoreTo(editor: NoteEditor): void;
    };

    restorable.__restoreTo(this);
  }
}

class EditorHistory {
  private readonly snapshots: EditorMemento[] = [];

  save(editor: NoteEditor): void {
    this.snapshots.push(editor.createMemento());
  }

  undo(editor: NoteEditor): void {
    const snapshot = this.snapshots.pop();

    if (snapshot) {
      editor.restore(snapshot);
    }
  }
}

const editor = new NoteEditor();
const history = new EditorHistory();

editor.type("Hello");
history.save(editor);

editor.type(", world");
editor.moveCursor(5);
history.save(editor);

editor.type("!");
history.undo(editor);

console.log(editor.read());
```

### 2.3 Less maintainable form

```ts
type EditorState = {
  text: string;
  cursor: number;
};

class NoteEditor {
  public text = "";
  public cursor = 0;

  type(value: string): void {
    this.text =
      this.text.slice(0, this.cursor) +
      value +
      this.text.slice(this.cursor);
    this.cursor += value.length;
  }

  moveCursor(position: number): void {
    this.cursor = Math.max(0, Math.min(position, this.text.length));
  }

  read(): string {
    return `${this.text}\n${" ".repeat(this.cursor)}^`;
  }
}

class EditorHistory {
  private readonly snapshots: EditorState[] = [];

  save(editor: NoteEditor): void {
    this.snapshots.push({
      text: editor.text,
      cursor: editor.cursor,
    });
  }

  undo(editor: NoteEditor): void {
    const snapshot = this.snapshots.pop();

    if (snapshot) {
      editor.text = snapshot.text;
      editor.cursor = snapshot.cursor;
    }
  }
}

const editor = new NoteEditor();
const history = new EditorHistory();

editor.type("Hello");
history.save(editor);

editor.type(", world");
editor.moveCursor(5);
history.save(editor);

editor.type("!");
history.undo(editor);

console.log(editor.read());
```

### 2.4 Why this difference matters

In the good form, `NoteEditor` is the only code that knows which fields make up a restorable editor state and how to apply them. `EditorHistory` only stores and returns mementos, so adding fields such as selection range, formatting mode, or scroll position changes the editor's snapshot logic without changing the history mechanism.

In the less maintainable form, `EditorHistory` must know that `text` and `cursor` are the complete state. That exposes internals and spreads restoration rules outside the owning object, making future state changes easy to miss during undo.

### 2.5 Structural references

```text
Good: editor-app > documents > documentHistory.ts > History.save > TextDocument.createMemento
Less maintainable: editor-app > documents > documentHistory.ts > History.undo > public text snapshot restore
```

The good form places snapshot creation and restoration behind functions owned by the stateful object. The less maintainable form places direct field copying and field restoration inside the history functions.

## 3. Boundaries and distinctions

Memento is useful when an object has state that must be restored later, especially for undo, redo, checkpoints, drafts, or rollback. It is less useful when state is already immutable, trivially serializable, or safely exposed as a public value object.

The less maintainable form can be appropriate for small data structures whose fields are intentionally public and stable, such as plain request DTOs or simple configuration records. It becomes risky when the object has invariants, derived fields, validation rules, or private representation choices.

Memento is not just generic serialization. Serialization is usually concerned with storage or transport format, while Memento is concerned with capturing and restoring state while preserving encapsulation. It is also distinct from Command-based undo: Command records operations and can reverse them, while Memento records object state and restores a previous snapshot.
