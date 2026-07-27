# Godot Runtime Validation Backlog

Once Godot 4.x is available:

- [ ] Open `project.godot` without parser errors
- [ ] Run `tests/run_tests.gd`
- [ ] Instantiate Genetics Lab
- [ ] Breed one lamb
- [ ] Breed ten lambs
- [ ] Verify seeded breeding
- [ ] Verify save/load through GDScript
- [ ] Verify FlockRepository
- [ ] Verify Barn debug panel
- [ ] Test scene node references
- [ ] Review Godot warnings
- [ ] Verify typed enum exports in the inspector
- [ ] Exercise malformed/unsupported JSON error paths
- [ ] Confirm all test `class_name` scripts resolve in a clean import cache
- [ ] Parse and run all Milestone 3 identity tests, including seeded founder/offspring personalities
- [ ] Verify personality trait determinism, sibling bounds, and food preference exclusion
- [ ] Verify bonding and elder-role affinity resolver numeric output
- [ ] Verify append-only event copies, filters, recent ordering, and lifetime statistics
- [ ] Verify breeding-history queries and mutation-founder provenance at runtime
- [ ] Verify breeder-note add/remove/rejection and stable IDs
- [ ] Exercise version 2 JSON round trip and explicit version 1/unknown rejection
- [ ] Instantiate `scenes/debug/sheep_identity_lab.tscn`, switch sheep, and add a note
- [ ] Check Identity Lab node references, signals, formatting, and empty-state behavior

## Milestone 4 — lifecycle simulation

- [ ] Parse and run `TestLifecycleSimulation` and the complete test runner
- [ ] Verify GameTime conversions and GameClock negative rejection
- [ ] Verify exact age boundaries, one-time transitions, and 100-day jumps
- [ ] Verify all breeding eligibility and relationship classifications
- [ ] Verify conception/due boundaries, weighted litter boundaries, birth records, and postpartum cooldown
- [ ] Compare seeded direct birth with version 3 save/load birth biology and stable IDs
- [ ] Verify wool growth/clamping, archive freeze, and repeated shearing history
- [ ] Instantiate `scenes/debug/lifecycle_lab.tscn` and exercise every control
- [ ] Check Lifecycle Lab node references, signals, display formatting, and error paths
- [ ] Exercise version 3 JSON/FileAccess round trips and explicit older-version rejection
- [ ] Run Milestone 4 PR-correction fixtures: required save clock, interval wool boundaries, remote relatedness, repeat-shear statistics, mutation timestamps, derived load age, and pregnancy partner rejection
