extends Node

func set_tween_trans_and_ease(tween:Tween, _str:String):
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
	
	var found_type:bool = false
	for type in trans.keys():
		if _str.begins_with(type):
			found_type = true
			tween.set_trans(trans.get(type))
			break
	
	if !found_type:
		tween.set_trans(Tween.TRANS_LINEAR)

	found_type = false
	for type in eases.keys():
		if _str.ends_with(type):
			found_type = true
			tween.set_ease(eases.get(type))
			break

	if !found_type:
		tween.set_ease(Tween.EASE_OUT)
