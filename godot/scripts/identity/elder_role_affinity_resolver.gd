class_name ElderRoleAffinityResolver
extends RefCounted

static func get_elder_role_affinities(profile: PersonalityProfile) -> Dictionary:
	var a := profile.temperament
	return {SheepRecord.ElderRole.NANNY:(a.affection+a.calmness+a.sociability)/3.0, SheepRecord.ElderRole.COMFORTER:(a.affection+a.calmness)/2.0, SheepRecord.ElderRole.GROOMER:(a.sociability+a.calmness)/2.0, SheepRecord.ElderRole.SHEPHERD:(a.boldness+a.sociability+(1.0-absf(a.energy-0.5)*2.0))/3.0, SheepRecord.ElderRole.FORAGER:(a.curiosity+a.energy+a.food_drive)/3.0, SheepRecord.ElderRole.STORYKEEPER:(a.calmness+a.sociability+(1.0-a.energy))/3.0}

static func get_best_elder_role(profile: PersonalityProfile) -> SheepRecord.ElderRole:
	var scores := get_elder_role_affinities(profile); var best := SheepRecord.ElderRole.NONE; var score := -1.0
	for role: int in scores:
		if float(scores[role]) > score: best = role as SheepRecord.ElderRole; score = float(scores[role])
	return best
