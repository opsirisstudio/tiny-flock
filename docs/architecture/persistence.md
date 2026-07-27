# Persistence

Tiny Flock uses human-readable JSON for the persistent flock prototype. `FlockPersistence.SAVE_VERSION` is currently `2`. The root object contains `save_version`, a `sheep` array, and a separate `genetic_knowledge` array. Unsupported or malformed versions fail clearly and return no partial repository.

Each sheep entry stores identity, name, sex, parent IDs, generation, age, location, elder role, favorite status, legacy tags, husbandry values, and a complete locus-to-pair genotype dictionary. Scenes and Nodes are never serialized. JSON numeric values are explicitly converted back into typed enum/integer/float fields.

A load builds new `SheepRecord`, `SheepGenome`, pair Array, and knowledge resources, validates every genome, and inserts through duplicate-ID checks. This guarantees that restored sheep do not share mutable genome state with pre-save objects. Deterministic round-trip tests compare all identity/ancestry/metadata fields and complete genomes, then compare phenotype text before archive and after load.

Version 1 contained genome, flock/archive metadata, ancestry, and genetic knowledge. Version 2 adds personality/preferences, life events, breeder notes, and supporting identity metadata. Version 1 and all other unsupported versions are explicitly rejected; migration is deferred because there are no production saves and runtime validation is unavailable. They are never silently interpreted as version 2.
