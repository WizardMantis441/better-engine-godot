@tool
class_name CameraPositionMarker2D extends Marker2D
# HEAVILY INSPIRED FROM NOAH ENGINE.

@export var show_bounds: bool = true 
@export var bound_color: Color = Color.RED
@export_custom(PROPERTY_HINT_LINK, "") var bound_zoom: Vector2 = Vector2(1.0, 1.0)

var window_size: Vector2
func _ready():
	window_size = Vector2(
		ProjectSettings.get_setting_with_override(&"display/window/size/viewport_width"),
		ProjectSettings.get_setting_with_override(&"display/window/size/viewport_height")
	)
	
func _draw() -> void:
	if show_bounds and Engine.is_editor_hint():
		draw_set_transform(Vector2.ZERO, global_rotation, global_scale * bound_zoom)
		draw_rect(Rect2(-window_size * 0.5, window_size), bound_color, false)
	
func _process(_delta: float) -> void:
	queue_redraw()
