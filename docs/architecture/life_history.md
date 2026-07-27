# Life history architecture

Each `SheepRecord` owns a flat array of compact `SheepLifeEvent` resources: enum type, integer game-time marker, related sheep IDs, and small metadata. `SheepHistoryService` is the normal append/query API. It stores a deep copy and returns copies, making recorded history append-only to ordinary callers. Pedigrees continue to contain IDs only.

Queries return all, type-filtered, or recent events in append order. Statistics are derived: offspring, breeding count, descendants, and generation depth come from parent IDs; shearing, archive, return, and favorite counts come from events. No duplicate counter is persisted. `FIRST_SHEAR` currently proves only the first occurrence; repeated shearing can add a general event later.

`BreedingHistoryService` derives mates, offspring, offspring with a partner, breeding count, and unique mate count from authoritative ancestry. `BreederNoteService` separately owns mutable notes.
