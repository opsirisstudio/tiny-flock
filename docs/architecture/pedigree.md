# Pedigree Queries

`PedigreeService` operates only on repository IDs. It provides `get_parents`, `get_children`, `get_siblings`, `get_ancestors(max_depth)`, and `get_descendants`. Missing sheep or missing parents yield empty/partial results instead of nested placeholder records.

Siblings include full siblings and half-siblings: sharing at least one non-empty parent ID is sufficient. Ancestor and descendant traversals maintain visited-ID sets, preventing cycles and duplicate ancestors when bloodlines converge. Results are stable: ascending generation, then sheep ID. The queried sheep is never returned as its own ancestor or descendant, even if malformed save data contains a cycle.

Calculated relationships and descendant counts are derived rather than persisted. Parent records remain flat, so save size does not grow recursively with pedigree depth.
