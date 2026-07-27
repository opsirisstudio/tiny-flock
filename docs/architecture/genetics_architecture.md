# Genetics architecture

## Genotype is authoritative

`SheepGenome` is a Godot `Resource` whose `loci` dictionary maps a locus ID to exactly two locus-scoped allele strings. This compact representation is serializable, iterable, and allows breeding and validation to remain generic. Adding a locus requires registry metadata, a default/founder value, and (only if visible) its phenotype rule—not edits throughout inheritance. Allele ordering is normalized for order-independent lookup; parental origin is not persisted in this first version.

`GeneRegistry` centralizes all legal loci, alleles, display labels, inheritance styles, and categories. `SheepGenome.set_pair()` rejects illegal input, while `validate()` checks both pair legality and genome completeness. Assertions intentionally fail loudly in development rather than creating malformed sheep.

## Breeding and mutation

`BreedingEngine` validates both genomes, iterates the registry, picks one allele from each parent with an injectable seeded RNG, normalizes each pair, and validates the complete lamb genome. `MutationManager` then runs as an explicit second stage. Mutation is disabled by default when constructing the engine, and its named `DEFAULT_LAMB_MUTATION_CHANCE` is 0.005 per lamb—not per locus. A successful event selects one of LAV, ROS, or STR and changes one allele to that locus's rare allele. This conservative stub introduces a heritable allele without guaranteeing immediate recessive expression.

## Phenotype and visuals

`PhenotypeResolver` is pure and deterministic: a valid genome always creates the same `SheepPhenotype`. Small trait-specific functions handle dominance, dilution interactions, blended traits, and conditional pattern/horn expression. Wool base, tone, graying, and rare modifiers remain separate instead of being flattened into a decorative color name.

Rendering is deliberately downstream and absent from saved genetics. A future visual controller will combine phenotype with age, wool growth, environment, and cosmetics. Improving meshes or shaders therefore cannot rewrite a bloodline.

## Sheep records and ancestry

`SheepRecord` stores a stable ID, non-unique display name, isolated sex and age enums, genome, care placeholders, parent IDs, and generation. Founders have generation 0. Lamb generation is `max(mother, father) + 1`. Parent records are never recursively embedded, keeping saves bounded. Actual genomes are stored on records, but the future player-knowledge model (unknown, suspected, confirmed, genotyped) should expose only learned facts; the Genetics Lab is intentionally omniscient.

## Assumptions

- Sex does not affect inheritance and parent-role compatibility is not enforced in this prototype.
- GRY resolves to `none`, `normal`, or `strong`; age-based shader intensity is deferred.
- ROS follows the requested recessive expression boolean, while its visual color effect remains undefined.
- A mutation changes one inherited allele. It does not force a homozygous rare phenotype.
