extends CanvasLayer

var cur_volume:int = 10 # TODO: save value on window close
var visible_timer:float = 0.0

@onready var sfx_up:AudioStreamPlayer = $Audio/Up
@onready var sfx_down:AudioStreamPlayer = $Audio/Down
@onready var sfx_max:AudioStreamPlayer = $Audio/Max

@onready var box:Sprite2D = $Background
@onready var bars:Array[Sprite2D] = [$Background/Bars1, $Background/Bars2, $Background/Bars3, $Background/Bars4, $Background/Bars5, $Background/Bars6, $Background/Bars7, $Background/Bars8, $Background/Bars9, $Background/Bars10]

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("volume_up"):
		change_volume(1)
	elif Input.is_action_just_pressed("volume_down"):
		change_volume(-1)
	
	visible_timer = max(visible_timer - delta, 0.0)
	box.position.y = lerp(box.position.y, 50.0 if visible_timer != 0.0 else -50.0, 0.1)
	box.modulate.a = lerp(box.modulate.a, 1.0 if visible_timer != 0.0 else 0.0, 0.1)

func change_volume(amt:int = 0):
	visible_timer = 1.0
	
	var prev_volume := cur_volume
	cur_volume = clampi(cur_volume + amt, 0, 10)
	
	var master_bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(master_bus, cur_volume / 10.0)
	
	if cur_volume > prev_volume: sfx_up.play()
	elif cur_volume < prev_volume: sfx_down.play()
	else: sfx_max.play()
	
	for bar in bars:
		bar.visible = bar == bars[cur_volume - 1] if cur_volume != 0 else false
