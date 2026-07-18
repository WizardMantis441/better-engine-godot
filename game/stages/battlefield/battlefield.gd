extends Stage

@onready var watchtower: FunkinSprite = $Parallax2D7/Watchtower

func _ready() -> void:
	SignalBus.connect("step_hit", Callable(self, "step_hit"))
	
func step_hit(_step:int):
	watchtower.play("watchtower gradient color instance 1")
