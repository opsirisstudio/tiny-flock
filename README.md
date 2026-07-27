# Tiny Flock

Tiny Flock is a private, single-player desktop game about cozy sheep husbandry, selective breeding, and permanent multi-generation bloodlines. Sheep never die, and the project has no networking, accounts, analytics, monetization, or backend services.

> **CURRENT MILESTONE: Persistent Flock Prototype**

- **Engine:** Godot 4.x
- **Language:** typed GDScript
- **Art pipeline:** Blender
- **Verification:** **STATICALLY VERIFIED — RUNTIME VERIFICATION DEFERRED**

## Implemented systems

- Validated, locus-scoped 25-locus sheep genomes and deterministic phenotype resolution.
- Seeded Mendelian breeding, a separate per-lamb mutation stage, four documented founders, and flat ID-based ancestry.
- Authoritative `FlockRepository` with unique IDs, active/archive locations, a domain-enforced maximum of three active elders, favorites, legacy tags, and elder roles.
- Versioned human-readable JSON save/load preserving full genomes, ancestry, husbandry state, metadata, and player genetic knowledge.
- Cycle-safe pedigree queries for parents, children, half/full siblings, ancestors, and descendants.
- Separate per-sheep/per-locus knowledge states: unknown, suspected, confirmed, and genotyped.
- Developer Genetics Lab and Flock & Archive Lab scenes.
- Dependency-free deterministic GDScript tests prepared for the future Godot runtime-validation milestone.

## Open the project and debug labs

When Godot 4.x becomes available, import `godot/project.godot`. The Genetics Lab is the main scene; open `scenes/debug/flock_archive_lab.tscn` directly for repository/archive controls. The archive lab lists/filter sheep, shows active elder capacity and pedigree/phenotype details, and supports archive, activate-elder, and favorite actions.

Runtime execution is intentionally deferred in the current environment. The future commands are:

```bash
godot --path godot --editor
godot --headless --path godot --script tests/run_tests.gd
```

See [Milestone 1 audit](docs/verification/milestone_1_audit.md) and [runtime backlog](docs/verification/godot_runtime_backlog.md) for exact verification status. Do not interpret static verification as proof that Godot parsed or executed the project.

## Layout

- `godot/scripts/genetics/` — genome, registry, inheritance, mutation, phenotype.
- `godot/scripts/sheep/` — persistent sheep records and founder/lamb construction.
- `godot/scripts/flock/` — repository, JSON persistence, pedigree, and genetic knowledge.
- `godot/scenes/debug/` — Genetics and Flock/Archive developer tools.
- `godot/tests/` — dependency-free test suite awaiting runtime validation.
- `docs/architecture/` — genetics, persistence, flock, pedigree, and visual boundaries.
- `docs/design/` — genome, founders, and elder-system specifications.
- `docs/verification/` — audit results and runtime backlog.
- `blender/` — future source-asset pipeline.

## Deferred systems

3D sheep, sheep AI, elder autonomous behavior, animations, husbandry interactions, shearing, wool processing, polished Barn UI, Breeder Journal inference, and the farm environment are intentionally out of scope for this milestone.
