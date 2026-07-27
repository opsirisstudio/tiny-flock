# Milestone 1 Audit

- **Audit date:** 2026-07-27
- **Commit audited:** `4249337` (`Build initial sheep genetics prototype`)
- **Runtime status:** **NOT RUNTIME VERIFIED — RUNTIME VERIFICATION DEFERRED**

## Scope reviewed

Every tracked Milestone 1 GDScript, `project.godot`, Genetics Lab scene, README, registry entry, founder definition, and test was read. Repository-wide searches checked repository nesting, empty GDScript files, duplicate `class_name` declarations, `res://` references, preload/load targets, generated artifacts, and Godot 3-era syntax. All 25 registry loci and legal allele sets were compared with the authoritative specification.

## PASS — statically verified

- The repository root is `/workspace/tiny-flock`; no nested repository exists.
- Required Milestone 1 files exist, required scripts are non-empty, `class_name` values are unique, and all current `res://` references resolve.
- `project.godot` uses Godot configuration version 5 and points to the existing debug scene. The scene's attached script, unique-name selectors/output nodes, and signal handlers agree statically.
- The registry contains each requested locus exactly once with correct locus-scoped alleles and two-allele validation.
- Pair normalization makes all unordered genotype lookups independent of input order.
- Breeding copies allele strings into a new genome, uses only its supplied seeded RNG, validates before and after the separate mutation stage, and does not share pair Arrays with either parent.
- Mutation is a single per-lamb event at the named `0.005` default and is limited to LAV, ROS, or STR.
- Phenotype mappings and conditional suppression agree with the genome specification under static inspection.
- Sheep records use parent IDs and `max(parent generations) + 1`; founder IDs are distinct and founders are generation 0.
- `.gitignore` retains `.gd`, `.tscn`, `.tres`, `project.godot`, and intentional `.blend` files while excluding Godot caches, Blender backups, build output, IDE state, and OS junk.

## FIXED defects found

1. **Test coverage was materially incomplete.** It did not comprehensively cover allele order, all requested phenotype tables, parent immutability/resource independence, reproducibility/different seeds, mutation chance zero, wool-pattern/horn-shape suppression, or all founder invariants. Tests were expanded with deterministic assertions.
2. **The Genetics Lab allowed the same record in both parent roles.** Selection validation now surfaces an explicit error and refuses that breeding action.
3. **The prior README overstated verification.** It described the suite as functioning despite never executing it. Verification language now distinguishes static verification from deferred runtime validation.
4. **Founder documentation was incomplete.** A dedicated document now records complete actual genotypes, resolved phenotype summaries, and hidden carriers.
5. **Resource-independence assertions used value inequality for Dictionaries.** They now use `is_same` so the tests actually check container identity.
6. **The lamb ID scheme used only seconds plus a process-local counter.** It was strengthened with microsecond ticks; repository-level duplicate rejection remains the authoritative uniqueness guard.

## Tests reviewed and strengthened

- `test_genome_validation.gd`: completeness, unknown loci, illegal alleles, wrong pair lengths, normalization, and copy independence.
- `test_phenotype_resolver.gd`: complete direct genotype matrices, conditional suppression/expression, rare traits, pair-order equivalence, and determinism.
- `test_breeding_engine.gd`: parent contribution, parent immutability, distinct resources, same-seed equality, different-seed validity/variation, mutation-disabled behavior, and generation.
- `test_mutation_manager.gd`: disabled, probability zero, probability one, exactly one conservative rare-allele change, validation, and source-genome isolation.
- Founder validation is covered by repository/founder tests added in Milestone 2.

## NOT RUNTIME VERIFIED

Godot is intentionally unavailable for this milestone. No claim is made that scripts parsed, scenes instantiated, signals executed, resources exported, JSON FileAccess operations completed, or tests passed in Godot. These items are recorded in `godot_runtime_backlog.md`.

## Remaining limitations

- Static review cannot prove Godot parser acceptance, class cache resolution, `Resource` export serialization behavior, scene lifecycle, signal dispatch, or platform FileAccess behavior.
- Assertions are development failures; a later user-facing layer will need recoverable error presentation.
- Mutation weights are intentionally provisional and uniform among the three supported loci.

## Confidence assessment

**Milestone 1: PASS under static verification, NOT RUNTIME VERIFIED.** No authoritative genetics rule was changed. The static gate is satisfied after the fixes and expanded deterministic tests; runtime acceptance remains a dedicated future milestone.
