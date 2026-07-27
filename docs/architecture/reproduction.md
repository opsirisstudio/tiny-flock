# Reproduction

`BreedingEligibilityService` requires two distinct repository records: valid `ADULT` sheep in `ACTIVE_FLOCK`, one female and one male, neither pregnant nor before its absolute breeding-availability minute. Lambs, juveniles, elders, active elders, and archived sheep are rejected. Relatedness is informational and does not block conception.

`BreedingService` selects the female, stores a focused `PregnancyState`, and records repeatable `BREEDING`, one-time `FIRST_BREEDING`, and `PREGNANCY_STARTED`. Gestation is three prototype days. Offspring are not generated at conception.

The pregnancy persists partner, conception/due minutes, and a litter seed. At or after due time, `PregnancyService` initializes local seeded RNG, selects a weighted litter, and gives each lamb its own derived seed. `SheepFactory` delegates genomes to `BreedingEngine` (including its mutation stage) and personalities/preferences to `PersonalityGenerator`. Sex is a seeded 50/50 choice unrelated to genetics. Birth IDs derive from mother, due minute, pregnancy seed, and litter index, making a birth retry and test fixture stable. Successful insertion precedes pregnancy clearing; each lamb receives ancestry, generation, `LAMB`, the resolution minute as birth marker, and `BORN`, while both parents receive `OFFSPRING_BORN` and the mother receives `BIRTH_GIVEN`.

The female's two-day postpartum cooldown begins at birth and is stored as an absolute `breeding_available_game_minute`. Males have no prototype cooldown. Saving and loading cannot alter litter count, sex, genome/mutation, personality, preferences, or IDs because the pregnancy seed—not process RNG state—is authoritative.
