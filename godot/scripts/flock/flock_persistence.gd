class_name FlockPersistence
extends RefCounted

const SAVE_VERSION := 4
static var last_error := ""
static var last_loaded_clock: GameClock

# This module delegates serialization to PersistenceSerializer and
# file I/O to IncrementalFlockSaver. It preserves the public API
# used elsewhere but avoids building large in-memory JSON blobs when
# saving repository files.

static func to_dictionary(repository: FlockRepository, clock: GameClock) -> Dictionary:
	last_error = ""
	if clock == null:
		last_error = "Version %d serialization requires an authoritative GameClock." % SAVE_VERSION
		push_error(last_error)
		return {}
	var sheep_data: Array[Dictionary] = []
	for sheep: SheepRecord in repository.all_sheep():
		sheep_data.append(PersistenceSerializer.sheep_to_dictionary(sheep))
	var knowledge_data: Array[Dictionary] = []
	for record: GeneticKnowledgeRecord in repository.all_knowledge():
		knowledge_data.append(record.to_dictionary())
	return {"save_version": SAVE_VERSION, "current_game_minute": clock.get_total_minutes(), "sheep": sheep_data, "genetic_knowledge": knowledge_data}

static func to_json(repository: FlockRepository, clock: GameClock) -> String:
	# Keep a convenience in-memory JSON exporter for small uses and tests.
	var data := to_dictionary(repository, clock)
	return "" if data.is_empty() else JSON.stringify(data, "  ", true)

static func save_to_file(repository: FlockRepository, path: String, clock: GameClock, async: bool = false) -> bool:
	# Prefer streaming saver for file I/O. Caller can set async=true to run in background.
	last_error = ""
	if clock == null:
		last_error = "Version %d serialization requires an authoritative GameClock." % SAVE_VERSION; push_error(last_error); return false
	if async:
		# Caller must ensure repository is quiescent or accept eventual consistency.
		IncrementalFlockSaver.save_async(repository, path, clock)
		return true
	else:
		return IncrementalFlockSaver.save_streaming(repository, path, clock)

static func load_from_file(path: String) -> FlockRepository:
	last_error = ""
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		last_error = "Unable to open save path: %s" % path; push_error(last_error); return null
	return from_json(file.get_as_text())

static func from_json(json_text: String) -> FlockRepository:
	last_error = ""
	var parsed := JSON.parse_string(json_text)
	if parsed.error != OK:
		last_error = "Save JSON parse error: %s" % str(parsed.error_string); push_error(last_error); return null
	if not parsed.result is Dictionary:
		last_error = "Save data is not a JSON object."; push_error(last_error); return null
	return from_dictionary(parsed.result)

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
	# Reconstruct sheep (use serializer)
	for entry: Variant in sheep_entries:
		if not entry is Dictionary:
			last_error = "Malformed sheep entry."; push_error(last_error); return null
		var sheep := PersistenceSerializer.sheep_from_dictionary(entry, last_loaded_clock.get_current_time())
		if sheep == null or not repository.add_sheep(sheep):
			last_error = "Invalid or duplicate sheep in save."; push_error(last_error); return null
	# Validate pregnancy references
	for sheep: SheepRecord in repository.all_sheep():
		if sheep.pregnancy != null:
			var partner := repository.get_sheep(sheep.pregnancy.other_parent_id)
			if partner == null or partner.sheep_id == sheep.sheep_id or not partner.validate():
				last_error = "Invalid pregnancy partner reference for sheep %s." % sheep.sheep_id; push_error(last_error); return null
	# Load genetic knowledge
	for entry: Variant in knowledge_entries:
		if not entry is Dictionary:
			last_error = "Malformed knowledge entry."; push_error(last_error); return null
		if not repository.set_knowledge(GeneticKnowledgeRecord.from_dictionary(entry)):
			last_error = "Invalid genetic knowledge in save."; push_error(last_error); return null
	return repository

# Backwards compatibility: keep helpers used elsewhere
static func last_loaded_game_clock() -> GameClock:
	return last_loaded_clock

