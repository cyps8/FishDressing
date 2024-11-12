extends Action

class_name ActionScale

var delta: Array[float]

func Create(_newParts: Array[Part], _startScale: Array[float]):
	pass
	# for part in newParts:
	# 	parts.append(part)
	# for i in parts.size():
	# 	delta.append(parts[i].scale.x - startScale[i])

func Undo():
	for i in parts.size():
		parts[i].scale -= Vector2(delta[i], delta[i])

func Redo():
	for i in parts.size():
		parts[i].scale += Vector2(delta[i], delta[i])