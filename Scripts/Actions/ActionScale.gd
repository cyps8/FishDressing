extends Action

class_name ActionScale

var delta: Array[float]

func Create(newParts: Array[Part], startScale: Array[float]):
	for part in newParts:
		parts.append(part)
	for i in parts.size():
		delta.append(parts[i].scale.x - startScale[i])

func Undo():
	for i in parts.size():
		parts[i].scale -= Vector2(delta[i], delta[i])

func Redo():
	for i in parts.size():
		parts[i].scale += Vector2(delta[i], delta[i])