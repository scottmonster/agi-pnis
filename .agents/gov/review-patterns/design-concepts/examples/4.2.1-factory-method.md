# Factory Method

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.1
- **Aliases:** None
- **Definition:** Let a base operation defer creation of a product to subclasses or supplied creators. It localizes construction variation.
- **Why it matters:** Factory Method keeps the main workflow readable by separating stable behavior from variable construction details, so adding a new product usually changes one creator instead of editing the base operation.
- **Related concepts:** Abstract Factory, Replace Constructor with Factory Function

## 2. Example

### 2.1 Scenario

An alert workflow sends a message through a delivery channel. Different deployments use different channels, but the workflow for building and sending an alert stays the same.

### 2.2 Good form

```ts
type SentMessage = {
  channel: string;
  recipient: string;
  body: string;
};

interface DeliveryChannel {
  send(recipient: string, body: string): SentMessage;
}

class EmailChannel implements DeliveryChannel {
  send(recipient: string, body: string): SentMessage {
    return {
      channel: "email",
      recipient,
      body
    };
  }
}

class SmsChannel implements DeliveryChannel {
  send(recipient: string, body: string): SentMessage {
    return {
      channel: "sms",
      recipient,
      body
    };
  }
}

abstract class AlertWorkflow {
  notify(recipient: string, body: string): SentMessage {
    const channel = this.createChannel();
    return channel.send(recipient, body);
  }

  protected abstract createChannel(): DeliveryChannel;
}

class EmailAlertWorkflow extends AlertWorkflow {
  protected createChannel(): DeliveryChannel {
    return new EmailChannel();
  }
}

class SmsAlertWorkflow extends AlertWorkflow {
  protected createChannel(): DeliveryChannel {
    return new SmsChannel();
  }
}

const emailWorkflow = new EmailAlertWorkflow();
const smsWorkflow = new SmsAlertWorkflow();

const sentByEmail = emailWorkflow.notify("ops@example.com", "Disk space is low");
const sentBySms = smsWorkflow.notify("+15550101", "Disk space is low");

console.log(sentByEmail, sentBySms);
```

### 2.3 Less maintainable form

```ts
type SentMessage = {
  channel: string;
  recipient: string;
  body: string;
};

interface DeliveryChannel {
  send(recipient: string, body: string): SentMessage;
}

class EmailChannel implements DeliveryChannel {
  send(recipient: string, body: string): SentMessage {
    return {
      channel: "email",
      recipient,
      body
    };
  }
}

class SmsChannel implements DeliveryChannel {
  send(recipient: string, body: string): SentMessage {
    return {
      channel: "sms",
      recipient,
      body
    };
  }
}

class AlertWorkflow {
  constructor(private readonly channelType: "email" | "sms") {}

  notify(recipient: string, body: string): SentMessage {
    let channel: DeliveryChannel;

    if (this.channelType === "email") {
      channel = new EmailChannel();
    } else {
      channel = new SmsChannel();
    }

    return channel.send(recipient, body);
  }
}

const emailWorkflow = new AlertWorkflow("email");
const smsWorkflow = new AlertWorkflow("sms");

const sentByEmail = emailWorkflow.notify("ops@example.com", "Disk space is low");
const sentBySms = smsWorkflow.notify("+15550101", "Disk space is low");

console.log(sentByEmail, sentBySms);
```

### 2.4 Why this difference matters

In the good form, `notify` is the stable base operation and `createChannel` is the localized construction variation point. Adding a push notification channel can be done by creating `PushChannel` and `PushAlertWorkflow` without changing the existing alert workflow.

In the less maintainable form, `notify` both runs the workflow and decides which concrete channel to instantiate. Every new channel requires editing that method, increasing the chance of breaking the shared alert behavior while changing construction logic.

### 2.5 Structural references

```text
Good: AlertWorkflow > createChannel and notify
Less maintainable: sendAlert > channelType conditional and concrete channel construction
```

The good form places product creation behind a dedicated factory method that the stable workflow calls. The less maintainable form places concrete product selection inside the workflow method itself.

## 3. Boundaries and distinctions

Factory Method is useful when a shared operation needs to create products, but the concrete product can vary by subclass, configuration, or supplied creator.

It may not be worth using when there is only one concrete product, when construction is trivial and unlikely to vary, or when the decision belongs at a composition root that wires objects together once. In small scripts or simple applications, a direct constructor call or a small conditional can be clearer.

Factory Method differs from Abstract Factory because Factory Method usually focuses on one product creation point inside a base operation, while Abstract Factory creates families of related products through a separate factory object. It differs from Replace Constructor with Factory Function because that refactoring hides or improves object construction behind a function, but it does not necessarily involve a base operation deferring creation to subclasses or creators.
