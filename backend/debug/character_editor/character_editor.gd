extends Control

var character:Character
var character_ghost:Character

func _ready() -> void:
	await ready
	_on_new_character_pressed()

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"): %Viewport.get_camera_2d().position.x -= delta * 200
	if Input.is_action_pressed("ui_down"): %Viewport.get_camera_2d().position.y += delta * 200
	if Input.is_action_pressed("ui_up"): %Viewport.get_camera_2d().position.y -= delta * 200
	if Input.is_action_pressed("ui_right"): %Viewport.get_camera_2d().position.x += delta * 200

func load_character(path:String):
	if character: character.queue_free()
	if character_ghost: character_ghost.queue_free()

	var char_scene = load(path)
	character = char_scene.instantiate()
	character_ghost = char_scene.instantiate()
	character_ghost.visible = false
	
	%NameInput.text = character.name
	%CameraOffsetX.value = character.camera_offset.x
	%CameraOffsetY.value = character.camera_offset.y
	%SwapLeftRightAnimsInput.button_pressed = character.swap_left_right_anims
	%IdleAnimsInput.text = ", ".join(character.idle_anims)
	
	%Viewport.add_child(character)
	%Viewport.add_child(character_ghost)
	
	var anim_scene = load("res://backend/debug/character_editor/character_animation.tscn")
	for anim in character.sprite.animations.keys():
		var new_anim = anim_scene.instantiate()
		new_anim.set_data(anim, character.sprite.animations.get(anim))
		%AnimationsList.add_child(new_anim)
		
		new_anim.play.pressed.connect(_on_anim_play_pressed.bind(new_anim))
		new_anim.show_ghost.pressed.connect(_on_anim_show_ghost_pressed.bind(new_anim))
		new_anim.delete.pressed.connect(_on_anim_delete_pressed.bind(new_anim))

func _on_new_character_pressed() -> void:
	load_character("res://game/characters/bf/bf.tscn")

func _on_load_character(path: String) -> void:
	load_character(path)

func _on_save_character(path: String) -> void:
	var saved_freaking_character_bro = PackedScene.new().pack(character)
	ResourceSaver.save(saved_freaking_character_bro, path)

func _on_name_text_submitted(new_text: String) -> void:
	character.name = new_text

func _on_sprite_selected(path: String) -> void:
	character.sprite.sprite_frames = load(path)
	# load anims again probably

func _on_cam_offset_x_value_changed(value: float) -> void:
	character.camera_offset.x = value

func _on_cam_offset_y_value_changed(value: float) -> void:
	character.camera_offset.y = value

func _on_swap_left_right_anims_toggled(toggled_on: bool) -> void:
	character.swap_left_right_anims = toggled_on

func _on_idle_anims_text_submitted(new_text: String) -> void:
	character.idle_anims = new_text.replace(", ", ",").split(",")



func _on_new_anim_pressed() -> void:
	var new_anim = load("res://backend/debug/character_editor/character_animation.tscn").instantiate()
	%AnimationsList.add_child(new_anim)

	new_anim.show_ghost.pressed.connect(_on_anim_show_ghost_pressed.bind(new_anim))
	new_anim.delete.pressed.connect(_on_anim_delete_pressed.bind(new_anim))

func _on_hide_ghost_pressed() -> void:
	character_ghost.visible = false
	%HideGhostButton.visible = false

func _on_anim_play_pressed(anim:CharacterAnimation) -> void:
	character.sprite.play_animation(anim.anim_name)
	character.sprite.offset = anim.anim_data.offset

func _on_anim_show_ghost_pressed(anim:CharacterAnimation) -> void:
	character_ghost.visible = true
	%HideGhostButton.visible = true
	character_ghost.sprite.play_animation(anim.anim_name)
	character_ghost.sprite.offset = anim.anim_data.offset

func _on_anim_delete_pressed(anim:CharacterAnimation) -> void:
	pass
