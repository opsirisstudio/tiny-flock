extends SceneTree

func _init() -> void:
	TestGenomeValidation.run()
	TestPhenotypeResolver.run()
	TestBreedingEngine.run()
	TestMutationManager.run()
	TestFlockRepository.run()
	TestPersistence.run()
	TestPedigreeService.run()
	TestGeneticKnowledge.run()
	print("Tiny Flock genetics tests: PASS")
	quit(0)
