class_name TestArchiveTransitions
extends RefCounted

static func run() -> void:
	_test_age_freezes_and_resumes()
	_test_archived_pregnancy_does_not_resolve_and_due_date_shifts()
	_test_postpartum_cooldown_shift()
	_test_restore_to_flock_repository_semantics()
	_test_events_and_idempotent_archive()
	_test_activate_elder_from_archive()
	_test_save_v5_round_trip_and_load_time_age_cap()

static func _sheep(id: String, sex: SheepRecord.Sex, age: SheepRecord.AgeStage = SheepRecord.AgeStage.ADULT) -> SheepRecord:
	var sheep := SheepRecord.new(); sheep.sheep_id = id; sheep.sheep_name = id; sheep.sex = sex; sheep.age_stage = age; sheep.genome = SheepFactory.default_genome(); var rng := RandomNumberGenerator.new(); rng.seed = id.hash(); sheep.personality = PersonalityGenerator.generate_founder_personality(rng); return sheep

static func _test_age_freezes_and_resumes() -> void:
	var repo := FlockRepository.new(); var sheep := _sheep("frozen-age", SheepRecord.Sex.FEMALE, SheepRecord.AgeStage.LAMB); assert(repo.add_sheep(sheep))
	var clock := GameClock.new(); var coordinator := SimulationCoordinator.new(); var archives := ArchiveTransitionService.new(repo)
	coordinator.advance_simulation(repo, clock, 1440) # 1 active day: age 1 day, needs decay a bit
	var frozen := [sheep.hunger, sheep.cleanliness, sheep.happiness, sheep.bond, sheep.wool_growth]
	assert(archives.archive("frozen-age", clock.get_current_time())) # archived at day 1, age 1 day
	coordinator.advance_simulation(repo, clock, 200 * 1440) # 200 archived days pass
	assert(sheep.age_stage == SheepRecord.AgeStage.LAMB)
	assert([sheep.hunger, sheep.cleanliness, sheep.happiness, sheep.bond, sheep.wool_growth] == frozen)
	var history := SheepHistoryService.new(repo)
	assert(history.get_events_by_type("frozen-age", SheepLifeEvent.Type.BECAME_JUVENILE).is_empty())
	assert(history.get_events_by_type("frozen-age", SheepLifeEvent.Type.BECAME_ADULT).is_empty())
	assert(history.get_events_by_type("frozen-age", SheepLifeEvent.Type.BECAME_ELDER).is_empty())
	assert(archives.restore_to_flock("frozen-age", clock.get_current_time()))
	assert(LifecycleService.get_age_minutes(sheep, clock.get_current_time()) == 1440) # still exactly 1 day old
	coordinator.advance_simulation(repo, clock, 1440) # 1 more active day: age 2 days
	assert(sheep.age_stage == SheepRecord.AgeStage.LAMB and sheep.hunger < frozen[0]) # decay resumed from the frozen value
	coordinator.advance_simulation(repo, clock, 6 * 1440) # age 8 days: crosses into juvenile
	assert(sheep.age_stage == SheepRecord.AgeStage.JUVENILE)
	assert(not history.get_events_by_type("frozen-age", SheepLifeEvent.Type.BECAME_JUVENILE).is_empty())

static func _test_archived_pregnancy_does_not_resolve_and_due_date_shifts() -> void:
	var repo := FlockRepository.new(); var mother := _sheep("mother", SheepRecord.Sex.FEMALE); mother.birth_game_minute = -14 * 1440; var father := _sheep("father", SheepRecord.Sex.MALE); father.birth_game_minute = -14 * 1440
	assert(repo.add_sheep(mother) and repo.add_sheep(father))
	var clock := GameClock.new(); var coordinator := SimulationCoordinator.new(); var archives := ArchiveTransitionService.new(repo)
	assert(BreedingService.new(repo).conceive("mother", "father", clock.get_current_time(), 123).success)
	var original_due := mother.pregnancy.due_game_minute
	assert(archives.archive("mother", clock.get_current_time())) # archived at minute 0, while pregnant
	var direct_attempt := PregnancyService.new(repo).resolve_due_pregnancy(mother, GameTime.new(10000))
	assert(not direct_attempt.success and "rchived" in direct_attempt.error and mother.pregnancy != null and repo.count() == 2)
	var births := coordinator.advance_simulation(repo, clock, 10000) # clock now at minute 10000, well past the original due date
	assert(births.size() == 1 and not births[0].success and mother.pregnancy != null and repo.count() == 2)
	assert(archives.restore_to_flock("mother", clock.get_current_time())) # restore at minute 10000
	assert(mother.pregnancy.due_game_minute == original_due + 10000) # due date pushed out by the frozen span
	var too_early := PregnancyService.new(repo).resolve_due_pregnancy(mother, GameTime.new(10000))
	assert(not too_early.success and "not due" in too_early.error)
	var remaining := mother.pregnancy.due_game_minute - clock.get_total_minutes()
	var final_births := coordinator.advance_simulation(repo, clock, remaining)
	assert(final_births.size() == 1 and final_births[0].success and mother.pregnancy == null and repo.count() > 2)

