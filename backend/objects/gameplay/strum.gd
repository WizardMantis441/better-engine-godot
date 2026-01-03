extends AnimatedSprite2D

class_name Strum

@onready var strum_line = self.get_parent()

var animations = ["Left", "Down", "Up", "Right"]

@export var id:int = 0
@onready var cpu:bool = strum_line.cpu

func press(hit_note:bool = false):
	self.play(("confirm" if hit_note else "press") + animations[id])

func _on_animation_finished() -> void:
	if cpu and animation != "static":
		self.play("static" + animations[id])

func splash():
	var new_splash = preload("res://backend/objects/gameplay/splash.tscn").instantiate()
	new_splash.id = self.id
	new_splash.z_index += 1000
	add_child(new_splash)
