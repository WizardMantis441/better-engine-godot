@tool
class_name Character extends Node2D

@export var sprite:Bopper
@export var animation_player:AnimationPlayer

## Amount of time until the character can resume idling.
@export_custom(PROPERTY_HINT_NONE, "suffix:steps") var hold_time:int = 8

var cur_hold_time:int = 0

func _ready() -> void:
	if !Engine.is_editor_hint():
		Conductor.step_hit.connect(step_hit)

func _process(_delta: float) -> void:
	# TODO: stepTime
	
	pass

func step_hit(step:int):
	pass
