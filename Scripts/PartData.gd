extends Resource

class_name PartData

enum Tag{ TEST = 1, HEAD = 2, UPPER = 4, LOWER = 8, ACCESSORY = 16 }

@export var name: String = "default"

@export var texture: Texture2D

@export var colorShader: bool = false

@export var redChannel: bool = false
@export var defaultRed: Color = Color.WHITE

@export var greenChannel: bool = false
@export var defaultGreen: Color = Color.WHITE

@export var blueChannel: bool = false
@export var defaultBlue: Color = Color.WHITE

@export_flags("Test:1", "Head:2", "Upper:4", "Lower:8", "Accessory:16") var tags: int = 0