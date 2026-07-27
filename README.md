# Tiny Flock

Tiny Flock is a private, single-player desktop game about cozy sheep husbandry, selective breeding, and permanent multi-generation bloodlines. Sheep never die, and the project has no networking, accounts, analytics, monetization, or backend services.

> **CURRENT MILESTONE: Husbandry Simulation Prototype**

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
- Persistent seeded personality profiles, independent food preferences, derived bonding tendencies, and ranked elder-role affinities.
- Append-only structured life history, derived lifetime/breeding statistics, mutation-founder provenance, and stable-ID breeder notes.
- Version 2 identity save format and a developer Sheep Identity Lab.
- Explicit integer game time, derived lifecycle progression, and ordered flock simulation without frame or wall-clock ticks.
- Adult-active breeding eligibility, informational relatedness classification, seeded pregnancy/birth/litters, and postpartum cooldown.
- Fractional time-based wool growth, archive freeze, shear readiness, repeatable shearing history, and a developer Lifecycle Lab.
- Version 3 persistence for authoritative time, birth markers, pregnancy seeds, reproduction availability, and wool state.
- Normalized hunger, cleanliness, buffered happiness, and durable player bond with deterministic active-time decay and total archive freeze.
- Feeding and treats with food preferences, personality-sensitive petting/grooming/washing, derived mood, repeatable care history, and care statistics.
- Recoverable care-based wool efficiency and explicit breeding readiness gates, persisted in Save Version 4.

## Open the project and debug labs

When Godot 4.x becomes available, import `godot/project.godot`. The Genetics Lab is the main scene; open `scenes/debug/flock_archive_lab.tscn` directly for repository/archive controls, `scenes/debug/lifecycle_lab.tscn` for time, pregnancy, wool, and history controls, or `scenes/debug/husbandry_lab.tscn` for normalized needs and deterministic care interactions. The archive lab lists/filter sheep, shows active elder capacity and pedigree/phenotype details, and supports archive, activate-elder, and favorite actions.

Runtime execution is intentionally deferred in the current environment. The future commands are:

```bash
godot --path godot --editor
godot --headless --path godot --script tests/run_tests.gd
```

See [Milestone 1 audit](docs/verification/milestone_1_audit.md) and [runtime backlog](docs/verification/godot_runtime_backlog.md) for exact verification status. Do not interpret static verification as proof that Godot parsed or executed the project.

## Layout

- `godot/scripts/genetics/` — genome, registry, inheritance, mutation, phenotype.
- `godot/scripts/sheep/` — persistent sheep records and founder/lamb construction.
- `godot/scripts/simulation/` — clock, lifecycle, reproduction, wool, and focused simulation coordination.
- `godot/scripts/husbandry/` — needs, food, care interactions, buffered happiness, and derived mood.
- `godot/scripts/flock/` — repository, JSON persistence, pedigree, and genetic knowledge.
- `godot/scenes/debug/` — Genetics and Flock/Archive developer tools.
- `godot/tests/` — dependency-free test suite awaiting runtime validation.
- `docs/architecture/` — genetics, persistence, flock, pedigree, and visual boundaries.
- `docs/design/` — genome, founders, and elder-system specifications.
- `docs/verification/` — audit results and runtime backlog.
- `blender/` — future source-asset pipeline.

## Deferred systems

3D sheep, AI, movement, physical care animations, inventory, sheep-to-sheep social behavior, polished breeding UI, wool inventory/processing/economy, polished barn, breeder journal inference, and the farm environment are intentionally deferred. **RUNTIME VERIFICATION DEFERRED:** Godot has not parsed or executed this work; only static checks were used.
