class_name CharacterAnimation extends PanelContainer

@onready var play: Button = $MarginContainer/VBoxContainer/HBoxContainer4/Play
@onready var show_ghost: Button = $MarginContainer/VBoxContainer/HBoxContainer4/Ghost
@onready var delete: Button = $MarginContainer/VBoxContainer/HBoxContainer4/Delete

var anim_name:String = ""
var anim_data:FunkinAnim = FunkinAnim.new()

func set_data(the_name:String, the_anim_data:FunkinAnim):
	anim_name = the_name
	anim_data = the_anim_data
	
	%AnimNameInput.text = anim_name
	%AnimPrefixInput.text = anim_data.animation_name
	%OffsetX.value = anim_data.offset.x
	%OffsetY.value = anim_data.offset.y
	%LoopInput.button_pressed = anim_data.loop

func _on_anim_name_submitted(new_text: String) -> void:
	anim_name = new_text

func _on_anim_prefix_submitted(new_text: String) -> void:
	anim_data.animation_name = new_text

func _on_offset_x_changed(value: float) -> void:
	anim_data.offset.x = value

func _on_offset_y_changed(value: float) -> void:
	anim_data.offset.y = value

func _on_loop_toggled(toggled_on: bool) -> void:
	anim_data.loop = toggled_on
