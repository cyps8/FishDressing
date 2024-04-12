extends ScrollContainer

func _process(_delta):
	if !Game.ins.hud.mouseGrabbed:
		mouse_filter = Control.MOUSE_FILTER_PASS
	else:
		mouse_filter = Control.MOUSE_FILTER_IGNORE