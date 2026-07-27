extends Control

@onready var sheep_selector: OptionButton = %SheepSelector
@onready var food_selector: OptionButton = %FoodSelector
@onready var details: RichTextLabel = %Details
var repository := FlockRepository.new()
var clock := GameClock.new()
var coordinator := SimulationCoordinator.new()

func _ready() -> void:
	for sheep: SheepRecord in SheepFactory.founders(): repository.add_sheep(sheep)
	for food: String in PersonalityConfig.FOODS: food_selector.add_item(food)
	_refresh()
func _selected_id() -> String: return sheep_selector.get_item_metadata(sheep_selector.selected) if sheep_selector.item_count > 0 else ""
func _refresh() -> void:
	var selected := _selected_id(); sheep_selector.clear()
	for sheep: SheepRecord in repository.all_sheep(): sheep_selector.add_item(sheep.sheep_name); sheep_selector.set_item_metadata(sheep_selector.item_count - 1, sheep.sheep_id)
	for index: int in range(sheep_selector.item_count):
		if sheep_selector.get_item_metadata(index) == selected: sheep_selector.select(index)
	_show_selected()
func _show_selected() -> void:
	var sheep := repository.get_sheep(_selected_id())
	if sheep == null: details.text = "No sheep selected"; return
	var traits := sheep.personality.traits(); var wool := WoolGrowthService.new().get_wool_growth_efficiency(sheep); var eligibility := BreedingEligibilityService.new(repository); eligibility.is_individually_eligible(sheep, clock.get_current_time())
	var recent := SheepHistoryService.new(repository).get_recent_events(sheep.sheep_id, 8); var event_names: Array[String] = []
	for event: SheepLifeEvent in recent: event_names.append(SheepLifeEvent.Type.keys()[event.event_type])
	details.text = "Time: %d\nHunger %.2f | Cleanliness %.2f | Happiness %.2f | Bond %.2f\nMood: %s\nTraits: %s\nFavorite: %s | Disliked: %s\nWool care efficiency: %.2f\nBreeding care/status: %s\nRecent care events: %s" % [clock.get_total_minutes(), sheep.hunger, sheep.cleanliness, sheep.happiness, sheep.bond, MoodResolver.label(MoodResolver.resolve(sheep)), str(traits), sheep.personality.favorite_food, sheep.personality.disliked_food, wool, BreedingEligibilityService.Reason.keys()[eligibility.last_reason], str(event_names)]
func _on_sheep_selected(_index: int) -> void: _show_selected()
func _on_feed_pressed() -> void: FeedingService.new(repository).feed_sheep(_selected_id(), food_selector.get_item_text(food_selector.selected), clock.get_current_time()); _show_selected()
func _on_pet_pressed() -> void: PettingService.new(repository).pet_sheep(_selected_id(), clock.get_current_time()); _show_selected()
func _on_groom_pressed() -> void: GroomingService.new(repository).groom_sheep(_selected_id(), clock.get_current_time()); _show_selected()
func _on_wash_pressed() -> void: WashingService.new(repository).wash_sheep(_selected_id(), clock.get_current_time()); _show_selected()
func _on_hour_pressed() -> void: coordinator.advance_simulation(repository, clock, GameTime.MINUTES_PER_HOUR); _show_selected()
func _on_day_pressed() -> void: coordinator.advance_simulation(repository, clock, GameTime.MINUTES_PER_DAY); _show_selected()
