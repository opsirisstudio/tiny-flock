# Milestone 3 Static Verification

- **Date:** 2026-07-27
- **Status:** **STATICALLY VERIFIED**
- **Runtime status:** **RUNTIME VERIFICATION DEFERRED**

## Scope and systems reviewed

Reviewed all identity resources/services, SheepRecord and factory integration, mutation result plumbing, version 2 persistence, Identity Lab scene/script, deterministic GDScript tests, documentation, and static tooling. Added persistent temperament/preferences, derived traits/bonding/elder affinity, append-only life events, derived statistics and breeding history, stable breeder notes, and mutation-founder provenance without changing any genome locus or inheritance rule.

## Static tests reviewed

The prepared runtime suite covers same-input trait determinism, founder seeds, bounded offspring/sibling variation, preference exclusion, role ranking, immutable append/query order, pedigree-derived breeding queries, mutation founders versus inherited alleles, note lifecycle, complete version 2 round trips, and explicit unsupported-version rejection.

## Defects found and fixed

- Mutation previously returned only a genome, so provenance could not distinguish a new allele from inheritance. `MutationResult` now reports locus and before/after pairs.
- Persistence had no identity boundary. Version 2 now requires personality and serializes events and notes; version 1 fails explicitly.
- History callers could otherwise retain and mutate the same event resource. The service stores and returns copies.
- Static tooling previously did not enforce identity enums, the new debug scene, documentation links, or the save constant.

## Verification and risks

Static verification checks unique `class_name` declarations, paths, scene handlers/nodes, documentation links, required loci/traits/events/elder roles, save version consistency, Python syntax, and whitespace. Godot is unavailable, so parser acceptance, typed arrays/enums, JSON runtime conversions, scene instantiation, and all GDScript execution remain deferred. The first-shear event cannot represent arbitrary repeated shears yet, mutation-founder lineage uniqueness is event-local rather than a global allele-lineage registry, and integer time-marker semantics await a game clock.
