extends CanvasLayer

func StartButton():
	Game.ins.HideMenu()
	Game.ins.ShowFish()
	Game.ins.ShowFishPicker()

func ExitButton():
	get_tree().quit()