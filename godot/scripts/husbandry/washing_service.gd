class_name WashingService
extends CareServiceBase

func wash_sheep(sheep_id: String, game_time: GameTime) -> CareInteractionResult:
	var result := begin(sheep_id, "WASH")
	if result.reason != CareInteractionResult.Reason.INVALID_STATE: return result
	var sheep := repository.get_sheep(sheep_id); var traits := sheep.personality.traits() if sheep.personality != null else []
	var happiness_change := HusbandryConfig.WASH_HAPPINESS_MODIFIER
	if "CALM" in traits: happiness_change += 0.02; result.personality_modifiers_applied.append("CALM")
	if "CUDDLY" in traits: happiness_change += 0.01; result.personality_modifiers_applied.append("CUDDLY")
	if "SHY" in traits: happiness_change -= 0.03; result.personality_modifiers_applied.append("SHY")
	sheep.cleanliness = clampf(sheep.cleanliness + HusbandryConfig.WASH_CLEANLINESS_GAIN, 0.0, 1.0); sheep.happiness = clampf(sheep.happiness + happiness_change, 0.0, 1.0); sheep.bond = clampf(sheep.bond + apply_life_stage_bond(sheep, HusbandryConfig.WASH_BOND_GAIN), 0.0, 1.0)
	record(sheep_id, SheepLifeEvent.Type.WASHED, game_time); result.complete(sheep); return result
