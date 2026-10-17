extends Node2D

const COOKING_POT_GAME = "uid://74un8kdkjk0a"
const GARLIC_GAME = "uid://bao7qolnlt5wi"
const ONION_GAME = "uid://cb14c03d2i0xu"
const PUMPKIN_GAME = "uid://dhb4bcr73gne5"

const QUIZ_BUTTER = "uid://d2w51xuwuxghv"
const QUIZ_CREAM = "uid://bneba7c1hd8wb"
const QUIZ_MILK = "uid://bv56nmuxhexnx"
const QUIZ_SHAKER = "uid://b3fw2lv0c34nj"

@export var debug_skip: bool = false

@onready var recipe_clickable: ClickableArea = $RecipeClickable
@onready var to_pantry: Polygon2D = $ToPantry
@onready var cutting_board: ClickableArea = $CuttingBoard
@onready var pumpkin: Sprite2D = $Pumpkin
@onready var onion: Sprite2D = $Onion
@onready var garlic: Sprite2D = $Garlic

@onready var small_ingredients: Node2D = %SmallIngredients
@onready var milk: ClickableArea = %Milk
@onready var cream: ClickableArea = %Cream
@onready var shaker: ClickableArea = %Shaker
@onready var butter: ClickableArea = %Butter


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
	
	# Check smalls here
	if not GlobalState.got_milk:
		milk.queue_free()
	if not GlobalState.got_cream:
		cream.queue_free()
	if not GlobalState.got_shaker:
		shaker.queue_free()
	if not GlobalState.got_butter:
		butter.queue_free()

	if GlobalState.has_all_smalls() and not GlobalState.fixed_twist_smalls:
		twist_small_ingredients()

	
	if debug_skip:
		_on_recipe_clickable_clicked()


func _disable_all_clickables() -> void:
	to_pantry.process_mode = Node.PROCESS_MODE_DISABLED
	cutting_board.process_mode = Node.PROCESS_MODE_DISABLED


func _enable_all_clickables() -> void:
	to_pantry.process_mode = Node.PROCESS_MODE_INHERIT
	cutting_board.process_mode = Node.PROCESS_MODE_INHERIT


func twist_small_ingredients() -> void:
	small_ingredients.process_mode = Node.PROCESS_MODE_INHERIT


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


func _on_milk_clicked() -> void:
	EventBus.hide_recipe.emit()
	EventBus.scene_change_requested.emit(QUIZ_MILK)


func _on_cream_clicked() -> void:
	EventBus.hide_recipe.emit()
	EventBus.scene_change_requested.emit(QUIZ_CREAM)


func _on_shaker_clicked() -> void:
	EventBus.hide_recipe.emit()
	EventBus.scene_change_requested.emit(QUIZ_SHAKER)


func _on_butter_clicked() -> void:
	EventBus.hide_recipe.emit()
	EventBus.scene_change_requested.emit(QUIZ_BUTTER)
