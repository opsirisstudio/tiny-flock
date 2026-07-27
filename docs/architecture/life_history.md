# Life history architecture

Each `SheepRecord` owns a flat array of compact `SheepLifeEvent` resources: enum type, integer game-time marker, related sheep IDs, and small metadata. `SheepHistoryService` is the normal append/query API. It stores a deep copy and returns copies, making recorded history append-only to ordinary callers. Pedigrees continue to contain IDs only.

Queries return all, type-filtered, or recent events in append order. Statistics are derived: offspring, breeding count, descendants, and generation depth come from parent IDs; shearing, archive, return, and favorite counts come from events. No duplicate counter is persisted. `FIRST_SHEAR` currently proves only the first occurrence; repeated shearing can add a general event later.

`BreedingHistoryService` derives mates, offspring, offspring with a partner, breeding count, and unique mate count from authoritative ancestry. `BreederNoteService` separately owns mutable notes.

## Authoritative time and Milestone 4 events

`time_marker` now means total elapsed game minutes from the save's simulation epoch, never Unix or wall-clock time. Lifecycle events use the crossed boundary minute even during a large jump. `BREEDING` and `SHEARED` are repeatable; `PREGNANCY_STARTED` and `BIRTH_GIVEN` mark reproductive boundaries. No tick events are recorded.

## Explicit care history (Version 4)

Successful explicit interactions append repeatable `FED`, `PETTED`, `GROOMED`, and `WASHED` events; treat foods also append `TREAT_GIVEN`. Feeding metadata stores compact food/preference flags. The first successful feeding appends `FED` plus the existing one-time `FIRST_FEEDING`; later feeds append only `FED`. Passive need decay creates no event spam. Lifetime feeding, favorite-food, petting, grooming, washing, and treat counts are derived from this history rather than persisted counters.
