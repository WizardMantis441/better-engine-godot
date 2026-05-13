extends Control

@onready var viewport = %SubViewport
@onready var opponent_strumline = %OpponentStrumline
@onready var player_strumline = %PlayerStrumline

var instrumental:AudioStream
var chart:Dictionary
var metadata:Dictionary

var stream_player:AudioStreamPlayer
var events:Array = []
var difficulty:String = "hard"

var snaps:Array[int] = [16]
var snap:int = 16

func _ready():
	var dialogue = FileDialog.new()
	dialogue.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialogue.current_dir = "res://game/songs/"
	dialogue.add_filter("*.tscn")

	add_child(dialogue)
	dialogue.popup_centered()
	dialogue.file_selected.connect(func(file_path):
		load_song(load(file_path))
	)

func load_song(scene:PackedScene):
	var scn = scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	
	if "instrumental" in scn:	instrumental = scn.instrumental
	if "chart" in scn:			chart = scn.chart.data
	if "metadata" in scn:		metadata = scn.metadata.data

	if "opponent_strumline" in scn:
		if "vocal" in scn.opponent_strumline:
			opponent_strumline.vocal = scn.opponent_strumline.vocal
			
	if "player_strumline" in scn:
		if "vocal" in scn.player_strumline:
			player_strumline.vocal = scn.player_strumline.vocal
	
	# TODO: everything below this is ripped from playstate, maybe make it a static function somehow?
	
	var audio_stream_sync = AudioStreamSynchronized.new()
	audio_stream_sync.stream_count = 1
	audio_stream_sync.set_sync_stream(0, instrumental)
	
	var i:int = 1
	for sl in [opponent_strumline, player_strumline]:
		if sl and sl.vocal:
			audio_stream_sync.stream_count += 1
			audio_stream_sync.set_sync_stream(i, sl.vocal)
			i += 1
	
	stream_player = AudioStreamPlayer.new()
	stream_player.stream = audio_stream_sync
	add_child(stream_player)
	
	assert(chart != null, "No chart!")
	assert(metadata != null, "No metadata!")
	
	Conductor.load_bpm_changes(metadata.timeChanges)
	Conductor.step_hit.connect(step_hit)
	Conductor.beat_hit.connect(beat_hit)
	Conductor.measure_hit.connect(measure_hit)
	Conductor.song_position = 0
	
	for event in chart.events:
		events.append({"name": event.e, "value": event.v, "time": event.t})

	events.sort_custom(func(a, b): return a["time"] < b["time"])
	
	for note in chart.notes[difficulty]:
		var sl_i = int(note.d / 4)
		var sl:StrumLine
		if sl_i == 0: sl = player_strumline
		elif sl_i == 1: sl = opponent_strumline
		if sl:
			sl.add_note(note)
	
	if chart.has("scrollSpeed"):
		opponent_strumline.scroll_speed = chart.scrollSpeed[difficulty]
		player_strumline.scroll_speed = chart.scrollSpeed[difficulty]

func _process(_delta: float) -> void:
	if not stream_player:
		return

	if Input.is_action_just_pressed("ui_accept"):
		if stream_player.playing:
			stream_player.stop()
		else:
			stream_player.play(Conductor.song_position)
	
	if Input.is_action_just_pressed("ui_up"):
		if stream_player.playing: stream_player.stop()
		set_time(Conductor.get_time_at_step(round((Conductor.cur_step_float - 1) * snap) / snap))
		
	if Input.is_action_just_pressed("ui_down"):
		if stream_player.playing: stream_player.stop()
		set_time(Conductor.get_time_at_step(round((Conductor.cur_step_float + 1) * snap) / snap))
	
	if stream_player.playing:
		set_time(stream_player.get_playback_position())

func _input(event):
	if event is InputEventKey:
		if event.pressed and (event as InputEventKey).keycode == KEY_1:
			var noteArr = opponent_strumline.notes.filter(func(n): return n.id == 0 and is_equal_approx(n.time / 1000, Conductor.song_position))
			print(noteArr)
			if noteArr.is_empty():
				opponent_strumline.add_note({"d": 4, "t": Conductor.song_position * 1000.0, "l": 0})
			else:
				var n = noteArr[0]
				opponent_strumline.notes.erase(n)
				n.queue_free()

func format_time(t: float) -> String:
	@warning_ignore("integer_division")
	var minutes = int(t) / 60
	var seconds = int(t) % 60
	var milliseconds = int((t - int(t)) * 1000)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

func set_time(time:float):
	time = clamp(time, 0, stream_player.stream.get_length())
	
	Conductor.song_position = time
	Conductor.update_time()
	
	%GridLineParallax.scroll_offset.y = -Conductor.cur_step_float * 150 / 2
	%GridLineParallax.repeat_size.y = 150 * 2
	$VBoxContainer/PanelContainer2/Footer/LeftLabel.text = format_time(time) + " - " + format_time(stream_player.stream.get_length())

func step_hit(_step:int):
	pass
	
func beat_hit(_beat:int):
	pass

func measure_hit(_measure:int):
	pass
