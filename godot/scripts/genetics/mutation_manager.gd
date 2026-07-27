class_name MutationManager
extends RefCounted

const DEFAULT_LAMB_MUTATION_CHANCE := 0.005
const MUTABLE_LOCI: Array[String] = ["LAV", "ROS", "STR"]

var enabled := true
var mutation_chance := DEFAULT_LAMB_MUTATION_CHANCE

func apply_possible_mutation(genome: SheepGenome, rng: RandomNumberGenerator) -> MutationResult:
	var result := MutationResult.new()
	if not enabled or mutation_chance <= 0.0 or rng.randf() >= mutation_chance:
		return result
	var locus := MUTABLE_LOCI[rng.randi_range(0, MUTABLE_LOCI.size() - 1)]
	var pair := genome.get_pair(locus)
	result.previous_alleles = pair.duplicate(); result.locus_id = locus
	var mutant := {"LAV":"l", "ROS":"r", "STR":"s"}[locus]
	pair[rng.randi_range(0, 1)] = mutant
	genome.set_pair(locus, pair)
	result.resulting_alleles = genome.get_pair(locus); result.did_mutate = result.previous_alleles != result.resulting_alleles
	return result
