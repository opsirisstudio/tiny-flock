class_name PersonalityResolver
extends RefCounted

const TRAITS: Array[String] = ["CALM", "SOCIAL", "SHY", "GREEDY", "CURIOUS", "INDEPENDENT", "CUDDLY", "MISCHIEVOUS", "SLEEPY", "ZOOMY"]

static func resolve(axes: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var high: float = PersonalityConfig.TRAIT_THRESHOLDS.high; var low: float = PersonalityConfig.TRAIT_THRESHOLDS.low
	if float(axes.get("calmness", 0.0)) >= high: result.append("CALM")
	if float(axes.get("sociability", 0.0)) >= high: result.append("SOCIAL")
	if float(axes.get("boldness", 1.0)) <= low: result.append("SHY")
	if float(axes.get("food_drive", 0.0)) >= high: result.append("GREEDY")
	if float(axes.get("curiosity", 0.0)) >= high: result.append("CURIOUS")
	if float(axes.get("sociability", 1.0)) <= low and float(axes.get("boldness", 0.0)) >= float(PersonalityConfig.TRAIT_THRESHOLDS.independent_boldness): result.append("INDEPENDENT")
	if float(axes.get("affection", 0.0)) >= high: result.append("CUDDLY")
	if float(axes.get("mischief", 0.0)) >= high: result.append("MISCHIEVOUS")
	if float(axes.get("energy", 1.0)) <= low: result.append("SLEEPY")
	if float(axes.get("energy", 0.0)) >= high and float(axes.get("boldness", 0.0)) >= high: result.append("ZOOMY")
	return result
