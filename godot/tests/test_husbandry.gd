class_name TestHusbandry
extends RefCounted

static func run() -> void:
	_test_decay_archive_and_large_jump(); _test_feeding_and_history(); _test_interactions_and_personality(); _test_moods_and_buffering(); _test_wool_and_breeding(); _test_v4_round_trip()
static func _repo_with_sheep(id: String = "care-test") -> Array:
	var repository := FlockRepository.new(); var sheep := SheepFactory.founders()[0]; sheep.sheep_id = id; sheep.hunger = 0.5; sheep.cleanliness = 0.2; sheep.happiness = 0.5; sheep.bond = 0.2; assert(repository.add_sheep(sheep)); return [repository, sheep]
static func _test_decay_archive_and_large_jump() -> void:
	var values := _repo_with_sheep(); var repository: FlockRepository = values[0]; var sheep: SheepRecord = values[1]; var clock := GameClock.new(); var coordinator := SimulationCoordinator.new()
	coordinator.advance_simulation(repository, clock, GameTime.MINUTES_PER_HOUR); assert(sheep.hunger < 0.5 and sheep.cleanliness < 0.2 and sheep.happiness != 0.5)
	sheep.location = SheepRecord.Location.BARN_ARCHIVE; var frozen := [sheep.hunger, sheep.cleanliness, sheep.happiness, sheep.bond]; coordinator.advance_simulation(repository, clock, 30 * GameTime.MINUTES_PER_DAY); assert([sheep.hunger, sheep.cleanliness, sheep.happiness, sheep.bond] == frozen)
	sheep.location = SheepRecord.Location.ACTIVE_FLOCK; coordinator.advance_simulation(repository, clock, 30 * GameTime.MINUTES_PER_DAY); assert(sheep.hunger == 0.0 and sheep.cleanliness == 0.0 and sheep.happiness >= 0.0 and sheep.validate())
static func _test_feeding_and_history() -> void:
	var values := _repo_with_sheep("feed-test"); var repository: FlockRepository = values[0]; var sheep: SheepRecord = values[1]; var service := FeedingService.new(repository); var time := GameTime.new(10); var favorite := sheep.personality.favorite_food; var disliked := sheep.personality.disliked_food
	if disliked.is_empty(): disliked = PersonalityConfig.FOODS[0] if favorite != PersonalityConfig.FOODS[0] else PersonalityConfig.FOODS[1]; sheep.personality.disliked_food = disliked
	var neutral := ""
	for food: String in PersonalityConfig.FOODS:
		if food != favorite and food != disliked: neutral = food; break
	var favorite_result := service.feed_sheep(sheep.sheep_id, favorite, time); assert(favorite_result.success and favorite_result.preference_match == "FAVORITE" and sheep.hunger <= 1.0)
	var first_happiness := favorite_result.after_happiness - favorite_result.before_happiness; var first_bond := favorite_result.after_bond - favorite_result.before_bond
	sheep.happiness = 0.5; sheep.bond = 0.2; var neutral_result := service.feed_sheep(sheep.sheep_id, neutral, time); assert(first_happiness > neutral_result.after_happiness - neutral_result.before_happiness and first_bond > neutral_result.after_bond - neutral_result.before_bond)
	assert(service.feed_sheep(sheep.sheep_id, disliked, time).success); var history := SheepHistoryService.new(repository); assert(history.get_events_by_type(sheep.sheep_id, SheepLifeEvent.Type.FIRST_FEEDING).size() == 1 and history.get_events_by_type(sheep.sheep_id, SheepLifeEvent.Type.FED).size() == 3)
	assert(not service.feed_sheep(sheep.sheep_id, "INVALID", time).success); sheep.location = SheepRecord.Location.BARN_ARCHIVE; assert(service.feed_sheep(sheep.sheep_id, favorite, time).reason == CareInteractionResult.Reason.SHEEP_ARCHIVED)
