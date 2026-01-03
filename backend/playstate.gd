extends Node
class_name PlayState

@export_subgroup("HUD")
@export var hud:CanvasLayer
@export var strum_lines:Array[StrumLine]

@export_subgroup("Song Data")
@export var instrumental:AudioStream
@export var chart:JSON
@export var metadata:JSON

@export_subgroup("")
@export var camera:Camera2D
@export var stage:Stage

var stream_player:AudioStreamPlayer

var default_camera_zoom:Vector2 = Vector2(1, 1)
var default_camera_zoom_weight:float = 0.04
var default_hud_zoom:Vector2 = Vector2(1, 1)
var default_hud_zoom_weight:float = 0.04

var bop_rate:int = 16
var bop_offset:int = 0

var scroll_speed:float = 1:
	set(v):
		scroll_speed = v
		for sl in strum_lines:
			sl.scroll_speed = v

var events:Array = []

func _ready() -> void:
	# TODO: funkin_camera.gd that adds a default zoom and basic easing stuff
	default_camera_zoom = get_viewport().get_camera_2d().zoom

	var diffs:Array = ["easy", "normal", "hard", "erect", "nightmare"]
	var cur_diff:int = diffs.size() - 1
	while cur_diff > 0 and !chart.data.notes.has(diffs[cur_diff]):
		cur_diff -= 1

	if diffs[cur_diff]:
		load_song(diffs[cur_diff])
	else:
		print("couldnt find a chart difficulty")

func load_song(difficulty:String = "hard"):
	var audio_stream_sync = AudioStreamSynchronized.new()
	audio_stream_sync.stream_count = 1
	audio_stream_sync.set_sync_stream(0, instrumental)
	
	for i in range(strum_lines.size()):
		var sl = strum_lines[i]
		if sl.vocal:
			audio_stream_sync.stream_count += 1
			audio_stream_sync.set_sync_stream(i + 1, sl.vocal)
	
	stream_player = AudioStreamPlayer.new()
	stream_player.stream = audio_stream_sync
	add_child(stream_player)
	#stream_player.play()
	
	assert(chart != null, "No chart!")
	assert(metadata != null, "No metadata!")
	
	Conductor.load_bpm_changes(metadata.data.timeChanges)
	Conductor.step_hit.connect(step_hit)
	Conductor.beat_hit.connect(beat_hit)
	Conductor.measure_hit.connect(measure_hit)
	Conductor.song_position = -5 * Conductor.crochet
	
	for beat in [-1, -2, -3, -4]:
		events.append({"name": "CountdownEvent", "value": beat, "time": beat * Conductor.crochet * 1000.0})
	
	for event in chart.data.events:
		events.append({"name": event.e, "value": event.v, "time": event.t})
	
	events.sort_custom(func(a, b): return a["time"] < b["time"])
	
	# TODO: all focus camera events are forced if t <= 0
	
	for note in chart.data.notes[difficulty]:
		var s_line_index = int(note.d / 4)
		if s_line_index > strum_lines.size():
			print("oh nah.")
		else:
			var s_line = strum_lines[s_line_index]
			s_line.add_note(note)
	
	if chart.data.has("scrollSpeed"):
		scroll_speed = chart.data.scrollSpeed[difficulty]

func _process(delta: float) -> void:
	if Conductor.song_position < 0.0:
		Conductor.song_position = min(Conductor.song_position + delta, 0.0)
	elif !stream_player.playing:
		stream_player.play()
	else:
		Conductor.song_position = stream_player.get_playback_position()
	
	Conductor.update_time()
	
	if !events.is_empty() and events[0].time <= Conductor.song_position * 1000.0:
		var e = events.pop_front()
		trigger_event(e.name, e.value, e.time)
	
	camera.zoom = lerp(camera.zoom, default_camera_zoom, default_camera_zoom_weight)
	hud.scale = lerp(hud.scale, default_hud_zoom, default_camera_zoom_weight)

func step_hit(step:int):
	if (step + bop_offset) % bop_rate == 0:
		camera.zoom += Vector2(0.03, 0.03)
		hud.scale += Vector2(0.015, 0.015)

func beat_hit(_beat:int):
	pass

func measure_hit(_measure:int):
	pass

