class_name Character
extends Node2D

var can_idle = true
var idle_anim_index:int = 0

@onready var sprite:FunkinSprite = $FunkinSprite
@export var camera_offset:Vector2 = Vector2.ZERO
@export var swap_left_right_anims:bool = false
@export var idle_anims:Array[String] = []

func _ready():
	Conductor.step_hit.disconnect(sprite.step_hit)
	Conductor.step_hit.connect(step_hit)

	sprite.animation_finished.connect(on_anim_finish)

func play_animation(anim_name:String = "", custom_speed:float = 1, from_end:bool = false) -> void:
	if swap_left_right_anims:
		if anim_name.find("LEFT") != -1:
			anim_name.replace("LEFT", "RIGHT")
		elif anim_name.find("RIGHT") != -1:
			anim_name.replace("RIGHT", "LEFT")
	
	sprite.play_animation(anim_name, custom_speed, from_end)
	
	if anim_name.to_lower().find("sing") != -1:
		can_idle = false

func idle(_step:int):
	if idle_anims.size() < 1:
		if sprite.animations.has("danceLeft") || sprite.animations.has("danceRight"):
			play_animation("danceLeft" if sprite.current_anim == "danceRight" else "danceRight")
		elif sprite.animations.has("idle"):
			play_animation("idle")
	else:
		play_animation(idle_anims[idle_anim_index])
		idle_anim_index = wrap(idle_anim_index + 1, 0, idle_anims.size() - 1)
	
func step_hit(step:int):
	if can_idle and step % sprite.dance_every == 0:
		idle(step)
	
func on_anim_finish():
	can_idle = true
