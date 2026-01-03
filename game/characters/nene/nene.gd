extends Character

@onready var abot_body:AnimateSymbol = $ABOT/Body

func idle(step:int):
	super.idle(step)
	
	abot_body.frame = 0
	abot_body.playing = true
