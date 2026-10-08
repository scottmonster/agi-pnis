# Miscellaneous Rules

## 1. Control-flow and batch-processing heuristics

1.1 **Push Ifs Up and Fors Down** - When many items share a decision or operation, make the decision once at the caller or orchestration boundary and give lower-level code a valid input or batch to process, protecting clear control flow and efficient repeated work.
