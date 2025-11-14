class_name SteamManager extends Node

var steamRunning: bool

static var ins: SteamManager

func _init():
	ins = self

func _ready():
	if OS.get_name() == "Web":
		steamRunning = false
		return

	Steam.steamInit()

	steamRunning = Steam.isSteamRunning()

	if !steamRunning:
		return

func SetRPMenu():
	if !steamRunning:
		return
	Steam.setRichPresence("steam_display", "#Ocean")

func SetRPDressing():
	if !steamRunning:
		return
	Steam.setRichPresence("fish", Game.ins.selectedFish.name)
	Steam.setRichPresence("steam_display", "#DressingFish")

func UnlockAchievement(achievement: String):
	if !steamRunning || Game.ins.demo:
		return
	var chieve = Steam.getAchievement(achievement)
	if chieve.ret && !chieve.achieved:
		Steam.setAchievement(achievement)
		Steam.storeStats()

func IncFishDressed():
	if !steamRunning:
		return
	var fishDressed: int = Steam.getStatInt("FishDressed")
	Steam.setStatInt("FishDressed", fishDressed + 1)

	var totalFishDressed: int = Steam.getStatInt("TotalFishDressed")
	Steam.setStatInt("TotalFishDressed", totalFishDressed + 1)

	Steam.storeStats()

func IncPartsCreated():
	if !steamRunning:
		return
	var partsCreated: int = Steam.getStatInt("PartsCreated")
	Steam.setStatInt("PartsCreated", partsCreated + 1)

	var totalPartsCreated: int = Steam.getStatInt("TotalPartsCreated")
	Steam.setStatInt("TotalPartsCreated", totalPartsCreated + 1)

	Steam.storeStats()

func IncFishKissed():
	if !steamRunning:
		return
	var fishKissed: int = Steam.getStatInt("FishKissed")
	Steam.setStatInt("FishKissed", fishKissed + 1)

	print(fishKissed)

	var totalFishKissed: int = Steam.getStatInt("TotalFishKissed")
	Steam.setStatInt("TotalFishKissed", totalFishKissed + 1)

	Steam.storeStats()

func GetFishDressed() -> int:
	if !steamRunning:
		return 0
	return Steam.getStatInt("TotalFishDressed")

func GetFishKissed() -> int:
	if !steamRunning:
		return 0
	return Steam.getStatInt("TotalFishKissed")

func GetPartsCreated() -> int:
	if !steamRunning:
		return 0
	return Steam.getStatInt("TotalPartsCreated")