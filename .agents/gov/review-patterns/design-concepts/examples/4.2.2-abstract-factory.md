# Abstract Factory

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.2
- **Aliases:** None
- **Definition:** Provide an interface for creating a related family of objects without naming concrete classes. It keeps family substitutions coherent, but can add indirection.
- **Why it matters:** Abstract Factory makes it clear which objects belong together and gives callers one stable creation interface. This improves maintainability when an entire product family must be swapped, such as web widgets for mobile widgets, because the calling code does not need to know every concrete class.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A checkout screen must render the same payment controls for either a web UI or a mobile UI. Each platform needs a coherent family of widgets so the button, text field, and dialog all come from the same platform style.

### 2.2 Good form

```ts
interface Button {
  render(label: string): string;
}

interface TextField {
  render(placeholder: string): string;
}

interface Dialog {
  render(message: string): string;
}

interface CheckoutWidgetFactory {
  createButton(): Button;
  createTextField(): TextField;
  createDialog(): Dialog;
}

class WebButton implements Button {
  render(label: string): string {
    return `<button class="web-button">${label}</button>`;
  }
}

class WebTextField implements TextField {
  render(placeholder: string): string {
    return `<input class="web-input" placeholder="${placeholder}" />`;
  }
}

class WebDialog implements Dialog {
  render(message: string): string {
    return `<section class="web-dialog">${message}</section>`;
  }
}

class MobileButton implements Button {
  render(label: string): string {
    return `<button class="mobile-button">${label}</button>`;
  }
}

class MobileTextField implements TextField {
  render(placeholder: string): string {
    return `<input class="mobile-input" placeholder="${placeholder}" />`;
  }
}

class MobileDialog implements Dialog {
  render(message: string): string {
    return `<section class="mobile-dialog">${message}</section>`;
  }
}

class WebCheckoutWidgetFactory implements CheckoutWidgetFactory {
  createButton(): Button {
    return new WebButton();
  }

  createTextField(): TextField {
    return new WebTextField();
  }

  createDialog(): Dialog {
    return new WebDialog();
  }
}

class MobileCheckoutWidgetFactory implements CheckoutWidgetFactory {
  createButton(): Button {
    return new MobileButton();
  }

  createTextField(): TextField {
    return new MobileTextField();
  }

  createDialog(): Dialog {
    return new MobileDialog();
  }
}

function renderCheckout(factory: CheckoutWidgetFactory): string {
  const couponField = factory.createTextField();
  const payButton = factory.createButton();
  const confirmationDialog = factory.createDialog();

  return [
    couponField.render("Coupon code"),
    payButton.render("Pay now"),
    confirmationDialog.render("Confirm payment")
  ].join("\n");
}

const webCheckout = renderCheckout(new WebCheckoutWidgetFactory());
const mobileCheckout = renderCheckout(new MobileCheckoutWidgetFactory());

console.log(webCheckout);
console.log(mobileCheckout);
```

### 2.3 Less maintainable form

```ts
type Platform = "web" | "mobile";

interface Button {
  render(label: string): string;
}

interface TextField {
  render(placeholder: string): string;
}

interface Dialog {
  render(message: string): string;
}

class WebButton implements Button {
  render(label: string): string {
    return `<button class="web-button">${label}</button>`;
  }
}

class WebTextField implements TextField {
  render(placeholder: string): string {
    return `<input class="web-input" placeholder="${placeholder}" />`;
  }
}

class WebDialog implements Dialog {
  render(message: string): string {
    return `<section class="web-dialog">${message}</section>`;
  }
}

class MobileButton implements Button {
  render(label: string): string {
    return `<button class="mobile-button">${label}</button>`;
  }
}

class MobileTextField implements TextField {
  render(placeholder: string): string {
    return `<input class="mobile-input" placeholder="${placeholder}" />`;
  }
}

class MobileDialog implements Dialog {
  render(message: string): string {
    return `<section class="mobile-dialog">${message}</section>`;
  }
}

function renderCheckout(platform: Platform): string {
  let couponField: TextField;
  let payButton: Button;
  let confirmationDialog: Dialog;

  if (platform === "web") {
    couponField = new WebTextField();
    payButton = new WebButton();
    confirmationDialog = new WebDialog();
  } else {
    couponField = new MobileTextField();
    payButton = new MobileButton();
    confirmationDialog = new MobileDialog();
  }

  return [
    couponField.render("Coupon code"),
    payButton.render("Pay now"),
    confirmationDialog.render("Confirm payment")
  ].join("\n");
}

const webCheckout = renderCheckout("web");
const mobileCheckout = renderCheckout("mobile");

console.log(webCheckout);
console.log(mobileCheckout);
```

### 2.4 Why this difference matters

In the good form, `renderCheckout` depends on one abstract creation interface, `CheckoutWidgetFactory`, rather than on every concrete widget class. The factory guarantees that the button, text field, and dialog are chosen as one coherent family. To switch from web to mobile, the caller substitutes the factory once.

In the less maintainable form, `renderCheckout` owns the family-selection logic and names all concrete widget classes. Each new platform adds more branching to the rendering function, and each new widget type requires editing every platform branch. The intended behavior is the same, but the creation policy is mixed into the client logic.

### 2.5 Structural references

```text
Good: renderCheckout > widgetFactory.createButton, createInput, createDialog
Less maintainable: renderCheckout > platform === "web" constructor expressions
```

The relevant structural difference is that the good form places family creation behind a factory target used by `renderCheckout`, while the less maintainable form places concrete product selection directly inside `renderCheckout`.

## 3. Boundaries and distinctions

Abstract Factory is useful when code must create multiple related objects that should vary together as a family. It is less useful when there is only one product type, when concrete classes are stable and unlikely to vary, or when direct construction is clearer than adding a factory layer.

The less maintainable form can be appropriate for a small script, a prototype, or a boundary where there are only one or two concrete choices and no expectation of adding more families. In those cases, the extra interface and factory classes may be unnecessary indirection.

Abstract Factory differs from Factory Method because Factory Method usually creates one product through an overridable method, while Abstract Factory creates a family of related products through one interface. It also differs from Builder, which focuses on assembling one complex object step by step rather than selecting a coherent family of objects.
