extends Node2D

const COOKING_POT_GAME = "uid://74un8kdkjk0a"
const GARLIC_GAME = "uid://bao7qolnlt5wi"
const ONION_GAME = "uid://cb14c03d2i0xu"
const PUMPKIN_GAME = "uid://dhb4bcr73gne5"


@onready var pumpkin: Sprite2D = $Pumpkin
@onready var onion: Sprite2D = $Onion
@onready var garlic: Sprite2D = $Garlic


func _ready() -> void:
	if not GlobalState.is_pumpkin_done:
		pumpkin.hide()
	if not GlobalState.is_onion_done:
		onion.hide()
	if not GlobalState.is_garlic_done:
		garlic.hide()


func _on_cutting_board_clicked() -> void:
	match GlobalState.current_item:
		GlobalState.Items.PUMPKIN:
			EventBus.scene_change_requested.emit(PUMPKIN_GAME)
		GlobalState.Items.GARLIC:
			EventBus.scene_change_requested.emit(GARLIC_GAME)
		GlobalState.Items.ONION:
			EventBus.scene_change_requested.emit(ONION_GAME)
		_:
			EventBus.prompt_requested.emit("Don't have anything to chop...")
