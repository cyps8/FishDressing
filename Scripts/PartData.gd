extends Resource

class_name PartData

enum Tag{ TEST = 1, HEAD = 2, UPPER = 4, LOWER = 8, ACCESSORY = 16, EXCLUSIVE = 32 }

enum MaterialSound{ DEFAULT = 0, FABRIC = 1, GLITCH = 2, HAIR = 3, METAL = 4, PLASTIC = 5, RUBBER  = 6, SHELL = 7, SOUP = 8, SQUISHY = 9, STICKER = 10, CHIRSTMAS = 11, GUITAR = 12, PIANO = 13, KISS = 14, ACOUSTIC = 15 }

@export var name: String = "default"

@export var texture: Texture2D

@export var colorShader: bool = false

@export var redChannel: bool = false
@export var defaultRed: Color = Color.WHITE

@export var greenChannel: bool = false
@export var defaultGreen: Color = Color.WHITE

@export var blueChannel: bool = false
@export var defaultBlue: Color = Color.WHITE

@export_flags("Test:1", "Head:2", "Upper:4", "Lower:8", "Accessory:16", "Exclusive:32") var tags: int = 0

@export_enum("Default:0", "Fabric:1", "Glitch:2", "Hair:3", "Metal:4", "Plastic:5", "Rubber:6", "Shell:7", "Soup:8", "Squishy:9", "Sticker:10", "Christmas:11", "Guitar:12", "Piano:13", "Kiss:14", "Acoustic:15") var materialSound: int = 0