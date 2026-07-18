class_name Hud extends CanvasLayer

@export var lerp_to_target_scale:bool = true
@export var target_scale:Vector2 = Vector2(1, 1)
@export var target_scale_weight:float = 0.04

@onready var health_bar:ProgressBar = $"Healthbar BG/ProgressBar"
@onready var icon_group:Node2D = $Icons
@onready var opponent_icon:Sprite2D = $Icons/Opponent
@onready var player_icon:Sprite2D = $Icons/Player
@onready var combo_group:Node2D = $Combo

var health:float = 50:
	set(v):
		health_bar.value = v
		health = health_bar.value

var score:int = 0:
	set(v):
		score = v
		$"Healthbar BG/Label".text = "Score: " + str(score)

func _ready() -> void:
	SignalBus.connect("step_hit", Callable(self, "step_hit"))

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

func _process(delta:float) -> void:
	if lerp_to_target_scale:
		scale = lerp(scale, target_scale, target_scale_weight)
	
	offset.x = 640 * (1 - 1 * scale.x) 
	offset.y = 360 * (1 - 1 * scale.y) 
	
	# TODO: if i want icons to be more accurate use smoothLerpPosition
	# https://github.com/FunkinCrew/Funkin/blob/main/source/funkin/play/components/HealthIcon.hx#L234
	
	if icon_group:
		icon_group.scale = Vector2(1, 1).max(icon_group.scale - Vector2(delta, delta))
		icon_group.position.x = remap(health, 0, 100, health_bar.global_position.x + health_bar.size.x, health_bar.global_position.x) # TODO: lerp this better

func step_hit(step:int):
	if step % 4 == 0:
		icon_group.scale = Vector2(1.2, 1.2)
