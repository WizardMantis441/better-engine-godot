extends Node2D

@onready var items:Node = $Parallax2/Items
@onready var camera:Camera2D = $Camera

var can_input:bool = true
static var cur_selected:int = 0

func _ready():
	for i in items.get_child_count():
		var item = items.get_child(i)
		item.position.x = 1280 / 2.0
		item.position.y = (720 - (160 * (items.get_child_count() - 1))) / 2.0
		item.position.y += 160 * i
		if i == cur_selected:
			item.play("selected")
		
	camera.position = items.get_child(cur_selected).position.lerp(Vector2(640, 360), 0.6)

func _process(_delta: float) -> void:
	if can_input:
		if Input.is_action_just_pressed("ui_up"):
			items.get_child(cur_selected).play("idle")
			cur_selected = wrap(cur_selected - 1, 0, items.get_child_count())
			items.get_child(cur_selected).play("selected")
			camera.position = items.get_child(cur_selected).position.lerp(Vector2(640, 360), 0.6)
		if Input.is_action_just_pressed("ui_down"):
			items.get_child(cur_selected).play("idle")
			cur_selected = wrap(cur_selected + 1, 0, items.get_child_count())
			items.get_child(cur_selected).play("selected")
			camera.position = items.get_child(cur_selected).position.lerp(Vector2(640, 360), 0.6)
			
