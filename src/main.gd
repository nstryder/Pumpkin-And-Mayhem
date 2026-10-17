extends Node2D

var is_recipe_showing: bool = false:
	set(value):
		is_recipe_showing = value
		if is_recipe_showing:
			recipe_animation.play("show_recipe")
		else:
			recipe_animation.play("hide_recipe")


@onready var current_scene: Node2D = %CurrentScene
@onready var prompt: Label = %Prompt
@onready var prompt_animation: AnimationPlayer = %PromptAnimation
@onready var recipe_animation: AnimationPlayer = %RecipeAnimation
@onready var recipe: TextureRect = %Recipe
@onready var mistake_counter: Label = %MistakeCounter
@onready var mistake_animation: AnimationPlayer = %MistakeAnimation


func _ready() -> void:
	GlobalState.recipe_read.connect(func() -> void:
		recipe.show()
	)
	EventBus.hide_recipe.connect(func() -> void:
		recipe.hide()
	)
	EventBus.show_recipe.connect(func() -> void:
		recipe.show()
	)
	EventBus.scene_change_requested.connect(_on_scene_change_requested)
	EventBus.prompt_requested.connect(_on_prompt_requested)
	if not GlobalState.is_recipe_read:
		recipe.hide()
	
	mistake_counter.hide()
	GlobalState.mistakes_made_changed.connect(_on_mistakes_made)


func _on_mistakes_made(new_value: int) -> void:
	if new_value == 0:
		mistake_counter.hide()
	else:
		mistake_counter.show()
		mistake_counter.text = str("Mistakes: ", new_value)
		mistake_animation.play("shake")


func _on_scene_change_requested(new_scene_path: String) -> void:
	current_scene.get_child(0).queue_free()
	var new_scene: PackedScene = load(new_scene_path)
	var instance: Node = new_scene.instantiate()
	current_scene.add_child(instance)


func _on_prompt_requested(text: String) -> void:
	prompt.text = text
	prompt_animation.play("fade")


func _on_recipe_gui_input(event: InputEvent) -> void:
	if not Utils.event_is_left_click(event) or event.is_pressed():
		return
	print("Setting to ", not is_recipe_showing)
	is_recipe_showing = not is_recipe_showing


func _on_recipe_mouse_entered() -> void:
	if not is_recipe_showing and not recipe_animation.is_playing():
		recipe_animation.play("hover")


func _on_recipe_mouse_exited() -> void:
	if not is_recipe_showing and recipe_animation.current_animation == "hover":
		recipe_animation.stop()
