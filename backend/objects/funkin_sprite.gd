class_name FunkinSprite
extends AnimatedSprite2D

@export var animations:Dictionary[String, FunkinAnim]
@export var dance_every:int = 4

func _ready():
	Conductor.step_hit.connect(step_hit)
	animation_finished.connect(on_anim_finish)

var current_anim:String = ""
func play_animation(anim_name:String = "", custom_speed:float = 1, from_end:bool = false, force:bool = false):
	current_anim = anim_name
	
	var real_name:String = anim_name
	if animations.has(anim_name):
		real_name = animations[anim_name].animation_name
		offset = animations[anim_name].offset
	
	play(real_name, custom_speed, from_end)
	
	if force:
		set_frame_and_progress(0, 0.0) # TODO: does this work with from end?

func step_hit(step:int):
	if step % dance_every == 0:
		play_animation(self.animation)

func on_anim_finish():
	if animations.has(current_anim) and animations[current_anim].loop:
		play_animation(current_anim)
