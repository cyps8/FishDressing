extends Action

class_name ActionRotate

var delta: Array[float]

func Create(_newParts: Array[Part], _startRot: Array[float]):
	pass
	# for part in newParts:
	# 	parts.append(part)
	# for i in parts.size():
	# 	delta.append(parts[i].rotation - startRot[i])

func Undo():
	for i in parts.size():
		parts[i].rotation -= delta[i]

func Redo():
	for i in parts.size():
		parts[i].rotation += delta[i]
