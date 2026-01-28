class_name StrumLine
extends Node2D

var animations = ["Left", "Down", "Up", "Right"]

@onready var hud:Hud = self.get_parent()

@export var vocal:AudioStream
var vocal_sync_index:int

@export var characters:Array[Character]

@onready var strums = [$Left, $Down, $Up, $Right]
@export var cpu:bool = false:
	set(v):
		cpu = v
		if strums:
			for strum in strums:
				strum.cpu = v

var notes:Array[Note] = []

var scroll_speed:float = 1:
	set(v):
		scroll_speed = v
		for note in notes:
			note.scroll_speed = v

func _ready() -> void:
	for strum in strums:
		strum.cpu = cpu

func _process(_delta:float) -> void:
	if cpu:
		for note in notes:
			if Conductor.song_position * 1000.0 >= note.time:
				strums[note.id].press(true)
				notes.erase(note)
				note.hit()
	else:
		var hitzone = 160
		
		var missed_notes = notes.filter(func(n): return Conductor.song_position * 1000.0 - hitzone > n.time)
		for note in missed_notes:
			notes.erase(note)
			note.miss()
		
		var inputs = [Input.is_action_just_pressed("left"), Input.is_action_just_pressed("down"), Input.is_action_just_pressed("up"), Input.is_action_just_pressed("right")]
		var releases = [Input.is_action_just_released("left"), Input.is_action_just_released("down"), Input.is_action_just_released("up"), Input.is_action_just_released("right")]
		
		for i in range(inputs.size()):
			if inputs[i]:
				var possible_notes = notes.filter(func(n): return abs(Conductor.song_position * 1000.0 - n.time) < hitzone and n.id == i)
				
				if possible_notes.size() == 0:
					strums[i].press()
					# no ghost tapping would miss here
				else:
					possible_notes[0].hit()
					
					var notes_to_clear = possible_notes.filter(func(n): return abs(possible_notes[0].time - n.time) < 2) # stacked notes
					for n in notes_to_clear:
						notes.erase(n)
						if n != possible_notes[0]:
							n.queue_free()
			
			if releases[i]:
				if strums[i].held_note != null:
					# the min amt of the hold note in ms before the player
					# gets penalized for letting go of it early
					if strums[i].held_note.length < 160:
						strums[i].unhold()
						print("ok :]")
					else:
						strums[i].held_note.miss()
						print("MISSED!!!!!!!")
					
				if !strums[i].animation.begins_with("static"):
					strums[i].play("static" + animations[i])

func add_note(note):
	var new_note = preload("res://backend/objects/gameplay/note.tscn").instantiate()
	strums[int(note.d) % strums.size()].add_child(new_note)
	
	new_note.id = int(note.d) % strums.size()
	new_note.time = note.t
	if note.has("l"):
		new_note.length = note.l
		
	notes.append(new_note)

func get_camera_position() -> Vector2:
	var sum = Vector2.ZERO
	if characters.is_empty(): return sum
	
	for character in characters:
		sum += character.get_camera_position()
	
	sum /= characters.size()
	return sum
