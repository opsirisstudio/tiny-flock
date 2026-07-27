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
	TestSheepIdentity.run()
	TestLifecycleSimulation.run()
	print("Tiny Flock static-prepared domain tests: PASS")
	quit(0)
