class_name LifetimeStatisticsService
extends RefCounted

var repository: FlockRepository
func _init(value: FlockRepository) -> void: repository = value
func get_statistics(sheep_id: String) -> Dictionary:
	var history := SheepHistoryService.new(repository); var pedigree := PedigreeService.new(repository); var breeding := BreedingHistoryService.new(repository)
	var descendants := pedigree.get_descendants(sheep_id); var max_depth := 0; var sheep := repository.get_sheep(sheep_id)
	if sheep != null:
		for descendant: SheepRecord in descendants: max_depth = maxi(max_depth, descendant.generation - sheep.generation)
	return {"offspring_count":breeding.get_offspring(sheep_id).size(), "breeding_count":breeding.get_breeding_count(sheep_id), "shearing_count":history.get_events_by_type(sheep_id, SheepLifeEvent.Type.SHEARED).size(), "barn_archive_count":history.get_events_by_type(sheep_id, SheepLifeEvent.Type.ARCHIVED_TO_BARN).size(), "pasture_return_count":history.get_events_by_type(sheep_id, SheepLifeEvent.Type.RETURNED_FROM_BARN).size(), "favorite_count":history.get_events_by_type(sheep_id, SheepLifeEvent.Type.MARKED_FAVORITE).size(), "known_descendant_count":descendants.size(), "known_generation_depth":max_depth}
