class_name Note
extends AnimatedSprite2D

@onready var strum:Strum = self.get_parent()
@onready var strum_line:StrumLine = strum.get_parent()

var id:int = 0:
	set(value):
		id = value
		self.play(["left", "down", "up", "right"][id])

var time:float = 0
var length:float = 0
var kind:String = ""

var scroll_speed:float = 1.0

var can_hit:bool = true

func hit():
	for character in strum_line.characters:
		character.play_animation(["singLEFT", "singDOWN", "singUP", "singRIGHT"][id % 4])
	
	if strum.cpu:
		strum.press(true)
		self.queue_free()
		return
	
	var ms_offset:int = int(Conductor.song_position * 1000.0 - time)
	var rating:String = judge(ms_offset)
	var score:int = score(ms_offset)
	
	var health_change:float = 0.0
	var is_combo_break:bool = false
	
	match rating:
		"sick":
			health_change = 0.03 * 50
			strum.splash()
		"good":
			health_change = 0.015 * 50
		"bad":
			is_combo_break = true
		"shit":
			health_change = -0.02 * 50
			is_combo_break = true
	
	if rating in ["bad", "shit"]:
		can_hit = false
		self.modulate.a *= 0.5
	else:
		self.queue_free()
	
	strum.press(true)
	strum_line.hud.display_rating(rating)
	# game.combo ++;
	# game.score += score;
	# game.health += health_change;
	# game.popUpScore(rating);

func miss():
	pass

func score(ms:int):
	var abs_ms = abs(ms)
	if abs_ms > 160: return 0 # miss
	if abs_ms < 5: return 500 # perfect
	
	var scoring_slope:float = 0.080
	var scoring_offset:float = 54.99
	var min_score:float = 9.0
	var max_score:int = 500
	
	var factor:float = 1.0 - (1.0 / (1.0 + exp(-scoring_slope * (abs_ms - scoring_offset))))
	return int(max_score * factor + min_score)

func judge(ms:int):
	var t = abs(ms)
	if t < 45: return "sick"
	if t < 90: return "good"
	if t < 135: return "bad"
	if t < 160: return "shit"
	return "miss"

func _process(_delta: float) -> void:
	self.position.y = (time - Conductor.song_position * 1000.0) * 0.45 * scroll_speed
