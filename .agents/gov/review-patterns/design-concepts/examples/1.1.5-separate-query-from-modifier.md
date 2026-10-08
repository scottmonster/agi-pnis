# Separate Query from Modifier

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 1.1.5
- **Aliases:** None
- **Definition:** Split a routine that both reports information and changes state into a query and a command. Callers can reason about observation and mutation separately.
- **Why it matters:** It makes code easier to read and maintain because callers can tell whether a routine only observes state or also changes it. This reduces surprise, simplifies testing, and lets query logic and mutation logic change independently.
- **Related concepts:** Command pattern

## 2. Example

### 2.1 Scenario

A reservation service expires active reservations whose expiration time has passed. The caller needs the expired reservation IDs for logging and must also mark those reservations as canceled.

### 2.2 Good form

```ts
type ReservationStatus = "active" | "canceled";

type Reservation = {
  id: string;
  expiresAt: Date;
  status: ReservationStatus;
};

function findExpiredReservationIds(
  reservations: Reservation[],
  now: Date
): string[] {
  return reservations
    .filter(
      (reservation) =>
        reservation.status === "active" && reservation.expiresAt <= now
    )
    .map((reservation) => reservation.id);
}

function cancelReservations(
  reservations: Reservation[],
  reservationIds: string[]
): void {
  const idsToCancel = new Set(reservationIds);

  for (const reservation of reservations) {
    if (idsToCancel.has(reservation.id) && reservation.status === "active") {
      reservation.status = "canceled";
    }
  }
}

const reservations: Reservation[] = [
  { id: "r-100", expiresAt: new Date("2025-01-01T10:00:00Z"), status: "active" },
  { id: "r-101", expiresAt: new Date("2025-01-01T12:00:00Z"), status: "active" }
];

const now = new Date("2025-01-01T11:00:00Z");
const expiredReservationIds = findExpiredReservationIds(reservations, now);

cancelReservations(reservations, expiredReservationIds);

console.log(`Canceled reservations: ${expiredReservationIds.join(", ")}`);
```

### 2.3 Less maintainable form

```ts
type ReservationStatus = "active" | "canceled";

type Reservation = {
  id: string;
  expiresAt: Date;
  status: ReservationStatus;
};

function cancelExpiredReservations(
  reservations: Reservation[],
  now: Date
): string[] {
  const canceledIds: string[] = [];

  for (const reservation of reservations) {
    if (reservation.status === "active" && reservation.expiresAt <= now) {
      reservation.status = "canceled";
      canceledIds.push(reservation.id);
    }
  }

  return canceledIds;
}

const reservations: Reservation[] = [
  { id: "r-100", expiresAt: new Date("2025-01-01T10:00:00Z"), status: "active" },
  { id: "r-101", expiresAt: new Date("2025-01-01T12:00:00Z"), status: "active" }
];

const now = new Date("2025-01-01T11:00:00Z");
const expiredReservationIds = cancelExpiredReservations(reservations, now);

console.log(`Canceled reservations: ${expiredReservationIds.join(", ")}`);
```

### 2.4 Why this difference matters

In the good form, `findExpiredReservationIds` is a query: it reports which reservations are expired without changing anything. `cancelReservations` is a command: it changes reservation state without also calculating and returning a result. A caller can inspect expired reservations, test the selection rule, or reuse the cancellation command without depending on a routine that does both at once.

In the less maintainable form, `cancelExpiredReservations` hides a state change behind a routine that also returns data. Any caller that only wants to know which reservations are expired must also cancel them, and any change to the expiration rule risks changing mutation behavior at the same time.

### 2.5 Structural references

```text
Good: reservation-service > reservations > expiration.ts > findExpiredReservationIds > expired reservation selection
Less maintainable: reservation-service > reservations > expiration.ts > cancelExpiredReservations > combined selection and cancellation
```

The relevant structural difference is that the good form gives observation and mutation separate functions, while the less maintainable form places both responsibilities in one function.

## 3. Boundaries and distinctions

This refactoring applies when a routine both returns information and mutates state, especially when callers may reasonably want one behavior without the other. It is less important for simple, conventional operations where the mutation is the whole point and the returned value is incidental, such as `array.pop()` returning the removed item.

The combined form can be appropriate when an operation must be atomic, when separating query and command would introduce a race condition, or when an external API intentionally provides one transactional operation. In those cases, name the routine clearly so callers know it mutates state.

This concept is related to the Command pattern but is not the same thing. Separate Query from Modifier is a refactoring rule about keeping observation and mutation apart. The Command pattern is a design pattern that represents an action as an object so it can be queued, logged, undone, or passed around.
