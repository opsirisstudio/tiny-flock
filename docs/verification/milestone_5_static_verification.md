# Milestone 5 static verification

## Architecture implemented

Milestone 5 adds normalized persistent needs, direct active-time decay, buffered happiness, non-decaying bond, a food registry and four focused interaction services, structured results, derived mood, history-derived care statistics, wool efficiency, breeding care gates, Version 4 persistence, a developer Husbandry Lab, and prepared deterministic tests. `SheepRecord` remains passive state, `FlockRepository` remains an index/invariant boundary, and `SimulationCoordinator` delegates care rules.

## Files reviewed and tests prepared

The root README; architecture, design, and verification documentation; record/personality/bonding/history/repository/time/lifecycle/pregnancy/breeding/wool/shearing/persistence implementations; all changed husbandry files; debug scene/script; static verifier; and test suite were reviewed. Prepared GDScript coverage includes W1–W18: direct decay/large jumps, archive freeze, feeding/preferences and GREEDY, care interactions and SHY curve, mood priorities, happiness buffering, wool efficiency, breeding gates, lamb/elder eligibility boundaries, unique first feeding, derived statistics, and Version 4 round trip. Godot execution remains deferred.

## Static checks, defects, and fixes

`tools/static_verify.py`, Python compilation, documentation-link validation (inside the verifier), `git diff --check`, status inspection, and generated/cache-file inspection are the authoritative checks. During review, the legacy mixed 0–100 defaults and Version 3 fallback defaults were found and replaced with strict normalized Version 4 state. Care events were made repeatable while `FIRST_FEEDING` remains unique. Derived mood and wool efficiency are deliberately absent from persistence.

## Save Version 4 and cozy-care invariants

Version 4 preserves all Version 3 biology/time fields and requires hunger, cleanliness, happiness, and bond. Versions 1–3 fail clearly rather than being reinterpreted. No wall clock, per-minute loop, offline progression, passive bond decay, death, illness, injury, deletion, permanent neglect change, login streak, or archive catch-up was introduced. Archived records remain frozen.

## Runtime-deferred items and risks

**RUNTIME VERIFICATION DEFERRED.** Godot is unavailable and was neither installed nor downloaded. Remaining risks are Godot parser/type behavior and scene execution, exact balance feel, and the interval approximation that applies the post-decay care efficiency uniformly to a wool-growth jump. These require the approved runtime and later playtesting; static verification is not runtime proof.

## Post-milestone correction: archive freeze boundary (Save Version 5)

An independent audit found that `BARN_ARCHIVE` was not actually the absolute simulation boundary the architecture docs claimed. `HusbandrySimulationService`/`WoolGrowthService` correctly checked location before applying needs decay and wool growth, but two other simulation-effect paths had no such check at all:

1. `PregnancyService.resolve_due_pregnancy`/`resolve_all_due` never checked `location`, so an archived pregnant sheep would still give birth the moment her due date passed, regardless of how long she had been archived.
2. `LifecycleService.update_age_stage` never checked `location`, so an archived sheep would silently age through `LAMB`/`JUVENILE`/`ADULT`/`ELDER` (recording the transition life events) purely from elapsed clock time.

Both now return/reject early on `BARN_ARCHIVE`. Because age stage and pregnancy/cooldown timing are *re-derived from absolute timestamps* rather than incrementally mutated, a location guard alone is not sufficient to keep them frozen across a save/reload of a still-archived sheep — the timestamps themselves (`birth_game_minute`, `breeding_available_game_minute`, `pregnancy.due_game_minute`) must be shifted forward by the archived duration when the sheep leaves the barn. `SheepRecord.archived_at_game_minute` and the new `ArchiveTransitionService` (wrapping `FlockRepository.archive_sheep`/`restore_to_flock`/`activate_elder` with this bookkeeping) implement that shift; `FlockPersistence` additionally caps the age-derivation reference time at `archived_at_game_minute` for a sheep that is still archived when loaded. See [archive transitions](../architecture/archive_transitions.md) for the full design.

`FlockRepository` gained `restore_to_flock`, since no path previously existed to return a non-elder archived sheep to `ACTIVE_FLOCK` at all. Save Version 5 adds the required `archived_at_game_minute` field and explicitly rejects Version 4. `TestArchiveTransitions` covers age freeze/resume, archived-pregnancy rejection and due-date shift, pending-vs-already-expired cooldown shift, `restore_to_flock` repository semantics, `ARCHIVED_TO_BARN`/`RETURNED_FROM_BARN` event recording (previously declared but never emitted), and the Version 5 round trip including the load-time age cap. The Flock & Archive Lab now carries its own `GameClock`, an `Advance Day` control, and a `Restore` button, and routes archive/activate-elder through `ArchiveTransitionService`, so the freeze can actually be exercised interactively once Godot is available.
