class_name ComboSprite
extends Sprite2D

var velocity:Vector2 = Vector2(-randi_range(0, 10), -randi_range(140, 175))
var accel_y:float = 550

func _ready() -> void:	
	await get_tree().create_timer(Conductor.crochet).timeout
	
	var fade_twn = create_tween()
	fade_twn.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.2)
	
	await get_tree().create_timer(1).timeout
	self.queue_free()

func _process(delta: float) -> void:
	self.position += velocity * delta
	velocity.y += accel_y * delta
