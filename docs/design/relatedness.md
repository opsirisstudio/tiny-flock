# Relatedness classification

`RelationshipService` uses flat parent IDs and cycle-safe `PedigreeService` traversal to classify `SELF`, `PARENT_CHILD`, `FULL_SIBLING`, `HALF_SIBLING`, `OTHER_RELATIVE`, `UNRELATED`, or `UNKNOWN`. Other relative means a known shared ancestor beyond sibling rules; missing records produce unknown. The warning API is informational: related eligible sheep may breed in Milestone 4. No inbreeding coefficient or sex-linked genetics is implied.
