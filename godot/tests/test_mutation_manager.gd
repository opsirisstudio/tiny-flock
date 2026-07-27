class_name TestMutationManager
extends RefCounted

static func run() -> void:
	var manager := MutationManager.new()
	var parent := SheepFactory.default_genome()
	var disabled_lamb := parent.duplicate_genome()
	manager.enabled = false; manager.mutation_chance = 1.0
	manager.apply_possible_mutation(disabled_lamb, _rng(9))
	assert(disabled_lamb.loci == parent.loci)
	var zero_lamb := parent.duplicate_genome()
	manager.enabled = true; manager.mutation_chance = 0.0
	manager.apply_possible_mutation(zero_lamb, _rng(9))
	assert(zero_lamb.loci == parent.loci)
	var forced_lamb := parent.duplicate_genome()
	manager.mutation_chance = 1.0
	var result := manager.apply_possible_mutation(forced_lamb, _rng(9))
	var changes := forced_lamb.get_pair("LAV").count("l") + forced_lamb.get_pair("ROS").count("r") + forced_lamb.get_pair("STR").count("s")
	assert(changes == 1 and forced_lamb.validate() and result.did_mutate and not result.locus_id.is_empty())
	assert(parent.get_pair("LAV") == ["L","L"] and parent.get_pair("ROS") == ["R","R"] and parent.get_pair("STR") == ["S","S"])

static func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new(); rng.seed = seed_value; return rng
