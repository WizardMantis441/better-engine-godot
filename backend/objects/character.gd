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

func step_hit(_step:int):
	cur_hold_time += 1
	if cur_hold_time >= hold_time: ## TODO: is this > or >= ? also should i force a dance at the end?
		sprite.can_dance = true

func play_anim(anim_name:StringName = &"", custom_speed:float = 1.0, from_end:bool = false, should_loop:bool = false, context:Enums.AnimContext = Enums.AnimContext.NONE):
	sprite.play_anim(anim_name, custom_speed, from_end, should_loop, context)

	if context in [Enums.AnimContext.SING, Enums.AnimContext.MISS]:
		sprite.can_dance = false
		cur_hold_time = 0
