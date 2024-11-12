extends Action

class_name ActionLayer

var delta: Array[int]

func Create(_newParts: Array[Part], _startLayer: Array[int]):
	pass
	# for part in newParts:
	# 	parts.append(part)
	# for i in parts.size():
	# 	delta.append(parts[i].get_index() - startLayer[i])

func Undo():
	for i in parts.size():
		Game.ins.hud.fishRef.move_child(parts[i], parts[i].get_index() - delta[i])

func Redo():
	for i in parts.size():
		Game.ins.hud.fishRef.move_child(parts[i], parts[i].get_index() + delta[i])