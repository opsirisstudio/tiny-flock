# Genetic Knowledge Foundation

Player knowledge is stored independently from the authoritative `SheepGenome`. A `GeneticKnowledgeRecord` identifies one sheep ID and locus ID, with a state of `UNKNOWN`, `SUSPECTED`, `CONFIRMED`, or `GENOTYPED`. Only `GENOTYPED` records may contain a complete validated pair of known alleles; other states intentionally carry no authoritative allele pair.

`FlockRepository` validates that knowledge refers to an existing sheep and registered locus. Updating knowledge never writes to the sheep's actual genome. Explicit knowledge entries are versioned and persisted beside—but not inside—sheep records. An absent valid sheep/locus entry reads as an ephemeral `UNKNOWN` record, while invalid lookup IDs return no record.

No inference engine is included. Future breeding observations can promote knowledge states without changing biological truth, and debug tooling may continue to reveal the actual genome directly.
