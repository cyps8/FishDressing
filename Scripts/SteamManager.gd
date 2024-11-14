class_name SteamManager extends Node

var steamRunning: bool

func _ready():
	if OS.get_name() != "Web":
		steamRunning = false
		return

	Steam.steamInit()

	steamRunning = Steam.isSteamRunning()

	if !steamRunning:
		return