func trigger_event(event_name:String, value, time:float):
	print("NEW EVENT! [event_name='" + str(event_name) + "', value='" + str(value) + "', time='" + str(time) + "']")

	match event_name:
		"CountdownEvent":
			hud.countdown(value)
		
		"FocusCamera": # TODO: move to funkin_camera function
			var pos:Vector2 = Vector2.ZERO
			
			if value is not Dictionary: # classic
				var sum:Vector2 = Vector2.ZERO
				if strum_lines[value].characters.size() > 0:
					for character in strum_lines[value].characters:
						sum += (character.sprite.global_position + character.camera_offset)
					sum /= strum_lines[value].characters.size()
					pos += sum
				
				var stage_offs = Vector2.ZERO
				if stage:
					var stage_offsets = [stage.player_camera_offset, stage.opponent_camera_offset, stage.gf_camera_offset]
					if value <= stage_offsets.size():
						stage_offs = stage_offsets[value]
				
				get_viewport().get_camera_2d().position = pos + stage_offs
			else:
				var x:float = float(value.x) if value.has("x") else 0.0
				var y:float = float(value.y) if value.has("y") else 0.0
				# var _duration:float = value.duration # TODO: this
				var character:float = float(value.char)
				var tween_ease:String = value.ease if value.has("ease") else "CLASSIC"
				
				if tween_ease == "CLASSIC":
					trigger_event("FocusCamera", character, time)
					get_viewport().get_camera_2d().position += Vector2(x, y)
					return
				else:
					pass # TODO: this
		
		"ZoomCamera": #TODO: move to funkin_camera function
			#if camera_zoom_tween:
				#pass
				##camera_zoom_tween.stop()
			#else:
			
			var camera_zoom_tween = create_tween()
			
			var zoom = Vector2(value.zoom, value.zoom) if value.has("zoom") else Vector2(1.0, 1.0)
			var duration = (value.duration if value.has("duration") else 4.0) * Conductor.crochet / 4.0
			var mode = value.mode if value.has("mode") else "stage"
			#var ease = value.ease # default is "linear"
			
			camera_zoom_tween.set_parallel(true)
			camera_zoom_tween.set_trans(Tween.TRANS_ELASTIC)
			camera_zoom_tween.set_ease(Tween.EASE_IN_OUT)
			camera_zoom_tween.tween_property(self, "default_camera_zoom", zoom * (Vector2(stage.camera_zoom, stage.camera_zoom) if mode == "stage" else Vector2(1.0, 1.0)), duration)
			camera_zoom_tween.tween_property(get_viewport().get_camera_2d(), "zoom", zoom * (Vector2(stage.camera_zoom, stage.camera_zoom) if mode == "stage" else Vector2(1.0, 1.0)), duration)
			camera_zoom_tween.play()
			print(default_camera_zoom)

		"PlayAnimation":
			var target = value.target
			var anim = value.anim
			# var force = value.force
			
			var sl_index = 2
			if target in ["bf", "boyfriend", "player"]: sl_index = 0
			elif target in ["dad", "opponent"]: sl_index = 1
			
			if strum_lines.size() <= sl_index:
				for character in strum_lines[sl_index].characters:
					character.play_animation(anim) # TODO: force?

func set_tween_trans_and_ease(tween:Tween, str:String):
	var trans = {
		"back": Tween.TRANS_BACK,
		"bounce": Tween.TRANS_BOUNCE,
		"circ": Tween.TRANS_CIRC,
		"cube": Tween.TRANS_CUBIC,
		"elastic": Tween.TRANS_ELASTIC,
		"expo": Tween.TRANS_EXPO,
		"linear": Tween.TRANS_LINEAR,
		"quad": Tween.TRANS_QUAD,
		"quart": Tween.TRANS_QUART,
		"quint": Tween.TRANS_QUINT,
		"sine": Tween.TRANS_SINE,
		"smoothStep": Tween.TRANS_LINEAR, # idk
		"smootherStep": Tween.TRANS_LINEAR, # idk
	}
	
	var eases = {
		"In": Tween.EASE_IN,
		"InOut": Tween.EASE_IN_OUT,
		"Out": Tween.EASE_OUT
	}
	
	for type in trans.keys():
		if str.begins_with(type):
			tween.set_trans(trans.get(type))
			break

	for type in eases.keys():
		if str.ends_with(type):
			tween.set_ease(eases.get(type))
			break
