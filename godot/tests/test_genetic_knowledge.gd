class_name TestGeneticKnowledge
extends RefCounted

static func run() -> void:
	var repository := FlockRepository.new(); var sheep := SheepFactory.founders()[0]; assert(repository.add_sheep(sheep))
	var original := sheep.genome.loci.duplicate(true)
	var unknown := repository.get_knowledge(sheep.sheep_id, "PNT")
	assert(unknown.knowledge_state == GeneticKnowledgeRecord.State.UNKNOWN)
	assert(repository.set_knowledge(unknown))
	var confirmed := GeneticKnowledgeRecord.new(); confirmed.sheep_id = sheep.sheep_id; confirmed.locus_id = "PDL"; confirmed.knowledge_state = GeneticKnowledgeRecord.State.CONFIRMED
	assert(repository.set_knowledge(confirmed))
	var genotyped := GeneticKnowledgeRecord.new(); genotyped.sheep_id = sheep.sheep_id; genotyped.locus_id = "PNT"; genotyped.knowledge_state = GeneticKnowledgeRecord.State.GENOTYPED; genotyped.known_alleles = ["B","b"]
	assert(repository.set_knowledge(genotyped) and sheep.genome.loci == original)
	var malformed := GeneticKnowledgeRecord.new(); malformed.sheep_id = "missing"; malformed.locus_id = "NOPE"; malformed.knowledge_state = GeneticKnowledgeRecord.State.GENOTYPED; malformed.known_alleles = ["x","x"]
	assert(not repository.set_knowledge(malformed))
	var loaded := FlockPersistence.from_json(FlockPersistence.to_json(repository))
	assert(loaded.get_knowledge(sheep.sheep_id, "WBC").knowledge_state == GeneticKnowledgeRecord.State.UNKNOWN)
	assert(loaded.get_knowledge(sheep.sheep_id, "PDL").knowledge_state == GeneticKnowledgeRecord.State.CONFIRMED)
	assert(loaded.get_knowledge(sheep.sheep_id, "PNT").known_alleles == ["B","b"])
