class_name LevelSection
extends Resource


@export var bpm: float
@export var parts: Array[LevelPart]
@export var intro_part: LevelPart
@export var outro_part: LevelPart
@export_range(0.0, 1.0, 0.01) var enemy_chance: float = 0.0
