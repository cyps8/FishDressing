extends Node

class_name DiscordRichPresence

static var ins: DiscordRichPresence

var startTime: int

func _init():
	ins = self

func SetUp():
	DiscordRPC.app_id = 1303839403910762567 # Application ID
	DiscordRPC.details = "A fish dress up game!"
	DiscordRPC.state = "In the ocean"
	DiscordRPC.large_image = "clownfish" # Image key from "Art Assets"
	DiscordRPC.large_image_text = "Clownfish"

	startTime = int(Time.get_unix_time_from_system())
	DiscordRPC.start_timestamp = startTime

	DiscordRPC.refresh()

func Update(msg: String, img: String = ""):
	DiscordRPC.state = msg
	if img != "":
		DiscordRPC.large_image = img
	DiscordRPC.refresh()