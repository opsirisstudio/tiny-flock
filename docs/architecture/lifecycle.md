# Lifecycle

Age is derived as `current total game minutes - birth_game_minute`; no age counter is persisted. Prototype half-open boundaries are lamb `[0, 7 days)`, juvenile `[7, 14)`, adult `[14, 90)`, and elder `[90 days, infinity)`. Constants live in `LifecycleConfig`.

`LifecycleService` owns resolution and mutation. It records `BECAME_JUVENILE`, `BECAME_ADULT`, and `BECAME_ELDER` once. A large jump records every crossed boundary at its logical boundary minute, without per-minute iteration. Becoming elder changes age only: it does not archive or move the sheep. The existing maximum of three `ACTIVE_ELDER` records remains repository-enforced, and an elder may remain `ACTIVE_FLOCK`.

Founder birth markers may be negative, representing sheep born before the simulation epoch; authoritative clock time itself is never negative.
