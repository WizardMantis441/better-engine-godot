class_name FunkinCamera
extends Camera2D

@export var lerp_to_target_zoom:bool = true
@export var target_zoom:Vector2 = Vector2(1, 1)
@export var target_zoom_weight:float = 0.04

func tween_to_point(position:Vector2, time:float, tween_str:String):
	pass

func snap_to_point(new_pos:Vector2):
	position = new_pos
	position_smoothing_enabled = false
	await get_tree().create_timer(0.0001).timeout
	position_smoothing_enabled = false

func _process(delta: float) -> void:
	if lerp_to_target_zoom:
		zoom = lerp(zoom, target_zoom, target_zoom_weight * 60 * delta)
