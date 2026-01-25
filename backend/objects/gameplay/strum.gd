extends AnimatedSprite2D

class_name Strum

@onready var strum_line = self.get_parent()
@onready var hud:Hud = strum_line.get_parent()
@onready var game:PlayState = hud.get_parent()

var animations = ["Left", "Down", "Up", "Right"]

@export var id:int = 0
@onready var cpu:bool = strum_line.cpu

@onready var hold_cover:AnimatedSprite2D = $HoldCover
var held_note:Note

func _ready() -> void:
	hold_cover.sprite_frames = load("res://game/hud/default/notes/hold-covers/" + animations[id].to_lower() + ".res")
	hold_cover.play("loop")

func press(hit_note:bool = false):
	self.play(("confirm" if hit_note else "press") + animations[id])

func hold(note:Note):
	held_note = note
	held_note.self_modulate.a = 0.0 # remove head
	hold_cover.visible = true
	hold_cover.play("loop")

func splash():
	var new_splash = preload("res://backend/objects/gameplay/splash.tscn").instantiate()
	new_splash.id = self.id
	new_splash.z_index += 1000
	add_child(new_splash)

func _on_animation_finished() -> void:
	if cpu and animation != "static":
		if held_note: self.play()
		else: self.play("static" + animations[id])

func _process(delta: float) -> void:
	if held_note:
		if !cpu:
			print(held_note.length)
		held_note.length -= delta * 1000.0
		if !cpu:
			print("HELLO")
			game.score += int(250.0 * delta) # TODO: check if score is stored as a float
		if held_note.length <= 0:
			print("die")
			held_note.queue_free()
			hold_cover.play("splash")
