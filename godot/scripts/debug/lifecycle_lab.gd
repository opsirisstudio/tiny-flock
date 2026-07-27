extends Control

@onready var details: RichTextLabel = %Details
var repository := FlockRepository.new()
var clock := GameClock.new()
var coordinator := SimulationCoordinator.new()
var selected_ids: Array[String] = []
func _ready() -> void:
	for sheep: SheepRecord in SheepFactory.founders(): repository.add_sheep(sheep)
	selected_ids = ["founder-clover", "founder-biscuit"]; _refresh()
func _advance(minutes: int) -> void: coordinator.advance_simulation(repository, clock, minutes); _refresh()
func _on_hour_pressed() -> void: _advance(GameTime.MINUTES_PER_HOUR)
func _on_day_pressed() -> void: _advance(GameTime.MINUTES_PER_DAY)
func _on_ten_days_pressed() -> void: _advance(10 * GameTime.MINUTES_PER_DAY)
func _on_breed_pressed() -> void: BreedingService.new(repository).conceive(selected_ids[0], selected_ids[1], clock.get_current_time(), 4004); _refresh()
func _on_shear_pressed() -> void: ShearingService.new(repository).shear(selected_ids[0], clock.get_current_time()); _refresh()
func _on_events_pressed() -> void: _refresh(true)
func _refresh(show_events: bool = false) -> void:
	var sheep := repository.get_sheep(selected_ids[0]); var lifecycle := LifecycleService.new(repository); var eligibility := BreedingEligibilityService.new(repository)
	var lines := [clock.get_current_time().format_day_time(), "Selected: %s" % sheep.sheep_name, "Age: %d days / stage %d" % [lifecycle.get_age_days(sheep, clock.get_current_time()), sheep.age_stage], "Breeding eligible: %s" % eligibility.is_individually_eligible(sheep, clock.get_current_time()), "Pregnant: %s" % (sheep.pregnancy != null), "Due minute: %s" % (sheep.pregnancy.due_game_minute if sheep.pregnancy != null else "—"), "Breeding available: %d" % sheep.breeding_available_game_minute, "Wool: %.3f / shear ready: %s" % [sheep.wool_growth, WoolGrowthService.new().is_ready_to_shear(sheep)]]
	if show_events:
		for event: SheepLifeEvent in SheepHistoryService.new(repository).get_recent_events(sheep.sheep_id, 10): lines.append("Event %d @ %d" % [event.event_type, event.time_marker])
	details.text = "\n".join(lines)
