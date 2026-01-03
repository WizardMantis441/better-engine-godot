extends AnimatedSprite2D

class_name Splash

var id:int = 0
var animations = [
	["note impact 1 purple", "note impact 2 purple"],
	["note impact 1  blue", "note impact 2 blue"],
	["note impact 1 green", "note impact 2 green"],
	["note impact 1 red", "note impact 2 red"]
]

func _ready() -> void:
	self.play(animations[id].pick_random())
	self.speed_scale = 1 + randi_range(-2, 2) / 24.0

func _on_animation_finished() -> void:
	self.queue_free()
