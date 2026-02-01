class_name Sun
extends Node2D



@export var module_curve: Curve

@onready var rings: Array[Sprite2D] = [
	$Ring5,
	$Ring4,
	$Ring3,
	$Ring2,
	$Ring1,
]


## Set health accepts percentage (0.0-1.0) of health.
func set_health(p: float) -> void:
	assert(0 <= p and p <= 1, "percentage out of range")
	
	var want_ops: Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0]

	if is_zero_approx(p):
		for i: int in 5:
			want_ops[i] = 0
	else:
		p *= 5 # p in [0; 5]
		var rings_active := ceili(p)

		assert(rings_active > 0, "expected at least one ring to be active")

		for i: int in 5:
			if i >= rings_active:
				want_ops[i] = 0.0
		
		var opacity := remap(p, rings_active-1, rings_active, 0, 1)
		want_ops[rings_active - 1] = opacity
	
	var t := create_tween()
	for i: int in 5:
		t.parallel().tween_property(rings[i], "modulate:a", module_curve.sample(want_ops[i]), 0.5)
