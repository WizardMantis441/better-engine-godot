@tool

class_name Bopper
extends AnimateSymbol

@export var idle_animations:Array[StringName] = ["idle"]
var cur_idle_index:int = 0

var can_dance:bool = true
var cur_anim_context:AnimContext = AnimContext.NONE
var override_context:bool = false # for debug purposes

@export_custom(PROPERTY_HINT_NONE, "suffix:steps") var dance_every:int = 4
@export_custom(PROPERTY_HINT_NONE, "suffix:steps") var dance_every_offset:int = 0

enum AnimContext {
	## Default animation, has no priority
	NONE,
	## Idle animation, lowest priority
	DANCE,
	## Singing, prioritized over `AnimContext.DANCE`
	SING,
	## Missing, acts similarly to `AnimContext.SING`
	MISS,
	## Special, doesn't allow `AnimContext.SING` or `AnimContext.MISS` animations to override
	SPECIAL,
	## Locked, similar to `AnimContext.SPECIAL`, but doesn't return context to `AnimContext.NONE` on finish
	LOCK
}

func _ready():
	dance()
	if !Engine.is_editor_hint():
		Conductor.step_hit.connect(step_hit)

func step_hit(step:int):
	if (step + dance_every_offset) % dance_every == 0 && can_dance:
		dance()

func dance():
	if self.symbol != idle_animations[cur_idle_index]:
		play_anim(idle_animations[cur_idle_index])
	
	cur_idle_index = wrapi(cur_idle_index + 1, 0, idle_animations.size())

func play_anim(anim_name:StringName = &"", custom_speed:float = 1.0, from_end:bool = false, should_loop:bool = false, context:AnimContext = AnimContext.NONE):
	if !override_context:
		# if cur none and new dance then cancel
		# if cur special and new [dance, sing, miss] and anim not finished then cancel
		# if cur lock and new [dance, sing, miss] then cancel

		# ok now after all of that
		# if sing or miss then add to hold time
		pass
	
	cur_anim_context = context

	self.symbol = anim_name
	self.frame = self.get_animation_length() if from_end else 0
	self.speed_scale = -custom_speed if from_end else custom_speed
	self.playing = true
	self.loop = should_loop
