extends Action

class_name ActionFlipH

var original: Array[bool]

func Create(newParts: Array[Part], startFlip: Array[bool]):
	for part in newParts:
		parts.append(part)
	for i in parts.size():
		original.append(startFlip[i])

func Undo():
	for i in parts.size():
		if parts[i].flip_h != original[i]:
			parts[i].FlipH()

func Redo():
	for i in parts.size():
		if parts[i].flip_h == original[i]:
			parts[i].FlipH()
