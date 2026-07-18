class_name PlayState extends Node

@export var hud:CanvasLayer

var song_data:FunkinSong
var instrumental:AudioStream
var voices:Array[AudioStream]

var stream_player:AudioStreamPlayer

var default_camera_zoom:Vector2 = Vector2(1, 1)

var bop_rate:int = 16
var bop_offset:int = 0

var scroll_speed:float = 1:
	set(v):
		scroll_speed = v
		for sl in [opponent_strumline, player_strumline]:
			if sl:
				sl.scroll_speed = v

var events:Array = []

var score:int = 0:
	set(v):
		score = v
		hud.score = v

var health:float = 50:
	set(v):
		health = v
		hud.health = v

var combo:int = 0

#var statistics:Statistics

"""
stats (FunkinStats)
	score (int)
	combo (int)
	max combo (int)
	tallies (FunkinTallies)
		sicks (int)
		goods (int)
		bads (int)
		shits (int)
		misses (int)
"""

func _ready() -> void:
	# TODO: SOMETHING FOR LOADING SONGS?
	#var diffs:Array = ["easy", "normal", "hard", "erect", "nightmare"]
	#var cur_diff:int = diffs.size() - 1
	#while cur_diff > 0 and !song_data.chart.notes.has(diffs[cur_diff]):
		#cur_diff -= 1
	#if diffs[cur_diff]:
		#load_song(diffs[cur_diff])
	#else:
		#print("couldnt find a chart difficulty")

	# TODO: SNAP CAMERA
	#var focus:int
	#if opponent_strumline: focus = 1
	#elif player_strumline: focus = 0
	#if focus:
		#var pos_smoothing = camera.position_smoothing_enabled
		#camera.position_smoothing_enabled = false
		#trigger_event("FocusCamera", focus, 0.0)
		#await get_tree().process_frame
		#camera.position_smoothing_enabled = pos_smoothing
	pass

func load_song(new_song_data:FunkinSong, difficulty:String = "hard"):
	song_data = new_song_data
	
	var audio_stream_sync = AudioStreamSynchronized.new()
	audio_stream_sync.stream_count = 1
	audio_stream_sync.set_sync_stream(0, instrumental)
	
	var i:int = 1
	for vocal:AudioStream in song_data.voices:
		audio_stream_sync.stream_count += 1
		audio_stream_sync.set_sync_stream(i, vocal)
		i += 1
	
	stream_player = AudioStreamPlayer.new()
	stream_player.stream = audio_stream_sync
	add_child(stream_player)
	
	# TODO: yeah
	#Conductor.load_bpm_changes(metadata.data.timeChanges)
	#Conductor.song_position = -5 * Conductor.crochet

	SignalBus.connect("step_hit", Callable(self, "step_hit"))
	SignalBus.connect("beat_hit", Callable(self, "beat_hit"))
	SignalBus.connect("measure_hit", Callable(self, "measure_hit"))

	for event in chart.data.events:
		events.append({"name": event.e, "value": event.v, "time": event.t})

	for beat in [-1, -2, -3, -4]:
		events.append({"name": "CountdownEvent", "value": beat, "time": beat * Conductor.crochet * 1000.0})

	events.sort_custom(func(a, b): return a["time"] < b["time"])
	
	for note in chart.data.notes[difficulty]:
		var sl_i = int(note.d / 4)
		var sl:StrumLine
		if sl_i == 0: sl = player_strumline
		elif sl_i == 1: sl = opponent_strumline
		if sl:
			sl.add_note(note)
	
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
			var current_camera = get_viewport().get_camera_2d()
			
			if value is not Dictionary: # classic
				var sl:StrumLine
				if value == 0: sl = player_strumline
				elif value == 1: sl = opponent_strumline
				else: return
				
				pos = sl.get_camera_position()
				
				var stage_offs = Vector2.ZERO
				if stage:
					var stage_offsets = [stage.player_camera_offset, stage.opponent_camera_offset, stage.gf_camera_offset]
					if value <= stage_offsets.size():
						stage_offs = stage_offsets[value]
				
				current_camera.position = pos + stage_offs
			else:
				var x:float = float(value.x) if value.has("x") else 0.0
				var y:float = float(value.y) if value.has("y") else 0.0
				# var _duration:float = value.duration # TODO: this
				var character:float = float(value.char)
				var tween_ease:String = value.ease if value.has("ease") else "CLASSIC"
				
				if tween_ease == "CLASSIC":
					trigger_event("FocusCamera", character, time)
					current_camera.position += Vector2(x, y)
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
			var zoom_ease:String = value.ease # default is "linear"
			
			camera_zoom_tween.set_parallel(true)
			#camera_zoom_tween.set_trans(Tween.TRANS_ELASTIC)
			#camera_zoom_tween.set_ease(Tween.EASE_IN_OUT)
			set_tween_trans_and_ease(camera_zoom_tween, zoom_ease)
			camera_zoom_tween.tween_property(self, "default_camera_zoom", zoom * (Vector2(stage.camera_zoom, stage.camera_zoom) if mode == "stage" else Vector2(1.0, 1.0)), duration)
			camera_zoom_tween.tween_property(get_viewport().get_camera_2d(), "zoom", zoom * (Vector2(stage.camera_zoom, stage.camera_zoom) if mode == "stage" else Vector2(1.0, 1.0)), duration)
			camera_zoom_tween.play()
			print(default_camera_zoom)

		"PlayAnimation":
			var target = value.target
			var anim = value.anim
			var force = value.force
			
			var sl:StrumLine
			if target in ["bf", "boyfriend", "player"]: sl = player_strumline
			elif target in ["dad", "opponent"]: sl = opponent_strumline
			
			if sl:
				for character in sl.characters:
					print("bruh")
					if character:
						character.play_animation(anim, 1, false, force)
