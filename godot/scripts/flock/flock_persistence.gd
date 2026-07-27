class_name FlockPersistence
extends RefCounted

const SAVE_VERSION := 5
static var last_error := ""
static var last_loaded_clock: GameClock

static func to_dictionary(repository: FlockRepository, clock: GameClock) -> Dictionary:
	last_error = ""
	if clock == null:
		last_error = "Version 5 serialization requires an authoritative GameClock."
		push_error(last_error)
		return {}
	var sheep_data: Array[Dictionary] = []
	for sheep: SheepRecord in repository.all_sheep(): sheep_data.append(_sheep_to_dictionary(sheep))
	var knowledge_data: Array[Dictionary] = []
	for record: GeneticKnowledgeRecord in repository.all_knowledge(): knowledge_data.append(record.to_dictionary())
	return {"save_version": SAVE_VERSION, "current_game_minute":clock.get_total_minutes(), "sheep": sheep_data, "genetic_knowledge": knowledge_data}

static func to_json(repository: FlockRepository, clock: GameClock) -> String:
	var data := to_dictionary(repository, clock)
	return "" if data.is_empty() else JSON.stringify(data, "  ", true)

static func save_to_file(repository: FlockRepository, path: String, clock: GameClock) -> bool:
	last_error = ""
	if clock == null:
		last_error = "Version 5 serialization requires an authoritative GameClock."; push_error(last_error); return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		last_error = "Unable to open save path: %s" % path; push_error(last_error); return false
	file.store_string(to_json(repository, clock))
	return true

static func load_from_file(path: String) -> FlockRepository:
	last_error = ""
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		last_error = "Unable to open save path: %s" % path; push_error(last_error); return null
	return from_json(file.get_as_text())

static func from_json(json_text: String) -> FlockRepository:
	last_error = ""
	var parsed: Variant = JSON.parse_string(json_text)
	if not parsed is Dictionary:
		last_error = "Save data is not a JSON object."; push_error(last_error); return null
	return from_dictionary(parsed)

static func from_dictionary(data: Dictionary) -> FlockRepository:
	last_error = ""
	if int(data.get("save_version", -1)) != SAVE_VERSION:
		last_error = "Unsupported save version: %s" % data.get("save_version", "missing"); push_error(last_error); return null
	var current_game_minute := int(data.get("current_game_minute", -1))
	if current_game_minute < 0:
		last_error = "Save is missing valid current_game_minute."; push_error(last_error); return null
	last_loaded_clock = GameClock.new(current_game_minute)
	var repository := FlockRepository.new()
	var sheep_entries: Variant = data.get("sheep", null)
	var knowledge_entries: Variant = data.get("genetic_knowledge", null)
	if not sheep_entries is Array or not knowledge_entries is Array:
		last_error = "Save is missing sheep or genetic_knowledge arrays."; push_error(last_error); return null
	for entry: Variant in sheep_entries:
		if not entry is Dictionary:
			last_error = "Malformed sheep entry."; push_error(last_error); return null
		var sheep := _sheep_from_dictionary(entry, last_loaded_clock.get_current_time())
		if sheep == null or not repository.add_sheep(sheep):
			last_error = "Invalid or duplicate sheep in save."; return null
	for sheep: SheepRecord in repository.all_sheep():
		if sheep.pregnancy != null:
			var partner := repository.get_sheep(sheep.pregnancy.other_parent_id)
			if partner == null or partner.sheep_id == sheep.sheep_id or not partner.validate():
				last_error = "Invalid pregnancy partner reference for sheep %s." % sheep.sheep_id; push_error(last_error); return null
	for entry: Variant in knowledge_entries:
		if not entry is Dictionary:
			last_error = "Malformed knowledge entry."; push_error(last_error); return null
		if not repository.set_knowledge(GeneticKnowledgeRecord.from_dictionary(entry)):
			last_error = "Invalid genetic knowledge in save."; return null
	return repository

