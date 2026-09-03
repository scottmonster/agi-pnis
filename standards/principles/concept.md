1. **YAGNI** - Scope gate. Do not solve problems that do not currently exist.
2. **KISS** - Governing principle. Minimize total unnecessary complexity.
3. **Rule of Three** - Abstraction gate. Do not generalize before repeated evidence justifies it.
4. **Principle of Least Power** - Mechanism choice. Use the least capable mechanism that adequately solves the problem.
5. **Separation of Concerns** - Structural rule. Separate things when distinct responsibilities genuinely benefit from separate boundaries.
6. **Composition over Inheritance** - Specific structural preference. Favor composition when choosing how behavior should be assembled.
7. **Occam's Razor** - Tie-breaker. Among adequate designs, prefer the one requiring fewer assumptions and mechanisms.

The important part is that they form something closer to a decision sequence:

```text
Is this needed now?
    YAGNI

What is the simplest adequate solution?
    KISS

Am I introducing an abstraction?
    Rule of Three

What mechanism should implement it?
    Principle of Least Power

How should responsibilities be organized?
    Separation of Concerns

How should behavior be assembled?
    Composition over Inheritance

Several options still remain?
    Occam's Razor
```

#### Decision Sequence

* **Is this needed now?** YAGNI
* **What is the simplest adequate solution?** KISS
* **Am I introducing an abstraction?** Rule of Three
* **What mechanism should implement it?** Principle of Least Power
* **How should responsibilities be organized?** Separation of Concerns
* **How should behavior be assembled?** Composition over Inheritance
* **Do multiple adequate options remain?** Occam's Razor

#### Decision Flow

Apply the principles as a sequence. Each step constrains the decisions available to the steps that follow.

1. **Is this needed now?** -> **YAGNI**

   * If no, do not build it.
   * If yes, continue.

2. **What is the simplest adequate solution?** -> **KISS**

   * Establish the simplest solution that satisfies the need.

3. **Does the solution require an abstraction?** -> **Rule of Three**

   * Introduce one only when demonstrated repetition or evidence justifies it.

4. **What mechanism should implement it?** -> **Principle of Least Power**

   * Choose the least powerful mechanism that is sufficient.

5. **How should responsibilities be organized?** -> **Separation of Concerns**

   * Separate only where meaningful boundaries improve the design.

6. **How should behavior be assembled?** -> **Composition over Inheritance**

   * Prefer composition when it provides the simpler, less coupled structure.

7. **Do multiple adequate designs still remain?** -> **Occam's Razor**

   * Prefer the one requiring fewer assumptions and mechanisms.


#### Supporting Concepts

These concepts support the primary framework but are not part of its canonical decision sequence:

1. **Single Responsibility** - Cohesion rule. Keep responsibilities together when they serve the same purpose and separate them when they have materially different reasons to change.
2. **Principle of Least Astonishment** - Predictability rule. Prefer behavior, interfaces, and conventions that reasonable users and maintainers can correctly anticipate.
3. **Law of Demeter** - Coupling rule. Limit dependence on the internal structure of other components while avoiding unnecessary wrappers or indirection.
4. **Fail Fast** - Failure-handling rule. Detect and surface invalid states and violated assumptions as close to their source as practical when continued execution cannot meaningfully recover.
