class_name PersonalityGenerator
extends RefCounted

static func generate_founder_personality(rng: RandomNumberGenerator) -> PersonalityProfile:
	var profile := PersonalityProfile.new(); profile.source = "founder"; profile.seed = rng.seed
	for axis: String in PersonalityConfig.AXES: profile.temperament[axis] = rng.randf()
	_assign_preferences(profile, rng); return profile

static func generate_offspring_personality(mother: PersonalityProfile, father: PersonalityProfile, rng: RandomNumberGenerator) -> PersonalityProfile:
	assert(mother.validate() and father.validate(), "Parents require valid personality profiles")
	var profile := PersonalityProfile.new(); profile.source = "offspring"; profile.seed = rng.seed
	for axis: String in PersonalityConfig.AXES:
		var average := (float(mother.temperament[axis]) + float(father.temperament[axis])) / 2.0
		profile.temperament[axis] = clampf(average + rng.randf_range(-PersonalityConfig.PERSONALITY_VARIATION_RANGE, PersonalityConfig.PERSONALITY_VARIATION_RANGE), 0.0, 1.0)
	_assign_preferences(profile, rng); return profile

static func _assign_preferences(profile: PersonalityProfile, rng: RandomNumberGenerator) -> void:
	profile.favorite_food = PersonalityConfig.FOODS[rng.randi_range(0, PersonalityConfig.FOODS.size() - 1)]
	var choices := PersonalityConfig.FOODS.duplicate(); choices.erase(profile.favorite_food)
	if rng.randi_range(0, 1) == 1: profile.disliked_food = choices[rng.randi_range(0, choices.size() - 1)]
