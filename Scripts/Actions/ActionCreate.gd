extends Action

var parts: Array[Part]
var indexes: Array[int]

func Create(newParts: Array[Part]):
    parts = newParts
    parts.sort_custom(func (a, b): return a.get_index() < b.get_index())
    for part in parts:
        indexes.append(part.get_index())

func Undo():
    for part in parts:
        part.get_parent().remove_child(part)

func Redo():
    for i in parts.size():
        Game.ins.hud.fishRef.add_child(parts[i])
        parts[i].set_index(indexes[i])