static func _sheep_to_dictionary(sheep: SheepRecord) -> Dictionary:
	var tags: Array[int] = []
	for tag: SheepRecord.LegacyTag in sheep.legacy_tags: tags.append(tag)
	var events: Array[Dictionary] = []
	for event: SheepLifeEvent in sheep.life_events: events.append(event.to_dictionary())
	var notes: Array[Dictionary] = []
	for note: BreederNote in sheep.breeder_notes: notes.append(note.to_dictionary())
	return {"sheep_id":sheep.sheep_id, "sheep_name":sheep.sheep_name, "sex":sheep.sex, "mother_id":sheep.mother_id, "father_id":sheep.father_id, "generation":sheep.generation, "birth_game_minute":sheep.birth_game_minute, "age_stage":sheep.age_stage, "location":sheep.location, "elder_role":sheep.elder_role, "favorite":sheep.favorite, "legacy_tags":tags, "hunger":sheep.hunger, "cleanliness":sheep.cleanliness, "happiness":sheep.happiness, "bond":sheep.bond, "wool_growth":sheep.wool_growth, "pregnancy":sheep.pregnancy.to_dictionary() if sheep.pregnancy != null else {}, "breeding_available_game_minute":sheep.breeding_available_game_minute, "archived_at_game_minute":sheep.archived_at_game_minute, "genome":sheep.genome.loci.duplicate(true), "personality":sheep.personality.to_dictionary() if sheep.personality != null else {}, "life_events":events, "breeder_notes":notes, "next_note_number":sheep.next_note_number}

static func _sheep_from_dictionary(data: Dictionary, current_time: GameTime) -> SheepRecord:
	if not data.get("genome", null) is Dictionary: return null
	var sheep := SheepRecord.new()
	sheep.sheep_id = str(data.get("sheep_id", "")); sheep.sheep_name = str(data.get("sheep_name", ""))
	sheep.sex = int(data.get("sex", 0)) as SheepRecord.Sex
	sheep.mother_id = str(data.get("mother_id", "")); sheep.father_id = str(data.get("father_id", "")); sheep.generation = int(data.get("generation", -1))
	if not data.has("birth_game_minute") or not data.has("breeding_available_game_minute") or not data.has("archived_at_game_minute"): return null
	sheep.birth_game_minute = int(data["birth_game_minute"]); sheep.breeding_available_game_minute = int(data["breeding_available_game_minute"]); sheep.archived_at_game_minute = int(data["archived_at_game_minute"])
	if sheep.birth_game_minute > current_time.total_minutes: return null
	sheep.location = int(data.get("location", SheepRecord.Location.ACTIVE_FLOCK)) as SheepRecord.Location
	var age_reference_time := current_time
	if sheep.location == SheepRecord.Location.BARN_ARCHIVE and sheep.archived_at_game_minute >= 0:
		age_reference_time = GameTime.new(mini(current_time.total_minutes, sheep.archived_at_game_minute))
	sheep.age_stage = LifecycleService.resolve_age_stage(sheep, age_reference_time)
	sheep.elder_role = int(data.get("elder_role", SheepRecord.ElderRole.NONE)) as SheepRecord.ElderRole
	sheep.favorite = bool(data.get("favorite", false))
	var tags: Variant = data.get("legacy_tags", [])
	if not tags is Array: return null
	for tag: Variant in tags: sheep.legacy_tags.append(int(tag) as SheepRecord.LegacyTag)
	if not data.has("hunger") or not data.has("cleanliness") or not data.has("happiness") or not data.has("bond"): return null
	sheep.hunger = float(data["hunger"]); sheep.cleanliness = float(data["cleanliness"]); sheep.happiness = float(data["happiness"]); sheep.bond = float(data["bond"]); sheep.wool_growth = float(data.get("wool_growth", 0.0))
	var pregnancy_data: Variant = data.get("pregnancy", null)
	if not pregnancy_data is Dictionary: return null
	if not pregnancy_data.is_empty():
		sheep.pregnancy = PregnancyState.from_dictionary(pregnancy_data)
		if sheep.pregnancy == null: return null
	var genome_data: Dictionary = data["genome"]
	sheep.genome = SheepGenome.new(genome_data)
	var personality_data: Variant = data.get("personality", {})
	if not personality_data is Dictionary or personality_data.is_empty(): return null
	sheep.personality = PersonalityProfile.from_dictionary(personality_data)
	var events: Variant = data.get("life_events", []); var notes: Variant = data.get("breeder_notes", [])
	if not events is Array or not notes is Array: return null
	for event: Variant in events:
		if not event is Dictionary: return null
		sheep.life_events.append(SheepLifeEvent.from_dictionary(event))
	for note: Variant in notes:
		if not note is Dictionary: return null
		var restored_note := BreederNote.from_dictionary(note)
		if restored_note.note_id.is_empty() or restored_note.text.strip_edges().is_empty(): return null
		sheep.breeder_notes.append(restored_note)
	sheep.next_note_number = int(data.get("next_note_number", 1))
	return sheep if sheep.validate() else null
