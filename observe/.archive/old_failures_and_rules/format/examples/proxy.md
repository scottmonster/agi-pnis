# Proxy

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.12
- **Aliases:** None
- **Definition:** Substitute an object that controls access to another object with the same interface. It localizes access, caching, or remoting concerns, but can hide cost or behavior.
- **Why it matters:** A proxy keeps access-control concerns near the object boundary instead of scattering them through callers. This makes code easier to read because clients depend on the intended interface, easier to understand because caching or remoting behavior has one location, and easier to maintain because access behavior can change without rewriting every caller.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A reporting page renders the same quarterly report more than once during a request. Fetching the report from the remote service is expensive, so repeated reads should use a cache while preserving the same report-fetching interface.

### 2.2 Good form

```ts
interface ReportGateway {
  fetchReport(reportId: string): Promise<string>;
}

class RemoteReportGateway implements ReportGateway {
  public requestCount = 0;

  constructor(private readonly reports: Record<string, string>) {}

  async fetchReport(reportId: string): Promise<string> {
    this.requestCount += 1;

    const report = this.reports[reportId];
    if (report === undefined) {
      throw new Error(`Report not found: ${reportId}`);
    }

    return report;
  }
}

class CachedReportProxy implements ReportGateway {
  private readonly cache = new Map<string, string>();

  constructor(private readonly origin: ReportGateway) {}

  async fetchReport(reportId: string): Promise<string> {
    const cached = this.cache.get(reportId);
    if (cached !== undefined) {
      return cached;
    }

    const report = await this.origin.fetchReport(reportId);
    this.cache.set(reportId, report);
    return report;
  }
}

async function renderReport(
  gateway: ReportGateway,
  reportId: string,
): Promise<string> {
  const report = await gateway.fetchReport(reportId);
  return `<article>${report}</article>`;
}

async function example(): Promise<void> {
  const remote = new RemoteReportGateway({
    q4: "Q4 revenue increased by 12%.",
  });

  const gateway: ReportGateway = new CachedReportProxy(remote);

  console.log(await renderReport(gateway, "q4"));
  console.log(await renderReport(gateway, "q4"));
  console.log(`Remote requests: ${remote.requestCount}`);
}

void example();
```

### 2.3 Less maintainable form

```ts
class RemoteReportGateway {
  public requestCount = 0;

  constructor(private readonly reports: Record<string, string>) {}

  async fetchReport(reportId: string): Promise<string> {
    this.requestCount += 1;

    const report = this.reports[reportId];
    if (report === undefined) {
      throw new Error(`Report not found: ${reportId}`);
    }

    return report;
  }
}

async function renderReport(
  gateway: RemoteReportGateway,
  cache: Map<string, string>,
  reportId: string,
): Promise<string> {
  let report = cache.get(reportId);

  if (report === undefined) {
    report = await gateway.fetchReport(reportId);
    cache.set(reportId, report);
  }

  return `<article>${report}</article>`;
}

async function example(): Promise<void> {
  const remote = new RemoteReportGateway({
    q4: "Q4 revenue increased by 12%.",
  });

  const cache = new Map<string, string>();

  console.log(await renderReport(remote, cache, "q4"));
  console.log(await renderReport(remote, cache, "q4"));
  console.log(`Remote requests: ${remote.requestCount}`);
}

void example();
```

### 2.4 Why this difference matters

In the good form, `CachedReportProxy` has the same `ReportGateway` interface as the remote gateway, so `renderReport` does not know whether it is reading from the network, memory, or another source. The caching concern is localized at the access boundary.

In the less maintainable form, the caller must pass both the remote gateway and the cache, and `renderReport` must implement the access policy itself. If another caller needs the same behavior, it must duplicate or share that logic manually. The behavior is still correct, but the access-control concern is spread into client code instead of being represented as a substitutable object.

### 2.5 Structural references

```text
Good: reporting-app > reports > reportGateway.ts > renderReport > ReportGateway
Less maintainable: reporting-app > reports > reportPage.ts > renderReport > RemoteReportGateway
```

The good structure points the rendering function at the stable `ReportGateway` target, allowing either the real gateway or proxy to be supplied. The less maintainable structure points the rendering function directly at the remote gateway and forces cache management into the same function that renders the report.

## 3. Boundaries and distinctions

Proxy applies when one object should stand in for another object with the same interface while controlling access to it. Common reasons include lazy loading, caching, authorization checks, logging access, rate limiting, or hiding remote communication.

It does not apply when there is no separate access concern to isolate. If a simple function calls a local object once and no caching, remoting, permission check, or lifecycle control is needed, adding a proxy only adds indirection. The less maintainable form can be appropriate for a small script, a one-off migration, or a narrow code path where duplicating the access logic is unlikely and introducing another object would obscure the code.

Proxy differs from Adapter because an adapter changes one interface into another, while a proxy preserves the same interface. It differs from Decorator because a decorator primarily adds responsibilities to behavior, while a proxy primarily controls access to another object. The distinction can be subtle because both wrap another object, but the proxy's key purpose is managing access rather than extending the domain behavior itself.
