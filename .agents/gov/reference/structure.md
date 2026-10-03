# Hierarchical Structural Reference

A hierarchical structural reference identifies where code is by moving from a broad context to progressively narrower containing elements.

## The model

A reference can be described with familiar code structures:

```text
Project
└── Package or module
    └── File
        └── Namespace, type, or class
            └── Function or method
                └── Block or statement
                    └── Line or range
```

Languages use different names and may omit or add structures. The same pattern can be described with general roles:

```text
Root context
└── Group or container
    └── Source unit
        └── Code element
            └── Nested code element
                └── Target
```

- **Root context** is the overall place being referenced, such as a project, repository, workspace, or package.
- **Group or container** organizes related source units, such as a folder, package, module, namespace, or component.
- **Source unit** is a distinct piece of source material, usually a file.
- **Code element** is an identifiable unit in that source, such as a class, function, type, rule, query, or selector.
- **Nested code element** is an identifiable unit within another element, such as a method, inner class, statement, expression, or declaration.
- **Target** is the exact item of interest. It can be a code element, statement, expression, line, or line range.

These are roles, not required levels or fixed pairs. A reference includes only the levels that exist and help identify its target. Each part identifies something within the context established by the part before it.

## Common language mappings

These examples show how common code structures fit the model. They are not required paths.

| Code style or language | Common reference path |
|---|---|
| Python, Ruby, or simple JavaScript | `project > folder > file > function > line` |
| Java, C#, Kotlin, or Swift | `project > package > file > class or type > method > line` |
| JavaScript or TypeScript modules | `project > folder > file or module > exported function or class > target` |
| Go | `project > package > file > function or type > method or statement` |
| Rust | `workspace > crate > module > file > function, type, or trait > target` |
| C or C++ | `project > folder > file > function, struct, or class > statement or line` |
| HTML | `project > folder > file > element > attribute or content > line` |
| CSS | `project > folder > file > selector or rule > declaration > line` |
| SQL | `project > database area > file > query, procedure, or function > statement` |

For example, a Java method and a CSS declaration use different names but follow the same pattern:

```text
Java
project > package > UserService.java > UserService > createUser() > lines 24-39

CSS
project > styles > account.css > .profile-card > padding > line 18
```

## Using the model

Use only the levels that exist and help identify the target. Do not invent a class, folder, or other level that is not present.

Start with the broadest useful context. Then add each enclosing structure until the target is clear. Use names when the structure has a name. Add a line or range only when the named target is not precise enough.
