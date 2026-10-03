# Command

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.14
- **Aliases:** None
- **Definition:** Represent a request as an object containing the operation and its context. It makes queuing, logging, undo, and parameterization explicit, at an object-cost trade-off.
- **Why it matters:** Command makes an action readable as a named, inspectable object instead of a scattered call plus separate parameters. This improves maintainability when requests must be queued, logged, retried, undone, or passed through different parts of a system.
- **Related concepts:** Replace Function with Command

## 2. Example

### 2.1 Scenario

A text editor applies user edits and supports undo. The same edit behavior should work whether the edit is executed immediately, logged, queued, or undone later.

### 2.2 Good form

```ts
interface Command {
  readonly label: string;
  execute(): void;
  undo(): void;
}

class TextDocument {
  private content = "";

  insert(index: number, text: string): void {
    this.content =
      this.content.slice(0, index) + text + this.content.slice(index);
  }

  delete(index: number, length: number): string {
    const removed = this.content.slice(index, index + length);
    this.content =
      this.content.slice(0, index) + this.content.slice(index + length);
    return removed;
  }

  text(): string {
    return this.content;
  }
}

class InsertTextCommand implements Command {
  readonly label: string;

  constructor(
    private readonly document: TextDocument,
    private readonly index: number,
    private readonly text: string
  ) {
    this.label = `Insert "${text}" at ${index}`;
  }

  execute(): void {
    this.document.insert(this.index, this.text);
  }

  undo(): void {
    this.document.delete(this.index, this.text.length);
  }
}

class CommandHistory {
  private readonly done: Command[] = [];

  run(command: Command): void {
    console.log(`Running: ${command.label}`);
    command.execute();
    this.done.push(command);
  }

  undoLast(): void {
    const command = this.done.pop();

    if (command) {
      console.log(`Undoing: ${command.label}`);
      command.undo();
    }
  }
}

const document = new TextDocument();
const history = new CommandHistory();

history.run(new InsertTextCommand(document, 0, "Hello"));
history.run(new InsertTextCommand(document, 5, ", world"));
history.undoLast();

console.log(document.text()); // "Hello"
```

### 2.3 Less maintainable form

```ts
type UndoEntry = {
  kind: "insert";
  index: number;
  text: string;
};

class TextDocument {
  private content = "";

  insert(index: number, text: string): void {
    this.content =
      this.content.slice(0, index) + text + this.content.slice(index);
  }

  delete(index: number, length: number): string {
    const removed = this.content.slice(index, index + length);
    this.content =
      this.content.slice(0, index) + this.content.slice(index + length);
    return removed;
  }

  text(): string {
    return this.content;
  }
}

function insertText(
  document: TextDocument,
  undoLog: UndoEntry[],
  index: number,
  text: string
): void {
  console.log(`Running: Insert "${text}" at ${index}`);
  document.insert(index, text);
  undoLog.push({ kind: "insert", index, text });
}

function undoLast(document: TextDocument, undoLog: UndoEntry[]): void {
  const entry = undoLog.pop();

  if (!entry) {
    return;
  }

  if (entry.kind === "insert") {
    console.log(`Undoing: Insert "${entry.text}" at ${entry.index}`);
    document.delete(entry.index, entry.text.length);
  }
}

const document = new TextDocument();
const undoLog: UndoEntry[] = [];

insertText(document, undoLog, 0, "Hello");
insertText(document, undoLog, 5, ", world");
undoLast(document, undoLog);

console.log(document.text()); // "Hello"
```

### 2.4 Why this difference matters

In the good form, the request is a first-class object: `InsertTextCommand` contains the receiver, parameters, execution behavior, undo behavior, and label. The history only knows that it can run and undo a `Command`, so adding `DeleteTextCommand`, `ReplaceTextCommand`, queuing, logging, or replay does not require rewriting the history logic.

In the less maintainable form, the action is split across a function call, an undo log entry, and conditional undo logic. Each new edit type requires changes in multiple places, especially the central `undoLast` branch. The behavior is still correct, but the request is not represented as a single object that can be passed around uniformly.

### 2.5 Structural references

```text
Good: editor-app > editor > commandHistory.ts > run > Command.execute and Command.undo
Less maintainable: editor-app > editor > editorActions.ts > undoLast > entry.kind === "insert" branch
```

The relevant structural difference is that the good form depends on a command target with a uniform `execute` and `undo` interface. The less maintainable form depends on a central function that interprets action data with a conditional branch.

## 3. Boundaries and distinctions

Command is most useful when requests need a lifecycle: queueing, delayed execution, audit logging, retries, undo, redo, macros, or parameterized UI actions. It is less useful for a simple direct call that is always executed immediately and never needs to be stored, inspected, undone, or routed.

The less maintainable form can be appropriate for very small code paths with one or two operations, especially when introducing command objects would add more ceremony than clarity. The trade-off is that growth usually creates duplicated metadata, switch statements, and separate undo or retry handling.

Command differs from Replace Function with Command. Command is a design pattern for representing requests as objects, often to decouple senders from receivers and support request management. Replace Function with Command is a refactoring that turns one function into an object when the function needs state, configuration, extension points, or clearer organization. A refactoring can lead to a Command, but not every command object comes from that refactoring, and not every replaced function is a Command pattern use.
