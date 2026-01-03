class_name Hud extends CanvasLayer

@onready var health_bar:ProgressBar = $"Healthbar BG/ProgressBar"
@onready var combo_group:Node2D = $Combo

var health:float = 50:
	set(v):
		health = v
		health_bar.value = v

func display_rating(rating_name:String = "good"):
	if rating_name == null: rating_name = "good"
	
	var rating = ComboSprite.new()
	rating.texture = load("res://game/hud/default/ratings/" + rating_name + ".png")
	rating.scale = Vector2(0.65, 0.65)
	combo_group.add_child(rating)

func display_combo(_combo:int = 0):
	pass

func countdown(beat:int = 0): # this setup makes more sense in my head bc they are played at negative beats
	match beat:
		-4:
			$"Countdown SFX/Three".play()
		-3:
			$"Countdown SFX/Two".play()
			show_countdown_image($Countdown/Ready)
		-2:
			$"Countdown SFX/One".play()
			show_countdown_image($Countdown/Set)
		-1:
			$"Countdown SFX/Go".play()
			show_countdown_image($Countdown/Go)

func show_countdown_image(image):
	image.visible = true
	create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).tween_property(image, "modulate:a", 0.0, Conductor.crochet)

func _process(_delta:float) -> void:
	offset.x = 640 * (1 - 1 * scale.x) 
	offset.y = 360 * (1 - 1 * scale.y) 
