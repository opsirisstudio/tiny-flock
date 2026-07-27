class_name PersonalityConfig
extends RefCounted

const AXES: Array[String] = ["sociability", "energy", "boldness", "affection", "food_drive", "curiosity", "mischief", "calmness"]
const PERSONALITY_VARIATION_RANGE := 0.15
const TRAIT_THRESHOLDS := {"high":0.7, "low":0.3, "independent_boldness":0.5}
const FOODS: Array[String] = ["APPLE", "CARROT", "CLOVER", "OATS", "PUMPKIN", "BERRIES"]
