class_name FoodRegistry
extends RefCounted

static func get_food(food_id: String) -> FoodDefinition:
	if food_id not in PersonalityConfig.FOODS: return null
	var treat := food_id in ["APPLE", "CARROT", "PUMPKIN", "BERRIES"]
	return FoodDefinition.new(food_id, HusbandryConfig.TREAT_FEED_AMOUNT if treat else HusbandryConfig.BASE_FEED_AMOUNT, HusbandryConfig.TREAT_FEED_HAPPINESS_GAIN if treat else HusbandryConfig.BASE_FEED_HAPPINESS_GAIN, treat)
