# Milestone 2 Static Verification

- **Date:** 2026-07-27
- **Status:** **STATICALLY VERIFIED**
- **Runtime status:** **RUNTIME VERIFICATION DEFERRED**

## Checks completed

- Reviewed every changed GDScript, scene, test, documentation file, and serialized field.
- Ran `tools/static_verify.py`: required files were non-empty; 24 GDScript files were scanned; 21 `class_name` declarations were unique; all 25 loci occurred exactly once and in authoritative order; all `res://`, preload, and load targets existed; scene handlers and unique-name node references agreed statically; no detected Godot 3 property syntax remained.
- Ran `git diff --check` successfully.
- Confirmed repository-only `Resource` data, duplicate-ID rejection, three-elder enforcement, archive retention, separate genetic knowledge, save version checks, new-object restoration, cycle guards, and stable pedigree sorting by code inspection.
- Reviewed deterministic tests for genome and phenotype rules, breeding independence, mutation boundaries, founder validity, elder transitions, JSON round trip, archive phenotype reproduction, pedigree convergence/cycles, and knowledge persistence.

## Additional defects fixed during Milestone 2

- Dictionary inequality in early independence tests compared values rather than object identity. Tests now use `is_same` to prove containers/resources are distinct.
- Repository insertion could previously accept a pre-located fourth active elder or a non-elder marked active elder. Insertion and `SheepRecord.validate()` now enforce those invariants.
- Invalid knowledge lookups previously constructed an invalid placeholder. They now return `null` with an explanatory repository error.
- Record validation now checks enum ranges, active-elder age consistency, and legacy-tag ranges in addition to genome and identity.

## RUNTIME VERIFICATION DEFERRED

The following remain unproven until Godot 4.x is available: parser acceptance, typed enum behavior, global class cache resolution, scene instantiation/signals, `FileAccess`, JSON runtime conversion, and actual test execution. The actionable checklist is maintained in `godot_runtime_backlog.md`.
