extends Node2D

const COOKING_POT_GAME = "uid://74un8kdkjk0a"
const GARLIC_GAME = "uid://bao7qolnlt5wi"
const ONION_GAME = "uid://cb14c03d2i0xu"
const PUMPKIN_GAME = "uid://dhb4bcr73gne5"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_cutting_board_clicked() -> void:
	match GlobalState.current_item:
		GlobalState.Items.PUMPKIN:
			EventBus.scene_change_requested.emit(PUMPKIN_GAME)
		_:
			EventBus.prompt_requested.emit("Don't have anything to chop...")
