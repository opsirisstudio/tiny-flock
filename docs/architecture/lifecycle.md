# Lifecycle

Age is derived as `current total game minutes - birth_game_minute`; no age counter is persisted. Prototype half-open boundaries are lamb `[0, 7 days)`, juvenile `[7, 14)`, adult `[14, 90)`, and elder `[90 days, infinity)`. Constants live in `LifecycleConfig`.

`LifecycleService` owns resolution and mutation. It records `BECAME_JUVENILE`, `BECAME_ADULT`, and `BECAME_ELDER` once. A large jump records every crossed boundary at its logical boundary minute, without per-minute iteration. Becoming elder changes age only: it does not archive or move the sheep. The existing maximum of three `ACTIVE_ELDER` records remains repository-enforced, and an elder may remain `ACTIVE_FLOCK`.

Founder birth markers may be negative, representing sheep born before the simulation epoch; authoritative clock time itself is never negative.

`update_age_stage` (and every other simulation-effect function) refuses to run on a `BARN_ARCHIVE` sheep. Age is otherwise always re-derived from `birth_game_minute`, so freezing it while archived requires `birth_game_minute` itself to shift forward by the archived duration when the sheep is restored — see [archive transitions](archive_transitions.md) for the full mechanism, including why the same shift is required at load time for a sheep saved while still archived.