static func _test_interactions_and_personality() -> void:
	var values := _repo_with_sheep("interaction-test"); var repository: FlockRepository = values[0]; var sheep: SheepRecord = values[1]; var time := GameTime.new(); var axes := sheep.personality.temperament
	for axis: String in PersonalityConfig.AXES: axes[axis] = 0.5
	axes.affection = 0.9; var cuddly := PettingService.new(repository).pet_sheep(sheep.sheep_id, time); assert("CUDDLY" in cuddly.personality_modifiers_applied)
	sheep.bond = 0.05; axes.affection = 0.5; axes.boldness = 0.1; var shy_low := PettingService.new(repository).pet_sheep(sheep.sheep_id, time); var low_gain := shy_low.after_bond - shy_low.before_bond
	sheep.bond = 0.8; var shy_high := PettingService.new(repository).pet_sheep(sheep.sheep_id, time); assert(shy_high.after_bond - shy_high.before_bond > low_gain)
	var groom := GroomingService.new(repository).groom_sheep(sheep.sheep_id, time); assert(groom.after_cleanliness > groom.before_cleanliness)
	sheep.cleanliness = 0.0; var wash := WashingService.new(repository).wash_sheep(sheep.sheep_id, time); assert(wash.after_cleanliness >= 0.8 and sheep.validate())
static func _test_moods_and_buffering() -> void:
	var values := _repo_with_sheep("mood-test"); var sheep: SheepRecord = values[1]; sheep.hunger = 0.1; assert(MoodResolver.resolve(sheep) == MoodResolver.Mood.HUNGRY); sheep.hunger = 1.0; sheep.cleanliness = 0.1; assert(MoodResolver.resolve(sheep) == MoodResolver.Mood.DIRTY)
	sheep.cleanliness = 1.0; sheep.happiness = 0.9; sheep.bond = 0.9; assert(MoodResolver.resolve(sheep) == MoodResolver.Mood.JOYFUL)
	var before := sheep.happiness; sheep.hunger = 0.0; sheep.cleanliness = 0.0; HappinessService.new().advance(sheep, GameTime.MINUTES_PER_HOUR); assert(sheep.happiness < before and sheep.happiness > HappinessService.new().get_care_target(sheep))
static func _test_wool_and_breeding() -> void:
	var values := _repo_with_sheep("gate-test"); var repository: FlockRepository = values[0]; var sheep: SheepRecord = values[1]; var wool := WoolGrowthService.new(); sheep.hunger = 1.0; sheep.cleanliness = 1.0; sheep.happiness = 1.0; assert(is_equal_approx(wool.get_wool_growth_efficiency(sheep), 1.0)); sheep.hunger = 0.0; sheep.cleanliness = 0.0; sheep.happiness = 0.0; assert(is_equal_approx(wool.get_wool_growth_efficiency(sheep), HusbandryConfig.WOOL_CARE_MIN_MULTIPLIER))
	var eligibility := BreedingEligibilityService.new(repository); assert(eligibility.get_individual_reason(sheep, GameTime.new()) == BreedingEligibilityService.Reason.TOO_HUNGRY); sheep.hunger = 1.0; assert(eligibility.get_individual_reason(sheep, GameTime.new()) == BreedingEligibilityService.Reason.TOO_UNHAPPY); sheep.happiness = 1.0; assert(eligibility.get_individual_reason(sheep, GameTime.new()) == BreedingEligibilityService.Reason.SUCCESS)
static func _test_v4_round_trip() -> void:
	var values := _repo_with_sheep("round-trip-care"); var repository: FlockRepository = values[0]; var sheep: SheepRecord = values[1]; sheep.hunger = 0.23; sheep.cleanliness = 0.34; sheep.happiness = 0.45; sheep.bond = 0.56; var mood := MoodResolver.resolve(sheep); var efficiency := WoolGrowthService.new().get_wool_growth_efficiency(sheep); var restored := FlockPersistence.from_json(FlockPersistence.to_json(repository, GameClock.new())); assert(restored != null); var copy := restored.get_sheep(sheep.sheep_id); assert(copy.hunger == sheep.hunger and copy.cleanliness == sheep.cleanliness and copy.happiness == sheep.happiness and copy.bond == sheep.bond); assert(MoodResolver.resolve(copy) == mood and is_equal_approx(WoolGrowthService.new().get_wool_growth_efficiency(copy), efficiency))
