class_name CareInteractionResult
extends RefCounted

enum Reason { SUCCESS, SHEEP_NOT_FOUND, SHEEP_ARCHIVED, INVALID_FOOD, INVALID_STATE }
var success := false
var reason: Reason = Reason.INVALID_STATE
var sheep_id := ""
var interaction_type := ""
var before_hunger := 0.0
var after_hunger := 0.0
var before_cleanliness := 0.0
var after_cleanliness := 0.0
var before_happiness := 0.0
var after_happiness := 0.0
var before_bond := 0.0
var after_bond := 0.0
var preference_match := "NONE"
var personality_modifiers_applied: Array[String] = []

func capture_before(sheep: SheepRecord) -> void:
	before_hunger = sheep.hunger; before_cleanliness = sheep.cleanliness; before_happiness = sheep.happiness; before_bond = sheep.bond
func capture_after(sheep: SheepRecord) -> void:
	after_hunger = sheep.hunger; after_cleanliness = sheep.cleanliness; after_happiness = sheep.happiness; after_bond = sheep.bond
func complete(sheep: SheepRecord) -> void:
	capture_after(sheep); success = true; reason = Reason.SUCCESS
