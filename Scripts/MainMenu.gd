extends CanvasLayer

func StartButton():
	Game.ins.HideMenu()
	Game.ins.ShowHUD()

func ExitButton():
	get_tree().quit()