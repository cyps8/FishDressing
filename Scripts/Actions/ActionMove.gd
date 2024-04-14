extends Action

var parts: Array[Part]
var delta: Array[Vector2]

func Create(newParts: Array[Part], startPos: Array[Vector2]):
    parts = newParts
    for i in parts.size():
        delta.append(parts[i].position - startPos[i])

func Undo():
    for i in parts.size():
        parts[i].position -= delta[i]

func Redo():
    for i in parts.size():
        parts[i].position += delta[i]