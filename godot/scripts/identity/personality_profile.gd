class_name PersonalityProfile
extends Resource

@export var temperament: Dictionary = {}
@export var favorite_food := ""
@export var disliked_food := ""
@export var source := ""
@export var seed := 0

func validate() -> bool:
	if temperament.size() != PersonalityConfig.AXES.size(): return false
	for axis: String in PersonalityConfig.AXES:
		if not temperament.has(axis) or float(temperament[axis]) < 0.0 or float(temperament[axis]) > 1.0: return false
	return favorite_food in PersonalityConfig.FOODS and (disliked_food.is_empty() or (disliked_food in PersonalityConfig.FOODS and disliked_food != favorite_food))

func traits() -> Array[String]:
	return PersonalityResolver.resolve(temperament)

func to_dictionary() -> Dictionary:
	return {"temperament":temperament.duplicate(true), "favorite_food":favorite_food, "disliked_food":disliked_food, "source":source, "seed":seed}

static func from_dictionary(data: Dictionary) -> PersonalityProfile:
	var profile := PersonalityProfile.new()
	profile.temperament = (data.get("temperament", {}) as Dictionary).duplicate(true)
	profile.favorite_food = str(data.get("favorite_food", "")); profile.disliked_food = str(data.get("disliked_food", ""))
	profile.source = str(data.get("source", "")); profile.seed = int(data.get("seed", 0))
	return profile if profile.validate() else null
