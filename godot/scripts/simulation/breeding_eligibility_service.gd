class_name BreedingEligibilityService
extends RefCounted

var repository: FlockRepository
var last_error := ""
func _init(value: FlockRepository) -> void: repository = value
func is_individually_eligible(sheep: SheepRecord, current_time: GameTime) -> bool:
	return sheep != null and sheep.validate() and sheep.age_stage == SheepRecord.AgeStage.ADULT and sheep.location == SheepRecord.Location.ACTIVE_FLOCK and sheep.pregnancy == null and current_time.total_minutes >= sheep.breeding_available_game_minute
func can_breed(sheep_a: SheepRecord, sheep_b: SheepRecord, current_time: GameTime) -> bool:
	last_error = ""
	if sheep_a == null or sheep_b == null or not repository.has_sheep(sheep_a.sheep_id) or not repository.has_sheep(sheep_b.sheep_id): last_error = "Both sheep must exist in the repository."; return false
	if sheep_a.sheep_id == sheep_b.sheep_id: last_error = "A sheep cannot breed with itself."; return false
	if not is_individually_eligible(sheep_a, current_time) or not is_individually_eligible(sheep_b, current_time): last_error = "Both sheep must be eligible active adults."; return false
	if sheep_a.sex == sheep_b.sex: last_error = "Pregnancy requires one female and one male."; return false
	return true
