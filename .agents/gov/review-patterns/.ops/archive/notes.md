if decided to do it like:
/home/scott/Documents/tmp/md/z-work/design-concepts
├── design-concepts-catalog.md
├── examples
│   └── ... concept examples ...
└── .ops
    ├── 00-research.md
    ├── 01-make-examples.md
    ├── ref
    │   ├── ex_list.md
    │   ├── old-prompt.md
    │   ├── sources.md
    │   ├── structure.md
    │   └── why.md
    └── update.md





see the rules in:
/home/scott/Documents/tmp/md/z-work/pitfalls/typescript.md

we want to do something SIMILAR but NOT a carbon copy. 
we want to create:
/home/scott/Documents/tmp/md/z-work/design-concepts/design-concepts-rules.md

it should follow the same heading pattern as:
/home/scott/Documents/tmp/md/z-work/design-concepts/design-concepts-catalog.md

for code examples you can see:
/home/scott/Documents/tmp/md/z-work/design-concepts/examples



each item should get a corresponding rule. the rule should be on a single line. the rule sould be in the format:
```php-template
<index> **<name>** - rule
```

Each rule should focus on either prevention (bad patterns) or enforcement (good patterns)

create /home/scott/Documents/tmp/md/z-work/design-concepts/design-concepts-rules.md accordingly





okay, im going to turn:
/home/scott/Documents/tmp/md/z-work/pitfalls/typescript.md
into:
/home/scott/Documents/tmp/md/z-work/pitfalls/typescript/typescript-pitfalls-catalog.md
/home/scott/Documents/tmp/md/z-work/pitfalls/typescript/typescript-pitfalls-rules.md
/home/scott/Documents/tmp/md/z-work/pitfalls/typescript/examples/<index>-name.md

I want it to follow the same formatting as:
/home/scott/Documents/tmp/md/z-work/design-concepts/design-concepts-catalog.md
/home/scott/Documents/tmp/md/z-work/design-concepts/design-concepts-rules.md
/home/scott/Documents/tmp/md/z-work/design-concepts/examples/*

what do you think is the best way to go about this?

```swift
/home/scott/Documents/tmp/md/z-work/design-concepts/.ops/00-research.md
/home/scott/Documents/tmp/md/z-work/design-concepts/.ops/01-make-examples.md
/home/scott/Documents/tmp/md/z-work/design-concepts/.ops/02-create-rules.md
/home/scott/Documents/tmp/md/z-work/design-concepts/.ops/update.md
```

contain the formatting and everything. I want to  make them uniform so i can reuse this structure. 

i guess what I'm really trying to determine is a spec for the -catalog.md, *-rules.md, and examples/ files


