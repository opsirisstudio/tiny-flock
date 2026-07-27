# Archive freeze and transition

`BARN_ARCHIVE` is meant to be an absolute simulation boundary: nothing about an archived sheep should change while it sits in the historical catalog, and restoring it should never apply a backlog of "catch-up" simulation for the time it spent archived. Two categories of state need different freeze mechanisms to make that true.

## Directly-mutated state: guard at the point of use

Hunger, cleanliness, happiness, and wool growth are incrementally mutated by focused services (`HusbandrySimulationService`, `HappinessService`, `WoolGrowthService`) that already check `sheep.location == BARN_ARCHIVE` internally before touching anything. Because location changes only ever happen between simulation ticks, not during one, checking location once at the moment a tick runs is sufficient for these values — there is no partial-interval case to account for.

`LifecycleService.update_age_stage` and `PregnancyService.resolve_due_pregnancy`/`resolve_all_due` did **not** have this guard. Age stage was derived unconditionally from `birth_game_minute` versus the live clock every tick, and pregnancy resolution never checked location at all — so an archived sheep would silently age through lifecycle stages (recording `BECAME_JUVENILE`/`BECAME_ADULT`/`BECAME_ELDER` along the way), and an archived pregnant ewe would still give birth the moment her due date passed, regardless of how long she'd been "frozen." Both now return early when `sheep.location == BARN_ARCHIVE`.

## Timestamp-derived state: shift on the way out

Age and reproduction timing are not incremental — `age_stage` is re-derived from `current_time - birth_game_minute` every time it's needed (live tick *and* on every load, since `age_stage` is not authoritative in the save format), and pregnancy/cooldown are absolute deadlines (`due_game_minute`, `breeding_available_game_minute`) compared against the live clock. A location guard alone freezes the *live* derivation but does nothing for the *next* re-derivation once the sheep leaves the barn, or for a save made while the sheep is still archived.

`SheepRecord.archived_at_game_minute` (default `-1`, meaning "not currently archived") records the game minute a sheep entered `BARN_ARCHIVE`. `ArchiveTransitionService` is the time-aware entry point for every archive/restore/elder-activation action:

- **Entering archive** (`archive`): stamps `archived_at_game_minute` to the current minute (only on the transition *into* archive — calling it again on an already-archived sheep is a no-op for the stamp) and records `ARCHIVED_TO_BARN`.
- **Leaving archive** (`restore_to_flock`, `activate_elder` when coming from `BARN_ARCHIVE`): computes `frozen_minutes = current_minute - archived_at_game_minute`, then shifts every absolute timestamp that represents a future deadline or age epoch forward by that amount — `birth_game_minute` always, `breeding_available_game_minute` only if it was still pending at the moment of archiving (already-expired cooldowns are left alone rather than incorrectly re-armed), and `pregnancy.due_game_minute` if the sheep is pregnant. `archived_at_game_minute` resets to `-1` and `RETURNED_FROM_BARN` is recorded.

Shifting `birth_game_minute` rather than tracking a separate "effective age" means every existing age/eligibility/wool-boundary formula keeps working completely unmodified — they only ever see an honest timestamp.

`FlockRepository.archive_sheep`/`activate_elder`/`restore_to_flock` remain pure, time-unaware location transitions (consistent with the repository's existing role as an index/invariant boundary, not a time authority); calling them directly — as existing pure-repository tests do — skips the freeze bookkeeping entirely. Real gameplay and the debug lab must go through `ArchiveTransitionService`.

## Load-time consequence

Because a sheep can be saved *while still archived* (before ever being restored), `birth_game_minute` on disk may not yet reflect any shift. `FlockPersistence` accounts for this directly: if a loaded sheep's location is `BARN_ARCHIVE` and it has a valid `archived_at_game_minute`, age is derived against `min(current_game_minute, archived_at_game_minute)` instead of the save's live current time, so a sheep that has been sitting in the barn for months of game time still loads at the age it had the moment it was archived.
