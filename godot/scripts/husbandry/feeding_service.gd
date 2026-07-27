class_name FeedingService
extends CareServiceBase

func feed_sheep(sheep_id: String, food_id: String, game_time: GameTime) -> CareInteractionResult:
	var result := begin(sheep_id, "FEED")
	if result.reason in [CareInteractionResult.Reason.SHEEP_NOT_FOUND, CareInteractionResult.Reason.SHEEP_ARCHIVED]: return result
	var food := FoodRegistry.get_food(food_id)
	if food == null: result.reason = CareInteractionResult.Reason.INVALID_FOOD; return result
	var sheep := repository.get_sheep(sheep_id); var traits := sheep.personality.traits() if sheep.personality != null else []
	var happiness_gain := food.happiness_effect; var bond_gain := HusbandryConfig.BASE_FEED_BOND_GAIN
	if sheep.personality != null and food_id == sheep.personality.favorite_food:
		result.preference_match = "FAVORITE"; happiness_gain += HusbandryConfig.FAVORITE_HAPPINESS_BONUS; bond_gain += HusbandryConfig.FAVORITE_BOND_BONUS
	elif sheep.personality != null and food_id == sheep.personality.disliked_food:
		result.preference_match = "DISLIKED"; happiness_gain += HusbandryConfig.DISLIKED_HAPPINESS_MODIFIER
	elif "CURIOUS" in traits:
		happiness_gain += HusbandryConfig.CURIOUS_NOVEL_FOOD_BONUS; result.personality_modifiers_applied.append("CURIOUS")
	if "GREEDY" in traits:
		happiness_gain *= HusbandryConfig.GREEDY_HAPPINESS_MULTIPLIER; result.personality_modifiers_applied.append("GREEDY")
	sheep.hunger = clampf(sheep.hunger + food.hunger_restoration, 0.0, 1.0)
	sheep.happiness = clampf(sheep.happiness + happiness_gain, 0.0, 1.0)
	sheep.bond = clampf(sheep.bond + apply_life_stage_bond(sheep, bond_gain), 0.0, 1.0)
	var metadata := {"food_id":food_id, "favorite_match":result.preference_match == "FAVORITE", "disliked_match":result.preference_match == "DISLIKED", "treat":food.is_treat}
	record(sheep_id, SheepLifeEvent.Type.FED, game_time, metadata)
	if food.is_treat: record(sheep_id, SheepLifeEvent.Type.TREAT_GIVEN, game_time, {"food_id":food_id})
	if history.get_events_by_type(sheep_id, SheepLifeEvent.Type.FIRST_FEEDING).is_empty(): record(sheep_id, SheepLifeEvent.Type.FIRST_FEEDING, game_time, {"food_id":food_id})
	result.complete(sheep); return result
