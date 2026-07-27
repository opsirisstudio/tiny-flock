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

## Milestone 5 — husbandry, needs, bonding, and care

All items are **RUNTIME VERIFICATION DEFERRED** until an approved Godot 4 runtime exists.

- [ ] Parse and run deterministic need decay for 1 hour, 1 day, and 30 days
- [ ] Verify archive freeze and no retroactive care catch-up
- [ ] Execute feeding preference, GREEDY, CURIOUS, treat, and first-feeding history tests
- [ ] Execute CUDDLY, SOCIAL, SHY warm-up, INDEPENDENT, lamb, and elder care tests
- [ ] Execute grooming/washing bounds and structured failure-result tests
- [ ] Execute mood priority and buffered happiness tests
- [ ] Execute care-adjusted wool growth and breeding reason-code tests
- [ ] Execute Version 4 comprehensive round trip and derived-value equality tests
- [ ] Open `res://scenes/debug/husbandry_lab.tscn` and exercise every developer control

## Post-Milestone 5 — archive freeze boundary (Save Version 5)

- [ ] Parse and run `TestArchiveTransitions`
- [ ] Verify age stage freezes while archived and resumes at the correct age after restore
- [ ] Verify an archived pregnant sheep does not give birth past its due date, and that the due date shifts correctly on restore
- [ ] Verify postpartum cooldown shifts only when still pending at archive time
- [ ] Verify `FlockRepository.restore_to_flock` semantics (unknown ID, not-archived, success)
- [ ] Verify `ARCHIVED_TO_BARN`/`RETURNED_FROM_BARN` life events are recorded exactly once per transition
- [ ] Verify Version 5 round trip, explicit Version 4 rejection, and the load-time age cap for a sheep saved while still archived
- [ ] Open `res://scenes/debug/flock_archive_lab.tscn` and exercise Archive, Restore, Activate Elder, Favorite, and Advance Day together on the same sheep
