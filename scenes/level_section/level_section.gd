class_name LevelSection
extends Resource


@export var bpm: float
@export var parts: Array[LevelPart]
@export var intro_part: LevelPart
@export var outro_part: LevelPart
@export_range(0.0, 1.0, 0.01) var enemy_chance: float = 0.0



func our_deep_clone() -> LevelSection:
	var res := LevelSection.new()
	res.bpm = bpm
	res.enemy_chance = enemy_chance
	if res.intro_part != null:
		res.intro_part = intro_part.our_deep_clone()
	if res.outro_part != null:
		res.outro_part = outro_part.our_deep_clone()

	var res_parts: Array[LevelPart] = []
	for lp: LevelPart in parts:
		res_parts.push_back(lp.our_deep_clone())
	res.parts = res_parts

	return res
