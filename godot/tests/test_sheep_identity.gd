class_name TestSheepIdentity
extends RefCounted

static func run() -> void:
	_test_personality(); _test_affinities(); _test_history_notes_and_breeding(); _test_mutation_founder()

static func _rng(value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new(); rng.seed = value; return rng

static func _test_personality() -> void:
	var first := PersonalityGenerator.generate_founder_personality(_rng(42)); var repeated := PersonalityGenerator.generate_founder_personality(_rng(42)); var other := PersonalityGenerator.generate_founder_personality(_rng(43))
	assert(first.temperament == repeated.temperament and first.traits() == repeated.traits() and first.temperament != other.temperament)
	assert(first.favorite_food != first.disliked_food)
	var child := PersonalityGenerator.generate_offspring_personality(first, other, _rng(99)); var sibling := PersonalityGenerator.generate_offspring_personality(first, other, _rng(100))
	for axis: String in PersonalityConfig.AXES:
		var average := (float(first.temperament[axis]) + float(other.temperament[axis])) / 2.0
		assert(float(child.temperament[axis]) >= 0.0 and float(child.temperament[axis]) <= 1.0)
		assert(absf(float(child.temperament[axis]) - average) <= PersonalityConfig.PERSONALITY_VARIATION_RANGE + 0.00001)
	assert(child.temperament != sibling.temperament)

static func _profile(values: Dictionary) -> PersonalityProfile:
	var profile := PersonalityProfile.new(); profile.favorite_food = "APPLE"
	for axis: String in PersonalityConfig.AXES: profile.temperament[axis] = float(values.get(axis, 0.5))
	return profile

static func _test_affinities() -> void:
	var nanny := _profile({"affection":1.0, "calmness":1.0, "sociability":1.0, "energy":0.5})
	assert(ElderRoleAffinityResolver.get_best_elder_role(nanny) == SheepRecord.ElderRole.NANNY)
	var forager := _profile({"curiosity":1.0, "energy":1.0, "food_drive":1.0, "affection":0.0, "calmness":0.0, "sociability":0.0})
	assert(ElderRoleAffinityResolver.get_best_elder_role(forager) == SheepRecord.ElderRole.FORAGER)

static func _test_history_notes_and_breeding() -> void:
	var repository := FlockRepository.new(); var mother := SheepFactory.founders()[0]; var father := SheepFactory.founders()[1]
	assert(repository.add_sheep(mother) and repository.add_sheep(father))
	for index: int in 2:
		var child := SheepFactory.create_lamb(mother, father, BreedingEngine.new(index, false), 0); child.sheep_id = "history-child-%d" % index; assert(repository.add_sheep(child))
	var breeding := BreedingHistoryService.new(repository)
	assert(breeding.get_mates(mother.sheep_id).size() == 1 and breeding.get_offspring(mother.sheep_id).size() == 2 and breeding.get_offspring_with_partner(mother.sheep_id, father.sheep_id).size() == 2 and breeding.get_breeding_count(mother.sheep_id) == 2 and breeding.get_unique_mate_count(mother.sheep_id) == 1)
	var history := SheepHistoryService.new(repository); var event := SheepLifeEvent.new(); event.event_type = SheepLifeEvent.Type.FIRST_SHEAR; event.time_marker = 10
	assert(history.record_event(mother.sheep_id, event)); event.time_marker = 99
	assert(history.get_events(mother.sheep_id)[0].time_marker == 10 and history.get_events_by_type(mother.sheep_id, SheepLifeEvent.Type.FIRST_SHEAR).size() == 1)
	var notes := BreederNoteService.new(repository); var id := notes.add_note(mother.sheep_id, "Watch this line", 12)
	assert(not id.is_empty() and notes.list_notes(mother.sheep_id)[0].note_id == id and notes.add_note(mother.sheep_id, "  ", 13).is_empty() and notes.remove_note(mother.sheep_id, id))

static func _test_mutation_founder() -> void:
	var parents := SheepFactory.founders(); var engine := BreedingEngine.new(7, true); engine.mutation_manager.mutation_chance = 1.0
	var mutant := SheepFactory.create_lamb(parents[0], parents[1], engine, 4321); assert(mutant.has_legacy_tag(SheepRecord.LegacyTag.MUTATION_FOUNDER)); assert(mutant.life_events[0].event_type == SheepLifeEvent.Type.MUTATION_DISCOVERED and mutant.life_events[0].time_marker == 4321)
	var inherited := SheepFactory.create_lamb(mutant, parents[1], BreedingEngine.new(8, false), 4321); assert(not inherited.has_legacy_tag(SheepRecord.LegacyTag.MUTATION_FOUNDER) and inherited.life_events.is_empty())
