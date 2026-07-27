# Flock Repository

`FlockRepository` is the authoritative in-memory collection for one save. It indexes persistent `SheepRecord` resources by stable ID, rejects empty/invalid records and duplicate IDs, and exposes `add_sheep`, `has_sheep`, `get_sheep`, `all_sheep`, `sheep_at_location`, and `count`. Historical records are archived rather than deleted.

Age and location are independent. Age is lamb, juvenile, adult, or elder. Location is active flock, active elder, or barn archive. `activate_elder` requires an existing elder and enforces `MAX_ACTIVE_ELDERS = 3` in the domain layer. `archive_sheep` moves any retained record to the archive without destroying identity or ancestry.

## Active simulation boundary

`SheepRecord` is persistent identity and data; it is not a `Node`. A future `SheepCharacter` will be a temporary active-world representation:

```text
SheepRecord
  -> PhenotypeResolver
  -> VisualController
  -> SheepCharacter
```

Archived sheep need no scene instance. When an active character leaves the world, persistent changes will be written back to its record. Reloading an archive record can reproduce phenotype from genome, age, and wool state.
