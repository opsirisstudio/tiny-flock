class_name GroomingService
extends CareServiceBase

func groom_sheep(sheep_id: String, game_time: GameTime) -> CareInteractionResult:
	var result := begin(sheep_id, "GROOM")
	if result.reason != CareInteractionResult.Reason.INVALID_STATE: return result
	var sheep := repository.get_sheep(sheep_id); var traits := sheep.personality.traits() if sheep.personality != null else []
	var happiness_gain := HusbandryConfig.GROOM_HAPPINESS_GAIN; var bond_gain := HusbandryConfig.GROOM_BOND_GAIN
	if "CALM" in traits: happiness_gain *= 1.25; result.personality_modifiers_applied.append("CALM")
	if "CUDDLY" in traits: bond_gain *= 1.20; result.personality_modifiers_applied.append("CUDDLY")
	sheep.cleanliness = clampf(sheep.cleanliness + HusbandryConfig.GROOM_CLEANLINESS_GAIN, 0.0, 1.0); sheep.happiness = clampf(sheep.happiness + happiness_gain, 0.0, 1.0); sheep.bond = clampf(sheep.bond + apply_life_stage_bond(sheep, bond_gain), 0.0, 1.0)
	record(sheep_id, SheepLifeEvent.Type.GROOMED, game_time); result.complete(sheep); return result
