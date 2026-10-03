### 9.3 Stable identifiers, locations, and indexes

Material episode records are stored as first-class records in the tracking system.

The tracker supports four material episode record types:

* `JR` - Judgment Record
* `JUR` - Judgment Update Record
* `FR` - Failure Record
* `FUR` - Failure Update Record

Each record has a permanent canonical identifier:

```text
JR-<id>
JUR-<id>
FR-<id>
FUR-<id>
```

The canonical identifier belongs to the record, not to a particular tracker implementation. GitHub issue numbers, Markdown paths, database IDs, URLs, or other backend identifiers are implementation references and may change without changing the canonical record ID.

Each record is individually addressable and retrievable by its canonical ID.

Update records are separate records linked to the record they update:

```text
JUR -> JR
FUR -> FR
```

Records may also reference other judgments, failures, work issues, tasks, repositories, artifacts, or external evidence when material.

The tracker provides indexes or equivalent queries sufficient to discover records by:

* canonical ID
* record type
* repository/project or other applicable scope
* classification
* related or updated record

The tracker is the canonical discovery location. Physical storage paths are implementation details. A backend may use issues, database rows, Markdown files, or another representation as long as canonical IDs and relationships are preserved.
