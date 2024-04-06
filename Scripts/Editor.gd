extends CanvasLayer

class_name Editor

static var ins: Editor

@export var partIns: PackedScene

@export var decorButtonIns: PackedScene

@export var partDataList: Array[PartData]

var currentPart: Part

var selectOffset: Vector2 = Vector2(0, 0)

var currentRotation: float = 0.0
var currentScale: float = 1.0

var fishRef: CanvasGroup

func _init():
	ins = self

func _ready():
	for i in partDataList.size():
		var newButton: Button = decorButtonIns.instantiate()
		newButton.tooltip_text = partDataList[i].name
		newButton.connect("button_down", Callable(self, "CreateNewDecor").bind(i))
		newButton.get_node("Texture").texture = partDataList[i].texture
		%Decors.add_child(newButton)

		fishRef = get_parent().get_node("Fish")

func CreateNewDecor(id: int = 0):
	var newDecor = partIns.instantiate() as Part
	newDecor.SetTexture(partDataList[id].texture)
	newDecor.GenerateClickMask()
	var mousePos = get_viewport().get_mouse_position()
	newDecor.position = mousePos
	fishRef.add_child(newDecor)
	selectOffset = newDecor.size / 2
	currentPart = newDecor
	currentRotation = 0
	currentScale = 1.0
	SpawnAnimation()

func SpawnAnimation():
	SetPartScale(1.2, currentPart)
	var spawnTween = currentPart.create_tween()
	spawnTween.tween_method(SetPartScale.bind(currentPart), 1.2, 1.0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _process(_delta):
	if currentPart:
		if IsInSafeZone():
			currentPart.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			currentPart.modulate = Color(1.0, .3, .3, 1.0)
		if Input.is_action_pressed("Interact"):
			if Input.is_action_just_released("ScrollDown"):
				if Input.is_action_pressed("Shift"):
					RotatePart(0.05)
				else:
					SetPartScale(currentPart.scale.x * 0.9, currentPart)
			elif Input.is_action_just_released("ScrollUp"):
				if Input.is_action_pressed("Shift"):
					RotatePart(-0.05)
				else:
					SetPartScale(currentPart.scale.x * 1.1, currentPart)
			if Input.is_action_pressed("ScaleUp"):
				if Input.is_action_pressed("Shift"):
					SetPartScale(currentPart.scale.x * 1.05, currentPart)
				else:
					SetPartScale(currentPart.scale.x * 1.01, currentPart)
			elif Input.is_action_pressed("ScaleDown"):
				if Input.is_action_pressed("Shift"):
					SetPartScale(currentPart.scale.x * 0.95, currentPart)
				else:
					SetPartScale(currentPart.scale.x * 0.99, currentPart)
			if Input.is_action_pressed("RotateLeft"):
				if Input.is_action_pressed("Shift"):
					RotatePart(-0.05)
				else:
					RotatePart(-0.01)
			elif Input.is_action_pressed("RotateRight"):
				if Input.is_action_pressed("Shift"):
					RotatePart(0.05)
				else:
					RotatePart(0.01)
			if Input.is_action_just_pressed("MoveUp"):
				if Input.is_action_pressed("Shift"):
					MoveToTop()
				else:
					MoveUp()
			elif Input.is_action_just_pressed("MoveDown"):
				if Input.is_action_pressed("Shift"):
					MoveToBottom()
				else:
					MoveDown()
			currentPart.position = get_viewport().get_mouse_position() - (selectOffset * currentScale).rotated(currentRotation)
		elif Input.is_action_just_released("Interact"):
			if !IsInSafeZone():
				currentPart.Delete()
			currentPart = null
			currentRotation = 0
			currentScale = 1.0

func IsInSafeZone() -> bool:
	var fishBody: Sprite2D = fishRef.get_node("FishBody") as Sprite2D
	var fBSize = fishBody.texture.get_size() * fishBody.scale
	var partPos = currentPart.position + (currentPart.size * currentPart.scale * 0.5).rotated(currentPart.rotation)
	if partPos.x > fishBody.position.x - (fBSize.x * 0.5) - 50 and partPos.x < fishBody.position.x + (fBSize.x * 0.5) + 50 and partPos.y > fishBody.position.y - (fBSize.y * 0.5) - 50 and partPos.y < fishBody.position.y + (fBSize.y * 0.5) + 50:
		return true
	return false

func RotatePart(amount: float):
	currentPart.rotation += amount
	currentRotation += amount

func SetPartScale(value: float, part: Part):
	if value > 0.2 and value < 5.0:
		if part == currentPart:
			currentScale *= value / part.scale.x 
		part.scale = Vector2(value, value)

func SelectPart(part: Part):
	currentPart = part
	selectOffset = get_viewport().get_mouse_position() - part.position
	currentRotation = 0
	currentScale = 1.0

func MoveUp():
	var index = currentPart.get_index()
	if index < fishRef.get_child_count():
		fishRef.move_child(currentPart, index + 1)

func MoveDown():
	var index = currentPart.get_index()
	if index > 1:
		fishRef.move_child(currentPart, index - 1)

func MoveToTop():
	fishRef.move_child(currentPart, 1)

func MoveToBottom():
	fishRef.move_child(currentPart, fishRef.get_child_count() - 1)