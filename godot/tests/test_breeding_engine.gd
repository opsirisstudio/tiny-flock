class_name TestBreedingEngine
extends RefCounted

static func run() -> void:
	_test_contribution_and_independence()
	_test_seed_behavior()
	_test_generation()

static func _test_contribution_and_independence() -> void:
	var mother := SheepFactory.default_genome({"PNT":["B","B"], "WBC":["W","W"]})
	var father := SheepFactory.default_genome({"PNT":["b","b"], "WBC":["D","D"]})
	var mother_before := mother.loci.duplicate(true)
	var father_before := father.loci.duplicate(true)
	var child := BreedingEngine.new(42, false).breed_genomes(mother, father)
	assert(child != mother and child != father and not is_same(child.loci, mother.loci) and not is_same(child.loci, father.loci))
	for locus: String in GeneRegistry.locus_ids():
		var pair := child.get_pair(locus)
		var maternal := mother.get_pair(locus)
		var paternal := father.get_pair(locus)
		assert((pair[0] in maternal and pair[1] in paternal) or (pair[1] in maternal and pair[0] in paternal))
	assert(child.get_pair("PNT") == ["B", "b"] and PhenotypeResolver.resolve(child).point_color == "black")
	var swapped := BreedingEngine.new(42, false).breed_genomes(father, mother)
	assert(swapped.get_pair("PNT") == child.get_pair("PNT") and swapped.get_pair("WBC") == child.get_pair("WBC"))
	child.set_pair("PNT", ["b", "b"])
	assert(mother.loci == mother_before and father.loci == father_before)

static func _test_seed_behavior() -> void:
	var mother := SheepFactory.default_genome({"PNT":["B","b"], "WBC":["W","D"], "CRL":["C","c"]})
	var father := SheepFactory.default_genome({"PNT":["B","b"], "WBC":["W","D"], "CRL":["C","c"]})
	var first := BreedingEngine.new(12345, false).breed_genomes(mother, father)
	var repeated := BreedingEngine.new(12345, false).breed_genomes(mother, father)
	assert(first.loci == repeated.loci)
	var alternatives: Array[Dictionary] = []
	for seed_value: int in range(1, 8): alternatives.append(BreedingEngine.new(seed_value, false).breed_genomes(mother, father).loci)
	assert(alternatives.any(func(value: Dictionary) -> bool: return value != alternatives[0]))

static func _test_generation() -> void:
	var mother := SheepRecord.new(); mother.sheep_id = "m"; mother.generation = 2; mother.genome = SheepFactory.default_genome()
	var father := SheepRecord.new(); father.sheep_id = "f"; father.generation = 5; father.genome = SheepFactory.default_genome()
	var lamb := SheepFactory.create_lamb(mother, father, BreedingEngine.new(2, false))
	assert(lamb.generation == 6 and lamb.mother_id == "m" and lamb.father_id == "f")
