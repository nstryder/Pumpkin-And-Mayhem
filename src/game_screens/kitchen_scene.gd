extends Node2D

const COOKING_POT_GAME = "uid://74un8kdkjk0a"
const GARLIC_GAME = "uid://bao7qolnlt5wi"
const ONION_GAME = "uid://cb14c03d2i0xu"
const PUMPKIN_GAME = "uid://dhb4bcr73gne5"

@onready var recipe_clickable: ClickableArea = $RecipeClickable
@onready var to_pantry: Polygon2D = $ToPantry
@onready var cutting_board: ClickableArea = $CuttingBoard
@onready var pumpkin: Sprite2D = $Pumpkin
@onready var onion: Sprite2D = $Onion
@onready var garlic: Sprite2D = $Garlic


func _ready() -> void:
	Audio.mute_instrument(Audio.Instruments.PERCUSSION)
	if GlobalState.is_recipe_read:
		recipe_clickable.queue_free()
		EventBus.show_recipe.emit()
	else:
		_disable_all_clickables()

	if not GlobalState.is_pumpkin_done:
		pumpkin.hide()
	if not GlobalState.is_onion_done:
		onion.hide()
	if not GlobalState.is_garlic_done:
		garlic.hide()


func _disable_all_clickables() -> void:
	to_pantry.process_mode = Node.PROCESS_MODE_DISABLED
	cutting_board.process_mode = Node.PROCESS_MODE_DISABLED


func _enable_all_clickables() -> void:
	to_pantry.process_mode = Node.PROCESS_MODE_INHERIT
	cutting_board.process_mode = Node.PROCESS_MODE_INHERIT


func _on_cutting_board_clicked() -> void:
	match GlobalState.current_item:
		GlobalState.Items.PUMPKIN:
			EventBus.hide_recipe.emit()
			EventBus.scene_change_requested.emit(PUMPKIN_GAME)
		GlobalState.Items.GARLIC:
			EventBus.hide_recipe.emit()
			EventBus.scene_change_requested.emit(GARLIC_GAME)
		GlobalState.Items.ONION:
			EventBus.hide_recipe.emit()
			EventBus.scene_change_requested.emit(ONION_GAME)
		_:
			EventBus.prompt_requested.emit("Don't have anything to chop...")


func _on_recipe_clickable_clicked() -> void:
	GlobalState.is_recipe_read = true
	recipe_clickable.queue_free()
	_enable_all_clickables()
