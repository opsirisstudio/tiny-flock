class_name PersistenceSerializer
extends RefCounted

# Responsibilities:
# - Convert domain objects (SheepRecord, GeneticKnowledgeRecord) to/from Dictionaries
# - Keep serialization logic focused and testable so FlockPersistence can delegate I/O

static func sheep_to_dictionary(sheep: SheepRecord) -> Dictionary:
	var tags: Array[int] = []
	for tag: SheepRecord.LegacyTag in sheep.legacy_tags:
		tags.append(tag)
	var events: Array[Dictionary] = []
	for event: SheepLifeEvent in sheep.life_events:
		events.append(event.to_dictionary())
	var notes: Array[Dictionary] = []
	for note: BreederNote in sheep.breeder_notes:
		notes.append(note.to_dictionary())
	return {
		"sheep_id": sheep.sheep_id,
		"sheep_name": sheep.sheep_name,
		"sex": int(sheep.sex),
		"mother_id": sheep.mother_id,
		"father_id": sheep.father_id,
		"generation": sheep.generation,
		"birth_game_minute": sheep.birth_game_minute,
		"breeding_available_game_minute": sheep.breeding_available_game_minute,
		"location": int(sheep.location),
		"elder_role": int(sheep.elder_role),
		"favorite": sheep.favorite,
		"legacy_tags": tags,
		"hunger": sheep.hunger,
		"cleanliness": sheep.cleanliness,
		"happiness": sheep.happiness,
		"bond": sheep.bond,
		"wool_growth": sheep.wool_growth,
		"pregnancy": (sheep.pregnancy.to_dictionary() if sheep.pregnancy != null else {}),
		"genome": sheep.genome.loci.duplicate(true),
		"personality": sheep.personality.to_dictionary(),
		"life_events": events,
		"breeder_notes": notes,
		"next_note_number": sheep.next_note_number,
	}

static func sheep_from_dictionary(data: Dictionary, current_time: GameTime) -> SheepRecord:
	# This mirrors the existing validation in flock_persistence, but is focused on construction.
	if not data.get("genome", null) is Dictionary:
		return null
	var sheep := SheepRecord.new()
	sheep.sheep_id = str(data.get("sheep_id", ""))
	sheep.sheep_name = str(data.get("sheep_name", ""))
	sheep.sex = int(data.get("sex", 0)) as SheepRecord.Sex
	sheep.mother_id = str(data.get("mother_id", ""))
	sheep.father_id = str(data.get("father_id", ""))
	sheep.generation = int(data.get("generation", -1))
	if not data.has("birth_game_minute") or not data.has("breeding_available_game_minute"):
		return null
	sheep.birth_game_minute = int(data["birth_game_minute"])
	sheep.breeding_available_game_minute = int(data["breeding_available_game_minute"])
	if sheep.birth_game_minute > current_time.total_minutes:
		return null
	sheep.age_stage = LifecycleService.new(FlockRepository.new()).resolve_age_stage(sheep, current_time)
	sheep.location = int(data.get("location", SheepRecord.Location.ACTIVE_FLOCK)) as SheepRecord.Location
	sheep.elder_role = int(data.get("elder_role", SheepRecord.ElderRole.NONE)) as SheepRecord.ElderRole
	sheep.favorite = bool(data.get("favorite", false))
	var tags: Variant = data.get("legacy_tags", [])
	if not tags is Array:
		return null
	for tag: Variant in tags:
		sheep.legacy_tags.append(int(tag) as SheepRecord.LegacyTag)
	if not data.has("hunger") or not data.has("cleanliness") or not data.has("happiness") or not data.has("bond"):
		return null
	sheep.hunger = float(data["hunger"])
	sheep.cleanliness = float(data["cleanliness"])
	sheep.happiness = float(data["happiness"])
	sheep.bond = float(data["bond"])
	sheep.wool_growth = float(data.get("wool_growth", 0.0))
	var pregnancy_data: Variant = data.get("pregnancy", null)
	if not pregnancy_data is Dictionary:
		return null
	if not pregnancy_data.is_empty():
		sheep.pregnancy = PregnancyState.from_dictionary(pregnancy_data)
		if sheep.pregnancy == null:
			return null
	var genome_data: Dictionary = data["genome"]
	sheep.genome = SheepGenome.new(genome_data)
	var personality_data: Variant = data.get("personality", {})
	if not personality_data is Dictionary or personality_data.is_empty():
		return null
	sheep.personality = PersonalityProfile.from_dictionary(personality_data)
	var events: Variant = data.get("life_events", [])
	var notes: Variant = data.get("breeder_notes", [])
	if not events is Array or not notes is Array:
		return null
	for event: Variant in events:
		if not event is Dictionary:
			return null
		sheep.life_events.append(SheepLifeEvent.from_dictionary(event))
	for note: Variant in notes:
		if not note is Dictionary:
			return null
		var restored_note := BreederNote.from_dictionary(note)
		if restored_note.note_id.is_empty() or restored_note.text.strip_edges().is_empty():
			return null
		sheep.breeder_notes.append(restored_note)
	sheep.next_note_number = int(data.get("next_note_number", 1))
	return sheep if sheep.validate() else null
