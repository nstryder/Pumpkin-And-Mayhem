extends Node2D

const COOKING_POT_GAME = "uid://74un8kdkjk0a"
const GARLIC_GAME = "uid://bao7qolnlt5wi"
const ONION_GAME = "uid://cb14c03d2i0xu"
const PUMPKIN_GAME = "uid://dhb4bcr73gne5"

const QUIZ_BUTTER = "uid://d2w51xuwuxghv"
const QUIZ_CREAM = "uid://bneba7c1hd8wb"
const QUIZ_MILK = "uid://bv56nmuxhexnx"
const QUIZ_SHAKER = "uid://b3fw2lv0c34nj"

const QUIZ_GARLIC = "uid://ms20ep2oivf5"
const QUIZ_ONION = "uid://dbqkleh8a25xl"
const QUIZ_PUMPKIN = "uid://dd6l3uixtkn8m"

@export var debug_skip: bool = false

@onready var recipe_clickable: ClickableArea = $RecipeClickable
@onready var to_pantry: Polygon2D = $ToPantry
@onready var cutting_board: ClickableArea = $CuttingBoard

@onready var main_ingredients: Node2D = %MainIngredients
@onready var pumpkin: ClickableArea = %Pumpkin
@onready var onion: ClickableArea = %Onion
@onready var garlic: ClickableArea = %Garlic

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
	
	small_ingredients.process_mode = Node.PROCESS_MODE_DISABLED
	main_ingredients.process_mode = Node.PROCESS_MODE_DISABLED

	# Check main ingredients
	if not GlobalState.is_pumpkin_done:
		pumpkin.queue_free()
	if not GlobalState.is_onion_done:
		onion.queue_free()
	if not GlobalState.is_garlic_done:
		garlic.queue_free()
	
	# Check small ingredients
	if not GlobalState.got_milk:
		milk.queue_free()
	if not GlobalState.got_cream:
		cream.queue_free()
	if not GlobalState.got_shaker:
		shaker.queue_free()
	if not GlobalState.got_butter:
		butter.queue_free()
	
	for ingredient_name: String in ["milk", "cream", "shaker", "butter", "onion", "garlic", "pumpkin"]:
		var ingredient: ClickableArea = get(ingredient_name)
		var sprite: Sprite2D = ingredient.get_node("Sprite")
		sprite.texture = GlobalState.call("get_sprite_" + ingredient_name)
		if GlobalState.get(ingredient_name + "_status") != GlobalState.Status.NONE:
			ingredient.process_mode = Node.PROCESS_MODE_DISABLED


	if GlobalState.has_all_smalls() and not GlobalState.resolved_all_twists_small():
		twist_small_ingredients()
	

	if GlobalState.has_all_mains() and not GlobalState.resolved_all_twists_main():
		twist_main_ingredients()
	

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


func twist_main_ingredients() -> void:
	main_ingredients.process_mode = Node.PROCESS_MODE_INHERIT


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


func _on_cauldron_clicked() -> void:
	if GlobalState.has_all_mains() and not GlobalState.resolved_all_twists_main():
		EventBus.prompt_requested.emit("Somethine doesn't look right...")
	elif GlobalState.has_all_smalls() and not GlobalState.resolved_all_twists_small():
		EventBus.prompt_requested.emit("Somethine doesn't look right...")
	elif (GlobalState.has_all_mains() and GlobalState.has_all_smalls()
	and GlobalState.resolved_all_twists_small() and GlobalState.resolved_all_twists_main()):
			EventBus.hide_recipe.emit()
			EventBus.scene_change_requested.emit(COOKING_POT_GAME)
	else:
		EventBus.prompt_requested.emit("I haven't prepared all ingredients yet...")


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


func _on_pumpkin_clicked() -> void:
	EventBus.hide_recipe.emit()
	EventBus.scene_change_requested.emit(QUIZ_PUMPKIN)


func _on_onion_clicked() -> void:
	EventBus.hide_recipe.emit()
	EventBus.scene_change_requested.emit(QUIZ_ONION)


func _on_garlic_clicked() -> void:
	EventBus.hide_recipe.emit()
	EventBus.scene_change_requested.emit(QUIZ_GARLIC)
