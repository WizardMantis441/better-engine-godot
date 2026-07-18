class_name PlayState2D
extends Node2D

@export var playstate:PlayState

@export var camera:Camera2D
@export var camera_positions:Array[Marker2D]

var initial_camera_zoom:Vector2

func _ready() -> void:
	initial_camera_zoom = camera.zoom
	
	SignalBus.connect("event_hit", Callable(self, "trigger_event"))

func _process(_delta: float) -> void:
	pass

func trigger_event(event):
	pass
