class_name PettingService
extends CareServiceBase

func pet_sheep(sheep_id: String, game_time: GameTime) -> CareInteractionResult:
	var result := begin(sheep_id, "PET")
	if result.reason != CareInteractionResult.Reason.INVALID_STATE: return result
	var sheep := repository.get_sheep(sheep_id); var traits := sheep.personality.traits() if sheep.personality != null else []
	var happiness_gain := HusbandryConfig.PET_HAPPINESS_GAIN; var bond_gain := HusbandryConfig.PET_BOND_GAIN
	if "CUDDLY" in traits: happiness_gain *= 1.40; bond_gain *= 1.40; result.personality_modifiers_applied.append("CUDDLY")
	if "SOCIAL" in traits: happiness_gain *= 1.15; bond_gain *= 1.15; result.personality_modifiers_applied.append("SOCIAL")
	if "INDEPENDENT" in traits: happiness_gain *= 0.75; result.personality_modifiers_applied.append("INDEPENDENT")
	if "SHY" in traits:
		var warm_up := 0.45 + 0.55 * sheep.bond
		happiness_gain *= warm_up; bond_gain *= warm_up; result.personality_modifiers_applied.append("SHY_WARM_UP")
	sheep.happiness = clampf(sheep.happiness + happiness_gain, 0.0, 1.0); sheep.bond = clampf(sheep.bond + apply_life_stage_bond(sheep, bond_gain, true), 0.0, 1.0)
	record(sheep_id, SheepLifeEvent.Type.PETTED, game_time); result.complete(sheep); return result
