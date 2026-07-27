# Persistence

Tiny Flock uses human-readable JSON for the persistent flock prototype. `FlockPersistence.SAVE_VERSION` is currently `1`. The root object contains `save_version`, a `sheep` array, and a separate `genetic_knowledge` array. Unsupported or malformed versions fail clearly and return no partial repository.

Each sheep entry stores identity, name, sex, parent IDs, generation, age, location, elder role, favorite status, legacy tags, husbandry values, and a complete locus-to-pair genotype dictionary. Scenes and Nodes are never serialized. JSON numeric values are explicitly converted back into typed enum/integer/float fields.

A load builds new `SheepRecord`, `SheepGenome`, pair Array, and knowledge resources, validates every genome, and inserts through duplicate-ID checks. This guarantees that restored sheep do not share mutable genome state with pre-save objects. Deterministic round-trip tests compare all identity/ancestry/metadata fields and complete genomes, then compare phenotype text before archive and after load.

The version field is a migration hook, not a migration framework. Future versions should add an explicit version-to-version transform rather than silently accepting unfamiliar data.
