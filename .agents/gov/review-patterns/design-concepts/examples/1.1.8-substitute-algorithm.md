# Substitute Algorithm

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 1.1.8
- **Aliases:** None
- **Definition:** Replace one algorithm body with another that has the same observable result. A clearer algorithm can make the logic understandable without changing its contract.
- **Why it matters:** A simpler algorithm reduces the amount of control flow a reader must simulate, making the code easier to verify, maintain, and safely modify while preserving existing behavior.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A helpdesk application stores support contact extensions as digits only, even when users type spaces, dashes, parentheses, or other formatting. The behavior must stay the same: keep ASCII digits and discard everything else.

### 2.2 Good form

```ts
type ContactForm = {
  name: string;
  extension: string;
};

type SupportContact = {
  displayName: string;
  extensionDigits: string;
};

function normalizeExtension(input: string): string {
  return input.replace(/\D/g, "");
}

export function toSupportContact(form: ContactForm): SupportContact {
  return {
    displayName: form.name.trim(),
    extensionDigits: normalizeExtension(form.extension),
  };
}

const contact = toSupportContact({
  name: "  Asha Patel  ",
  extension: "(555) 012-3400 ext. 9",
});

console.log(contact);
// { displayName: "Asha Patel", extensionDigits: "55501234009" }
```

### 2.3 Less maintainable form

```ts
type ContactForm = {
  name: string;
  extension: string;
};

type SupportContact = {
  displayName: string;
  extensionDigits: string;
};

function normalizeExtension(input: string): string {
  let digits = "";

  for (let index = 0; index < input.length; index += 1) {
    const charCode = input.charCodeAt(index);

    if (charCode >= 48 && charCode <= 57) {
      digits += input[index];
    }
  }

  return digits;
}

export function toSupportContact(form: ContactForm): SupportContact {
  return {
    displayName: form.name.trim(),
    extensionDigits: normalizeExtension(form.extension),
  };
}

const contact = toSupportContact({
  name: "  Asha Patel  ",
  extension: "(555) 012-3400 ext. 9",
});

console.log(contact);
// { displayName: "Asha Patel", extensionDigits: "55501234009" }
```

### 2.4 Why this difference matters

The good form substitutes the manual character scanning algorithm with a regular expression algorithm that expresses the same rule directly: remove every non-digit character. The observable result is unchanged, but the intent is easier to see because the reader no longer has to interpret character codes, loop boundaries, mutation, and conditional accumulation.

### 2.5 Structural references

```text
Good: helpdesk-app > support-contacts > contactMapper.ts > normalizeExtension > digit-extraction algorithm
Less maintainable: helpdesk-app > support-contacts > contactMapper.ts > normalizeExtension > manual character-scan algorithm
```

The relevant structural difference is inside the same function body: the good form uses a clearer replacement algorithm, while the less maintainable form keeps an equivalent but lower-level algorithm.

## 3. Boundaries and distinctions

Substitute Algorithm applies only when the replacement preserves the same observable contract, including edge cases such as empty strings, already normalized input, and mixed formatting. It does not apply when the change intentionally alters behavior, such as accepting non-ASCII digits, preserving separators, or validating extension length.

The less maintainable form may be appropriate if the loop encodes a deliberately specialized rule that a regular expression would obscure, or if measurement shows a specific implementation is required for a critical performance path.

This refactoring differs from merely renaming variables or extracting a helper because the algorithm itself is replaced. It also differs from changing requirements because callers should not observe a different result after the substitution.
