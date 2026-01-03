extends Node

signal step_hit(step:int)
signal beat_hit(beat:int)
signal measure_hit(measure:int)

var bpm:float = 100.0
var bpm_changes:Array = [] # { "time": float, "step": int, "new_bpm": float }
var time_signature:Array[int] = [4, 4] # [beats per measure, measures per phrase]
var crochet:float:
	get: return (60.0 / bpm)
	
var song_position:float = 0.0
var song_offset:float = 0.0

var cur_step:int = 0
var cur_step_float:float = 0.0
var cur_beat:int = 0
var cur_beat_float:float = 0.0
var cur_measure:int = 0
var cur_measure_float:float = 0.0

func update_time():
	var old_step:int = cur_step

	var cur_bpm_change:int = 0
	if bpm_changes.size() > 1:
		while cur_bpm_change < bpm_changes.size() - 1 and song_position + song_offset >= bpm_changes[cur_bpm_change + 1]["time"]:
			cur_bpm_change += 1

	if bpm_changes.size() > 0 and bpm != bpm_changes[cur_bpm_change]["new_bpm"]:
		bpm = bpm_changes[cur_bpm_change]["new_bpm"]

	if bpm_changes.is_empty():
		cur_step = int(floor((song_position + song_offset) / (crochet / 4.0)))
	else:
		var change = bpm_changes[cur_bpm_change]
		cur_step = change["step"] + int(floor((song_position + song_offset - change["time"]) / (crochet / 4.0)))

	cur_beat = int(floor(cur_step / 4.0))
	cur_measure = int(floor(cur_beat / 4.0))

	cur_step_float = (song_position + song_offset) / (crochet / 4.0)
	cur_beat_float = cur_step_float / 4.0
	cur_measure_float = cur_beat_float / 4.0

	if old_step != cur_step:
		step_hit.emit(cur_step) # these could lowkirkerfadeperchenuinely be setters :eyes:
		if cur_step % 4 == 0:
			beat_hit.emit(cur_beat)
			if cur_beat % 4 == 0:
				measure_hit.emit(cur_measure)

func load_bpm_changes(bpms:Array):
	bpm_changes.clear()
	
	bpm = 100.0
	time_signature = [4, 4]
	
	var last_time: float = 0.0
	var last_bpm: float = bpm
	var current_step: int = 0

	for bpm_change in bpms:
		var step_time = int(floor((bpm_change["t"] - last_time) / ((60.0 / last_bpm) / 4.0)))
		current_step += step_time

		bpm_changes.append({
			"time": bpm_change["t"],
			"step": current_step,
			"new_bpm": bpm_change["bpm"]
		})

		last_time = bpm_change["t"]
		last_bpm = bpm_change["bpm"]
	
	bpm = bpm_changes[0]["new_bpm"]
	time_signature = [4, 4] # haven't done that yet
