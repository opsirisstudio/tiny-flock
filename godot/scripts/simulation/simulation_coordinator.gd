class_name SimulationCoordinator
extends RefCounted

func advance_simulation(repository: FlockRepository, clock: GameClock, minutes: int) -> Array[BirthResult]:
	var old_time := clock.get_current_time()
	if minutes < 0 or not clock.advance_minutes(minutes): return []
	var current := clock.get_current_time(); var lifecycle := LifecycleService.new(repository)
	var existing := repository.all_sheep()
	var husbandry := HusbandrySimulationService.new()
	# Needs decay intentionally reads each sheep's pre-transition age_stage: decay rates are
	# not currently age-dependent, so the ordering is inert today. If an age-sensitive care
	# rate is ever added, decide deliberately whether it should see the old or new stage here.
	for sheep: SheepRecord in existing: husbandry.advance_needs(sheep, minutes)
	for sheep: SheepRecord in existing: lifecycle.update_age_stage(sheep, current)
	var births := PregnancyService.new(repository).resolve_all_due(current)
	var wool := WoolGrowthService.new()
	for sheep: SheepRecord in existing: wool.advance_wool_growth_interval(sheep, old_time, current)
	return births
