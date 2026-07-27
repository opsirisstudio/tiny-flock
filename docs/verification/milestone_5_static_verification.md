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
