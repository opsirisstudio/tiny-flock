class_name SimulationCoordinator
extends RefCounted

func advance_simulation(repository: FlockRepository, clock: GameClock, minutes: int) -> Array[BirthResult]:
	if minutes < 0 or not clock.advance_minutes(minutes): return []
	var current := clock.get_current_time(); var lifecycle := LifecycleService.new(repository)
	var existing := repository.all_sheep()
	for sheep: SheepRecord in existing: lifecycle.update_age_stage(sheep, current)
	var births := PregnancyService.new(repository).resolve_all_due(current)
	var wool := WoolGrowthService.new()
	for sheep: SheepRecord in existing: wool.advance_wool_growth(sheep, minutes)
	return births
