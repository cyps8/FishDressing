extends Action

class_name ActionLayer

var delta: Array[int]

func Create(newParts: Array[Part], startLayer: Array[int]):
	for part in newParts:
		parts.append(part)
	for i in parts.size():
		delta.append(parts[i].get_index() - startLayer[i])

func Undo():
	for i in parts.size():
		Game.ins.hud.fishRef.move_child(parts[i], parts[i].get_index() - delta[i])

func Redo():
	for i in parts.size():
		Game.ins.hud.fishRef.move_child(parts[i], parts[i].get_index() + delta[i])