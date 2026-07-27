# Elder and Archive Foundation

Sheep never die.

## Active elders

A save may have at most **3** active elders. An active elder is represented by two independent fields: `age_stage = ELDER` and `location = ACTIVE_ELDER`. Enforcement belongs to `FlockRepository`, not only to UI.

Persistent elder roles are:

- None
- Nanny
- Comforter
- Groomer
- Shepherd
- Forager
- Storykeeper

Roles have no behavior in this milestone. Future active elders may use role and personality to provide ambient interactions with lambs and flock members.

## Barn Archive

The Barn Archive is a historical catalog of retained `SheepRecord` data, not a physical simulation populated by Nodes. Archived sheep retain identity, genome, ancestry, generation, age, husbandry values, favorite state, legacy tags, and elder role. They remain permanently retrievable and can later be regenerated through phenotype and visual controllers.
