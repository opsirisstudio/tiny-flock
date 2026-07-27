class_name FlockRepository
extends RefCounted

const MAX_ACTIVE_ELDERS := 3

var _sheep_by_id: Dictionary = {}
var _knowledge_by_key: Dictionary = {}
var last_error := ""

func add_sheep(sheep: SheepRecord) -> bool:
	last_error = ""
	if sheep == null or not sheep.validate(): return _fail("Cannot add an invalid sheep record.")
	if _sheep_by_id.has(sheep.sheep_id): return _fail("Duplicate sheep ID: %s" % sheep.sheep_id)
	if sheep.location == SheepRecord.Location.ACTIVE_ELDER:
		if sheep.age_stage != SheepRecord.AgeStage.ELDER: return _fail("Only elders may have ACTIVE_ELDER location.")
		if active_elder_count() >= MAX_ACTIVE_ELDERS: return _fail("The active elder limit is %d." % MAX_ACTIVE_ELDERS)
	_sheep_by_id[sheep.sheep_id] = sheep
	return true

func has_sheep(sheep_id: String) -> bool:
	return _sheep_by_id.has(sheep_id)

func get_sheep(sheep_id: String) -> SheepRecord:
	return _sheep_by_id.get(sheep_id) as SheepRecord

func all_sheep() -> Array[SheepRecord]:
	var result: Array[SheepRecord] = []
	for sheep: SheepRecord in _sheep_by_id.values(): result.append(sheep)
	result.sort_custom(func(a: SheepRecord, b: SheepRecord) -> bool: return a.sheep_id < b.sheep_id)
	return result

func sheep_at_location(location: SheepRecord.Location) -> Array[SheepRecord]:
	var result: Array[SheepRecord] = []
	for sheep: SheepRecord in all_sheep():
		if sheep.location == location: result.append(sheep)
	return result

func count() -> int:
	return _sheep_by_id.size()

func active_elder_count() -> int:
	return sheep_at_location(SheepRecord.Location.ACTIVE_ELDER).size()

func activate_elder(sheep_id: String) -> bool:
	last_error = ""
	var sheep := get_sheep(sheep_id)
	if sheep == null: return _fail("Unknown sheep ID: %s" % sheep_id)
	if sheep.age_stage != SheepRecord.AgeStage.ELDER: return _fail("Only an elder can enter the active elder meadow.")
	if sheep.location == SheepRecord.Location.ACTIVE_ELDER: return true
	if active_elder_count() >= MAX_ACTIVE_ELDERS: return _fail("The active elder limit is %d." % MAX_ACTIVE_ELDERS)
	sheep.location = SheepRecord.Location.ACTIVE_ELDER
	return true

func archive_sheep(sheep_id: String) -> bool:
	last_error = ""
	var sheep := get_sheep(sheep_id)
	if sheep == null: return _fail("Unknown sheep ID: %s" % sheep_id)
	sheep.location = SheepRecord.Location.BARN_ARCHIVE
	return true

func set_favorite(sheep_id: String, favorite: bool) -> bool:
	var sheep := get_sheep(sheep_id)
	if sheep == null: return _fail("Unknown sheep ID: %s" % sheep_id)
	sheep.favorite = favorite
	return true

func set_knowledge(record: GeneticKnowledgeRecord) -> bool:
	last_error = ""
	if record == null or not record.validate(): return _fail("Invalid genetic knowledge record.")
	if not has_sheep(record.sheep_id): return _fail("Knowledge references an unknown sheep ID.")
	_knowledge_by_key[_knowledge_key(record.sheep_id, record.locus_id)] = record
	return true

func get_knowledge(sheep_id: String, locus_id: String) -> GeneticKnowledgeRecord:
	if not has_sheep(sheep_id) or not GeneRegistry.LOCI.has(locus_id):
		last_error = "Knowledge lookup requires a valid sheep ID and locus."
		return null
	var key := _knowledge_key(sheep_id, locus_id)
	if _knowledge_by_key.has(key): return _knowledge_by_key[key] as GeneticKnowledgeRecord
	var unknown := GeneticKnowledgeRecord.new(); unknown.sheep_id = sheep_id; unknown.locus_id = locus_id
	return unknown

func all_knowledge() -> Array[GeneticKnowledgeRecord]:
	var result: Array[GeneticKnowledgeRecord] = []
	for record: GeneticKnowledgeRecord in _knowledge_by_key.values(): result.append(record)
	result.sort_custom(func(a: GeneticKnowledgeRecord, b: GeneticKnowledgeRecord) -> bool: return _knowledge_key(a.sheep_id, a.locus_id) < _knowledge_key(b.sheep_id, b.locus_id))
	return result

func _knowledge_key(sheep_id: String, locus_id: String) -> String:
	return "%s|%s" % [sheep_id, locus_id]

func _fail(message: String) -> bool:
	last_error = message
	push_error(message)
	return false
