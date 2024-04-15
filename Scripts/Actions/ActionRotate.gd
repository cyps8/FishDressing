extends Action

class_name ActionRotate

var delta: Array[float]

func Create(newParts: Array[Part], startRot: Array[float]):
	for part in newParts:
		parts.append(part)
	for i in parts.size():
		delta.append(parts[i].rotation - startRot[i])

func Undo():
	for i in parts.size():
		parts[i].rotation -= delta[i]

func Redo():
	for i in parts.size():
		parts[i].rotation += delta[i]
