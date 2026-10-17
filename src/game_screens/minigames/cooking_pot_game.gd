extends Node2D


class TimelineAction:
	var method: Callable
	var start_time: float
	var window_duration: float
	var visual: TimelineActionItem

enum Clickables {
	CREAM,
	GARLIC,
	MILK,
	ONION,
	PUMPKIN,
}
const SLICE_BUTTER = preload("uid://c8iwm3ulg4wkh")
const SHAKE_SEASONING = preload("uid://coeo76qvjgdvv")


@export var pass_sfx: AudioStream
@export var fail_sfx: AudioStream
@export var splat_sfx: AudioStream


var actions: Array[TimelineAction] = []
var current_prompt: Node2D
var scroll_speed: float = 200.0
var visual_offset: int = 128
var current_action_idx: int = 0
var current_ingredient: ClickableArea


@onready var timeline_player: AnimationPlayer = $TimelinePlayer
@onready var timer: Timer = $Timer
@onready var output: Label = %Output
@onready var action_holder: Control = %ActionHolder
@onready var action_line: ColorRect = %ActionLine
@onready var stir_point: Node2D = %StirPoint
@onready var butter_point: Node2D = %ButterPoint
@onready var splat: GPUParticles2D = %Splat
@onready var seasoning_particles: GPUParticles2D = %SeasoningParticles
@onready var twist_seasoning_particles: GPUParticles2D = %TwistSeasoningParticles
@onready var animation: AnimationPlayer = %Animation
@onready var transition: AnimationPlayer = %Transition

@onready var ingredients: Node2D = %Ingredients
@onready var milk: ClickableArea = %Milk
@onready var cream: ClickableArea = %Cream
@onready var onion: ClickableArea = %Onion
@onready var pumpkin: ClickableArea = %Pumpkin
@onready var garlic: ClickableArea = %Garlic


func _ready() -> void:
	# for s: String in ["milk", "cream", "shaker", "butter", "onion", "garlic", "pumpkin"]:
	# 	GlobalState.set(s + "_status", GlobalState.Status.TWISTED)
	Audio.play_instrument(Audio.Instruments.PERCUSSION)
	action_line.position.x = visual_offset
	_get_timeline_actions()
	_place_timeline_actions()
	timer.timeout.connect(_on_action_missed)
	output.hide()
	_check_twists()
	_disable_ingredients()


func _get_timeline_actions() -> void:
	var timeline: Animation = timeline_player.get_animation("default")
	# We must assume only 1 track is present (the method track)
	var track_idx: int = 0
	for key_idx in timeline.track_get_key_count(track_idx):
		var action := TimelineAction.new()
		var method_name: StringName = timeline.method_track_get_name(track_idx, key_idx)
		action.method = Callable(self, method_name)
		action.start_time = timeline.track_get_key_time(track_idx, key_idx)
		action.window_duration = timeline.method_track_get_params(track_idx, key_idx)[0]
		actions.push_back(action)


func _place_timeline_actions() -> void:
	for action in actions:
		var action_name: String = action.method.get_method().capitalize()
		var action_item := TimelineActionItem.construct(action_name)
		action_item.color = Color.WHITE
		action_item.size.y = action_holder.size.y
		action_item.position.x = (scroll_speed * action.start_time) + visual_offset
		action_item.size.x = scroll_speed * action.window_duration
		action_holder.add_child(action_item)
		action.visual = action_item


func _check_twists() -> void:
	for ingredient_name: String in ["milk", "cream", "onion", "garlic", "pumpkin"]:
		var ingredient: ClickableArea = get(ingredient_name)
		var sprite: Sprite2D = ingredient.get_node("Sprite")
		sprite.texture = GlobalState.call("get_sprite_" + ingredient_name)


func _process(delta: float) -> void:
	action_holder.position.x -= scroll_speed * delta


func _change_action_color(color: Color) -> void:
	actions[current_action_idx].visual.color = color


