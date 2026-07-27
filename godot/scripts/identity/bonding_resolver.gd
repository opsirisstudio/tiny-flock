class_name BondingResolver
extends RefCounted

static func resolve(profile: PersonalityProfile) -> Dictionary:
	var a := profile.temperament
	return {"bond_gain_modifier":0.75 + float(a.affection) * 0.5, "stranger_comfort":float(a.sociability), "lamb_affinity":(float(a.affection) + float(a.calmness)) / 2.0, "elder_affinity":(float(a.affection) + float(a.sociability)) / 2.0, "player_affinity":(float(a.affection) + float(a.boldness)) / 2.0}
