class_name TestPersistence
extends RefCounted

static func run() -> void:
	var repository := FlockRepository.new()
	var founders := SheepFactory.founders()
	for founder: SheepRecord in founders: assert(repository.add_sheep(founder))
	var engine := BreedingEngine.new(77, false)
	var lambs: Array[SheepRecord] = []
	for index: int in 3:
		var lamb := SheepFactory.create_lamb(founders[0], founders[1], engine, "Roundtrip %d" % index)
		lamb.sheep_id = "roundtrip-%d" % index; lambs.append(lamb); assert(repository.add_sheep(lamb))
	lambs[0].age_stage = SheepRecord.AgeStage.ELDER; lambs[0].elder_role = SheepRecord.ElderRole.NANNY
	assert(repository.activate_elder(lambs[0].sheep_id)); assert(repository.archive_sheep(lambs[0].sheep_id))
	lambs[1].favorite = true; lambs[1].add_legacy_tag(SheepRecord.LegacyTag.NOTABLE_BREEDER)
	var knowledge := GeneticKnowledgeRecord.new(); knowledge.sheep_id = lambs[1].sheep_id; knowledge.locus_id = "PNT"; knowledge.knowledge_state = GeneticKnowledgeRecord.State.GENOTYPED; knowledge.known_alleles = lambs[1].genome.get_pair("PNT")
	assert(repository.set_knowledge(knowledge))
	var before_phenotype := PhenotypeResolver.resolve(lambs[0].genome).to_text()
	var loaded := FlockPersistence.from_json(FlockPersistence.to_json(repository))
	assert(loaded != null and loaded.count() == repository.count())
	for original: SheepRecord in repository.all_sheep():
		var restored := loaded.get_sheep(original.sheep_id)
		assert(restored != null and restored != original and not is_same(restored.genome, original.genome))
		assert(restored.genome.loci == original.genome.loci and restored.mother_id == original.mother_id and restored.father_id == original.father_id)
		assert(restored.generation == original.generation and restored.age_stage == original.age_stage and restored.location == original.location)
		assert(restored.elder_role == original.elder_role and restored.favorite == original.favorite and restored.legacy_tags == original.legacy_tags)
	assert(PhenotypeResolver.resolve(loaded.get_sheep(lambs[0].sheep_id).genome).to_text() == before_phenotype)
	var restored_knowledge := loaded.get_knowledge(lambs[1].sheep_id, "PNT")
	assert(restored_knowledge.knowledge_state == GeneticKnowledgeRecord.State.GENOTYPED and restored_knowledge.known_alleles == knowledge.known_alleles)
	assert(FlockPersistence.from_dictionary({"save_version":999, "sheep":[], "genetic_knowledge":[]}) == null)
