class_name TestFlockRepository
extends RefCounted

static func run() -> void:
	var repository := FlockRepository.new()
	for founder: SheepRecord in SheepFactory.founders():
		assert(founder.validate() and founder.generation == 0 and founder.has_legacy_tag(SheepRecord.LegacyTag.FOUNDER))
		assert(repository.add_sheep(founder))
	assert(repository.count() == 4 and not repository.add_sheep(repository.get_sheep("founder-clover")))
	var elders: Array[SheepRecord] = []
	for index: int in 4:
		var elder := _record("elder-%d" % index, SheepRecord.AgeStage.ELDER)
		elders.append(elder); assert(repository.add_sheep(elder))
	assert(repository.activate_elder("elder-0")); assert(repository.activate_elder("elder-1")); assert(repository.activate_elder("elder-2"))
	assert(repository.active_elder_count() == 3 and not repository.activate_elder("elder-3"))
	assert(repository.archive_sheep("elder-1") and repository.has_sheep("elder-1"))
	assert(repository.activate_elder("elder-3"))
	var adult := _record("adult", SheepRecord.AgeStage.ADULT); assert(repository.add_sheep(adult))
	assert(not repository.activate_elder("adult"))
	assert(repository.archive_sheep("elder-0") and repository.activate_elder("elder-0"))

static func _record(id: String, age: SheepRecord.AgeStage) -> SheepRecord:
	var sheep := SheepRecord.new(); sheep.sheep_id = id; sheep.sheep_name = id; sheep.age_stage = age; sheep.genome = SheepFactory.default_genome(); return sheep