static func _test_postpartum_cooldown_shift() -> void:
	var repo := FlockRepository.new(); var pending := _sheep("cooldown-pending", SheepRecord.Sex.FEMALE); pending.breeding_available_game_minute = 100; assert(repo.add_sheep(pending))
	var expired := _sheep("cooldown-expired", SheepRecord.Sex.FEMALE); expired.breeding_available_game_minute = 30; assert(repo.add_sheep(expired))
	var archives := ArchiveTransitionService.new(repo)
	assert(archives.archive("cooldown-pending", GameTime.new(50)) and archives.archive("cooldown-expired", GameTime.new(50)))
	assert(archives.restore_to_flock("cooldown-pending", GameTime.new(5000)) and archives.restore_to_flock("cooldown-expired", GameTime.new(5000)))
	assert(pending.breeding_available_game_minute == 5050) # still pending at archive time: shifted forward by the frozen span
	assert(expired.breeding_available_game_minute == 30) # already expired before archiving: left untouched

static func _test_restore_to_flock_repository_semantics() -> void:
	var repo := FlockRepository.new(); var sheep := _sheep("not-archived", SheepRecord.Sex.FEMALE); assert(repo.add_sheep(sheep))
	assert(not repo.restore_to_flock("not-archived") and not repo.restore_to_flock("missing-id"))
	assert(repo.archive_sheep("not-archived") and repo.restore_to_flock("not-archived") and sheep.location == SheepRecord.Location.ACTIVE_FLOCK)

static func _test_events_and_idempotent_archive() -> void:
	var repo := FlockRepository.new(); var sheep := _sheep("events", SheepRecord.Sex.FEMALE); assert(repo.add_sheep(sheep))
	var archives := ArchiveTransitionService.new(repo); var history := SheepHistoryService.new(repo)
	assert(archives.archive("events", GameTime.new(10)) and sheep.archived_at_game_minute == 10)
	assert(history.get_events_by_type("events", SheepLifeEvent.Type.ARCHIVED_TO_BARN).size() == 1)
	assert(archives.archive("events", GameTime.new(20))) # already archived: must not clobber the original start
	assert(sheep.archived_at_game_minute == 10 and history.get_events_by_type("events", SheepLifeEvent.Type.ARCHIVED_TO_BARN).size() == 1)
	assert(archives.restore_to_flock("events", GameTime.new(30)))
	assert(sheep.archived_at_game_minute == -1 and sheep.birth_game_minute == 20) # frozen for 30 - 10 = 20 minutes
	assert(history.get_events_by_type("events", SheepLifeEvent.Type.RETURNED_FROM_BARN).size() == 1)

static func _test_activate_elder_from_archive() -> void:
	var repo := FlockRepository.new(); var archived_elder := _sheep("elder-from-archive", SheepRecord.Sex.FEMALE, SheepRecord.AgeStage.ELDER); assert(repo.add_sheep(archived_elder))
	var archives := ArchiveTransitionService.new(repo); var history := SheepHistoryService.new(repo)
	assert(archives.archive("elder-from-archive", GameTime.new(5)))
	assert(archives.activate_elder("elder-from-archive", GameTime.new(25)))
	assert(archived_elder.location == SheepRecord.Location.ACTIVE_ELDER and archived_elder.archived_at_game_minute == -1 and archived_elder.birth_game_minute == 20)
	assert(history.get_events_by_type("elder-from-archive", SheepLifeEvent.Type.RETURNED_FROM_BARN).size() == 1)
	var already_active_elder := _sheep("elder-already-active", SheepRecord.Sex.MALE, SheepRecord.AgeStage.ELDER); assert(repo.add_sheep(already_active_elder))
	assert(archives.activate_elder("elder-already-active", GameTime.new(100)))
	assert(history.get_events_by_type("elder-already-active", SheepLifeEvent.Type.RETURNED_FROM_BARN).is_empty()) # was never archived: no unfreeze bookkeeping

static func _test_save_v5_round_trip_and_load_time_age_cap() -> void:
	var repo := FlockRepository.new(); var lamb := _sheep("frozen-lamb", SheepRecord.Sex.FEMALE, SheepRecord.AgeStage.LAMB); lamb.birth_game_minute = 0; assert(repo.add_sheep(lamb))
	var clock := GameClock.new(); var coordinator := SimulationCoordinator.new(); var archives := ArchiveTransitionService.new(repo)
	assert(archives.archive("frozen-lamb", clock.get_current_time()))
	coordinator.advance_simulation(repo, clock, 100 * 1440) # 100 days pass while archived: would derive ELDER if not capped
	var saved := FlockPersistence.to_json(repo, clock)
	var loaded := FlockPersistence.from_json(saved)
	assert(loaded != null)
	var loaded_lamb := loaded.get_sheep("frozen-lamb")
	assert(loaded_lamb.age_stage == SheepRecord.AgeStage.LAMB and loaded_lamb.location == SheepRecord.Location.BARN_ARCHIVE and loaded_lamb.archived_at_game_minute == 0)
	var v5_dict := FlockPersistence.to_dictionary(repo, clock)
	var v4_dict := v5_dict.duplicate(true); v4_dict.save_version = 4
	assert(FlockPersistence.from_dictionary(v4_dict) == null and "Unsupported save version" in FlockPersistence.last_error)
