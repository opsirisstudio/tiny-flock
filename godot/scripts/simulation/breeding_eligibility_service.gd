class_name BreedingEligibilityService
extends RefCounted

enum Reason { SUCCESS, SHEEP_NOT_FOUND, SAME_SHEEP, NOT_ACTIVE_ADULT, PREGNANT, COOLDOWN, INCOMPATIBLE_SEX, TOO_HUNGRY, TOO_UNHAPPY }

var repository: FlockRepository
var last_error := ""
var last_reason: Reason = Reason.SUCCESS
func _init(value: FlockRepository) -> void: repository = value
func is_individually_eligible(sheep: SheepRecord, current_time: GameTime) -> bool:
	last_reason = get_individual_reason(sheep, current_time)
	return last_reason == Reason.SUCCESS
func get_individual_reason(sheep: SheepRecord, current_time: GameTime) -> Reason:
	if sheep == null or not sheep.validate(): return Reason.SHEEP_NOT_FOUND
	if sheep.age_stage != SheepRecord.AgeStage.ADULT or sheep.location != SheepRecord.Location.ACTIVE_FLOCK: return Reason.NOT_ACTIVE_ADULT
	if sheep.pregnancy != null: return Reason.PREGNANT
	if current_time.total_minutes < sheep.breeding_available_game_minute: return Reason.COOLDOWN
	if sheep.hunger < HusbandryConfig.BREEDING_HUNGER_THRESHOLD: return Reason.TOO_HUNGRY
	if sheep.happiness < HusbandryConfig.BREEDING_HAPPINESS_THRESHOLD: return Reason.TOO_UNHAPPY
	return Reason.SUCCESS
func can_breed(sheep_a: SheepRecord, sheep_b: SheepRecord, current_time: GameTime) -> bool:
	last_error = ""
	last_reason = Reason.SUCCESS
	if sheep_a == null or sheep_b == null or not repository.has_sheep(sheep_a.sheep_id) or not repository.has_sheep(sheep_b.sheep_id): last_reason = Reason.SHEEP_NOT_FOUND; last_error = "Both sheep must exist in the repository."; return false
	if sheep_a.sheep_id == sheep_b.sheep_id: last_reason = Reason.SAME_SHEEP; last_error = "A sheep cannot breed with itself."; return false
	var reason_a := get_individual_reason(sheep_a, current_time); var reason_b := get_individual_reason(sheep_b, current_time)
	if reason_a != Reason.SUCCESS or reason_b != Reason.SUCCESS: last_reason = reason_a if reason_a != Reason.SUCCESS else reason_b; last_error = Reason.keys()[last_reason]; return false
	if sheep_a.sex == sheep_b.sex: last_reason = Reason.INCOMPATIBLE_SEX; last_error = "Pregnancy requires one female and one male."; return false
	return true
