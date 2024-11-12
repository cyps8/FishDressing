extends Action

class_name ActionMove

var delta: Array[Vector2]

func Create(_newParts: Array[Part], _startPos: Array[Vector2]):
	pass
	# for part in newParts:
	# 	parts.append(part)
	# for i in parts.size():
	# 	delta.append(parts[i].position - startPos[i])

func Undo():
	for i in parts.size():
		parts[i].position -= delta[i]

func Redo():
	for i in parts.size():
		parts[i].position += delta[i]
