extends Node2D

@onready var pieces:Array = [$"1", $"2", $"3", $"4", $"5", $"6", $"7"]

func _process(_delta: float) -> void:
	for p in pieces:
		var i = pieces.find(p)
		var f = round((sin(Conductor.song_position * 10.0 + i * 0.5) / 2.0 + 0.5) * 6)
		p.frame = f
		p.visible = f != 6
