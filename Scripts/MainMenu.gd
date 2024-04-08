extends CanvasLayer

var menuActive: bool = true

func StartButton():
	if !menuActive:
		return
	Game.ins.HideMenu()
	Game.ins.ShowFish()
	Game.ins.ShowFishPicker()

func SettingsButton():
	if !menuActive:
		return
	Game.ins.ShowSettings()

func SetActive(value: bool):
	menuActive = value

func ExitButton():
	if !menuActive:
		return
	get_tree().quit()