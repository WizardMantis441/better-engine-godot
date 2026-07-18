# SignalBus
# to emit:   SignalBus.emit_signal("signal_name", arg)
# to listen: SignalBus.connect("signal_name", Callable(self, "func_name"))

extends Node

@warning_ignore("unused_signal")
signal step_hit(step)
@warning_ignore("unused_signal")
signal beat_hit(beat)
@warning_ignore("unused_signal")
signal measure_hit(measure)

@warning_ignore("unused_signal")
signal load_note(note, group)

@warning_ignore("unused_signal")
signal note_hit(note, group)
@warning_ignore("unused_signal")
signal note_miss(note, group)

@warning_ignore("unused_signal")
signal event_hit(event)

@warning_ignore("unused_signal")
signal update_stats(stats)
