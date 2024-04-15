extends Action

class_name ActionFlipV

var original: Array[bool]

func Create(newParts: Array[Part], startFlip: Array[bool]):
	for part in newParts:
		parts.append(part)
	for i in parts.size():
		original.append(startFlip[i])

func Undo():
	for i in parts.size():
		if parts[i].flip_v != original[i]:
			parts[i].FlipV()

func Redo():
	for i in parts.size():
		if parts[i].flip_v == original[i]:
			parts[i].FlipV()