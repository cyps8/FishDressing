extends Resource

class_name PartData

enum Tag{ TEST = 1, HAT = 2, GLASSES = 4 }

@export var name: String = "default"

@export var texture: Texture2D

@export var colorShader: bool = false

@export var redChannel: bool = false
@export var defaultRed: Color = Color.WHITE

@export var greenChannel: bool = false
@export var defaultGreen: Color = Color.WHITE

@export var blueChannel: bool = false
@export var defaultBlue: Color = Color.WHITE

@export_flags("Test:1", "Hat:2", "Glasses:4") var tags: int = 0