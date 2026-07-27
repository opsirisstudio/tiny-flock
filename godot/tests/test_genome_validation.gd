class_name TestGenomeValidation
extends RefCounted

static func run() -> void:
	var genome := SheepFactory.default_genome()
	assert(genome.validate())
	assert(GeneRegistry.is_valid_pair("PNT", ["B", "b"]))
	assert(not GeneRegistry.is_valid_pair("PNT", ["D", "D"]))
	assert(not GeneRegistry.is_valid_pair("UNKNOWN", ["B", "b"]))
	assert(not GeneRegistry.is_valid_pair("PNT", ["B"]))
	assert(not GeneRegistry.is_valid_pair("PNT", ["B", "b", "B"]))
	var partial := SheepGenome.new({"PNT":["B","b"]})
	assert(partial.validate(false) and not partial.validate(true))
	var reversed := SheepGenome.new({"PNT":["b","B"]})
	assert(reversed.get_pair("PNT") == ["B", "b"])
	var copied := genome.duplicate_genome()
	assert(copied != genome and not is_same(copied.loci, genome.loci))
	copied.set_pair("PNT", ["b", "b"])
	assert(genome.get_pair("PNT") == ["B", "B"])
