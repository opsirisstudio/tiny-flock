class_name FoodDefinition
extends RefCounted

var food_id := ""
var hunger_restoration := 0.0
var happiness_effect := 0.0
var is_treat := false
func _init(id: String = "", restoration: float = 0.0, happiness: float = 0.0, treat: bool = false) -> void:
	food_id = id; hunger_restoration = restoration; happiness_effect = happiness; is_treat = treat
