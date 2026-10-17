extends Node2D


@export var correct_sprite: Texture2D
@export var wrong_sprite: Texture2D
@export var global_variable: String

@export_range(0, 1) var correct_choice: int = 0

@onready var choice_1: Node2D = $Choice1
@onready var choice_2: Node2D = $Choice2
@onready var choice_1_sprite: Sprite2D = %Choice1Sprite
@onready var choice_2_sprite: Sprite2D = %Choice2Sprite
@onready var choices: Array[Sprite2D]
@onready var woosh: GPUParticles2D = %Woosh
@onready var transition: AnimationPlayer = $Transition


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	choices.assign([choice_1_sprite, choice_2_sprite])
	choices[correct_choice].texture = correct_sprite
	var wrong_choice: int = 1 - correct_choice
	choices[wrong_choice].texture = wrong_sprite


func woosh_unchosen(node: Node2D) -> void:
	woosh.global_position = node.global_position
	woosh.restart()
	node.queue_free()


func return_to_kitchen() -> void:
	choice_1.process_mode = Node.PROCESS_MODE_DISABLED
	choice_2.process_mode = Node.PROCESS_MODE_DISABLED
	transition.play("fade_out")
	await transition.animation_finished
	EventBus.scene_change_requested.emit("uid://cu0hrfgp6mbuy")


func _on_choice_1_clicked() -> void:
	if correct_choice == 0:
		GlobalState.twist_select_correct(global_variable)
	else:
		GlobalState.twist_select_wrong(global_variable)
	woosh_unchosen(choice_2)
	return_to_kitchen()
	
	
func _on_choice_2_clicked() -> void:
	if correct_choice == 1:
		GlobalState.twist_select_correct(global_variable)
	else:
		GlobalState.twist_select_wrong(global_variable)
	woosh_unchosen(choice_1)
	return_to_kitchen()