func _show_text(text: String) -> void:
	output.text = text
	output.show()
	output.offset_transform_position.y = 256
	var tween := create_tween()
	(tween.tween_property(output, "offset_transform_position:y", 0, 0.2)
		.set_ease(Tween.EASE_OUT)
		.set_trans(Tween.TRANS_CUBIC)
	)
	await get_tree().create_timer(1.0).timeout
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(output, "offset_transform_position:y", 256, 0.2)
	await tween.finished
	output.hide()


func _start_action(window: float, prompt_node: Node2D) -> void:
	current_prompt = prompt_node
	timer.start(window)
	_change_action_color(Color.LIGHT_BLUE)


func _add_clickable(window: float, ingredient: ClickableArea) -> void:
	current_ingredient = ingredient
	timer.start(window)
	_enable_ingredients()
	_change_action_color(Color.LIGHT_BLUE)


func _disable_ingredients() -> void:
	ingredients.process_mode = Node.PROCESS_MODE_DISABLED


func _enable_ingredients() -> void:
	ingredients.process_mode = Node.PROCESS_MODE_INHERIT
	animation.play("prompt_ingredients")

	
func stir(window: float) -> void:
	var circle_input := CircleInput.construct()
	stir_point.add_child(circle_input)
	circle_input.completed.connect(_on_action_completed)
	_start_action(window, circle_input)


func add_onion(window: float) -> void:
	_add_clickable(window, onion)


func add_cream(window: float) -> void:
	_add_clickable(window, cream)


func add_garlic(window: float) -> void:
	_add_clickable(window, garlic)


func add_milk(window: float) -> void:
	_add_clickable(window, milk)


func add_pumpkin(window: float) -> void:
	_add_clickable(window, pumpkin)


func slice_butter(window: float) -> void:
	var instance: SliceInput = SLICE_BUTTER.instantiate()
	butter_point.add_child(instance)
	butter_point.move_child(instance, 0)
	instance.sliced.connect(_on_butter_completed)
	_start_action(window, instance)


func shake_seasoning(window: float) -> void:
	var instance: ShakeInput = SHAKE_SEASONING.instantiate()
	butter_point.add_child(instance)
	instance.completed.connect(_on_seasoning_completed)
	_start_action(window, instance)


func _on_butter_completed() -> void:
	timer.stop()
	_change_action_color(Color.SPRING_GREEN)
	_show_text("Nice!")
	current_action_idx += 1
	animation.play("butter_fall")
	await animation.animation_finished
	current_prompt.queue_free()


func _on_seasoning_completed() -> void:
	if GlobalState.shaker_status == GlobalState.Status.TWISTED:
		twist_seasoning_particles.restart()
	else:
		seasoning_particles.restart()
	_on_action_completed()


func _on_action_completed() -> void:
	timer.stop()
	if current_prompt:
		current_prompt.queue_free()
	_change_action_color(Color.SPRING_GREEN)
	_show_text("Nice!")
	Audio.play_sfx(pass_sfx)
	current_action_idx += 1


func _on_action_missed() -> void:
	if current_prompt:
		current_prompt.queue_free()
	Audio.play_sfx(fail_sfx)
	timer.stop()
	_change_action_color(Color.PALE_VIOLET_RED)
	GlobalState.mistakes_made += 1
	_show_text("Failed...")
	current_action_idx += 1


func _check_ingredient(ingredient: ClickableArea) -> void:
	_disable_ingredients()
	if current_ingredient == ingredient:
		_on_action_completed()
		splat.restart()
		Audio.play_sfx(splat_sfx)
		current_ingredient.queue_free()
	else:
		_on_action_missed()


func _on_onion_clicked() -> void:
	_check_ingredient(onion)


func _on_cream_clicked() -> void:
	_check_ingredient(cream)


func _on_milk_clicked() -> void:
	_check_ingredient(milk)


func _on_garlic_clicked() -> void:
	_check_ingredient(garlic)


func _on_pumpkin_clicked() -> void:
	_check_ingredient(pumpkin)


func _on_timeline_player_animation_finished(_anim_name: StringName) -> void:
	set_process(false)
	transition.play("fade_out")
	await transition.animation_finished
	get_tree().change_scene_to_packed(load("uid://dr01e4q2881b0") as PackedScene)
