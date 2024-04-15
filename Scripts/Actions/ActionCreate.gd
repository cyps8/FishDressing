extends Action

class_name ActionCreate

var indexes: Array[int]

func Create(newParts: Array[Part]):
    for part in newParts:
        parts.append(part)
    parts.sort_custom(func (a, b): return a.get_index() < b.get_index())
    for part in parts:
        indexes.append(part.get_index())

func Undo():
    for part in parts:
        part.SetControlGroup(false)
        part.get_parent().remove_child(part)
        Game.ins.hud.partsGraveyard.append(part)

func Redo():
    for i in parts.size():
        Game.ins.hud.fishRef.add_child(parts[i])
        Game.ins.hud.fishRef.move_child(parts[i], indexes[i])
        Game.ins.hud.partsGraveyard.erase(parts[i])