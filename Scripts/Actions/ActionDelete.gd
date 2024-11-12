extends Action

class_name ActionDelete

var positions: Array[Vector2]

var rotations: Array[float]

var scales: Array[float]

var indexes: Array[int]

var flipHs: Array[bool]

var flipVs: Array[bool]

func Create(_newParts: Array[Part], _prevPositions: Array[Vector2], _prevIndexes: Array[int], _prevRotations: Array[float], _prevScales: Array[float], _prevFlipHs: Array[bool], _prevFlipVs: Array[bool]):
	pass
	# for part in newParts:
	# 	parts.append(part)
	# #parts.sort_custom(func (a, b): return a.get_index() < b.get_index())
	# for i in parts.size():
	# 	indexes.append(prevIndexes[i])
	# 	positions.append(prevPositions[i])
	# 	rotations.append(prevRotations[i])
	# 	scales.append(prevScales[i])
	# 	flipHs.append(prevFlipHs[i])
	# 	flipVs.append(prevFlipVs[i])

func Undo():
	for i in parts.size():
		if !parts[i].UndoWhileDeleting():
			Game.ins.hud.fishRef.add_child(parts[i])
			Game.ins.hud.fishRef.move_child(parts[i], indexes[i])
			Game.ins.hud.partsGraveyard.erase(parts[i])
		parts[i].position = positions[i]
		parts[i].rotation = rotations[i]
		parts[i].scale = Vector2(scales[i], scales[i])
		parts[i].flip_h = flipHs[i]
		parts[i].flip_v = flipVs[i]
		parts[i].ResetMoveValues(true)

func Redo():
	for part in parts:
		part.SetControlGroup(false)
		part.get_parent().remove_child(part)
		Game.ins.hud.partsGraveyard.append(part)
	
