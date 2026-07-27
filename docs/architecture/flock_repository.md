# Flock Repository

`FlockRepository` is the authoritative in-memory collection for one save. It indexes persistent `SheepRecord` resources by stable ID, rejects empty/invalid records and duplicate IDs, and exposes `add_sheep`, `has_sheep`, `get_sheep`, `all_sheep`, `sheep_at_location`, and `count`. Historical records are archived rather than deleted.

Age and location are independent. Age is lamb, juvenile, adult, or elder. Location is active flock, active elder, or barn archive. `activate_elder` requires an existing elder and enforces `MAX_ACTIVE_ELDERS = 3` in the domain layer. `archive_sheep` moves any retained record to the archive without destroying identity or ancestry, and the mirror-image `restore_to_flock` returns a currently-archived record (of any age stage) to `ACTIVE_FLOCK`.

These three methods are pure, time-unaware location transitions — exactly the repository's existing invariant-boundary role, nothing more. They do not stamp or shift any timestamp, and calling them directly (as pure repository tests do) does not freeze/unfreeze age, wool, or pregnancy timing. Real gameplay routes archive/restore/elder-activation through `ArchiveTransitionService` instead, which wraps these calls with the time bookkeeping that makes `BARN_ARCHIVE` an actual simulation boundary — see [archive transitions](archive_transitions.md).

## Active simulation boundary

`SheepRecord` is persistent identity and data; it is not a `Node`. A future `SheepCharacter` will be a temporary active-world representation:

```text
SheepRecord
  -> PhenotypeResolver
  -> VisualController
  -> SheepCharacter
```

Archived sheep need no scene instance. When an active character leaves the world, persistent changes will be written back to its record. Reloading an archive record can reproduce phenotype from genome, age, and wool state.

## Identity service ownership

The repository remains the authoritative ID index and owner of location, favorite, elder-capacity, and genetic-knowledge invariants. It deliberately does not resolve personality or become a universal identity manager. `SheepHistoryService`, `BreederNoteService`, `BreedingHistoryService`, and `LifetimeStatisticsService` receive a repository and own their focused append/query operations; personality, bonding, and elder suitability remain pure resolvers. Persistent event/note arrays live on the flat record so archive and save ownership stay straightforward.
