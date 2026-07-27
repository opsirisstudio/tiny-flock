class_name BreedingEngine
extends RefCounted

var rng: RandomNumberGenerator
var mutation_manager: MutationManager
var last_mutation_result := MutationResult.new()

func _init(seed_value: int = 0, mutations_enabled: bool = false) -> void:
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	mutation_manager = MutationManager.new()
	mutation_manager.enabled = mutations_enabled

func breed_genomes(mother: SheepGenome, father: SheepGenome) -> SheepGenome:
	assert(mother.validate() and father.validate(), "Both parent genomes must be complete and valid")
	var lamb := SheepGenome.new()
	for locus: String in GeneRegistry.locus_ids():
		var maternal := mother.get_pair(locus)
		var paternal := father.get_pair(locus)
		lamb.set_pair(locus, [maternal[rng.randi_range(0, 1)], paternal[rng.randi_range(0, 1)]])
	assert(lamb.validate(), "Inherited lamb genome is invalid")
	last_mutation_result = mutation_manager.apply_possible_mutation(lamb, rng)
	assert(lamb.validate(), "Mutated lamb genome is invalid")
	return lamb
