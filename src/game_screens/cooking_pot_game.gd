extends Node2D


class TimelineAction:
	var method: Callable
	var start_time: float
	var window_duration: float
	var visual: TimelineActionItem


const CLICK_CREAM = preload("uid://dx0ytpr3c5rvi")
const CLICK_GARLIC = preload("uid://cub5jljcse7nv")
const CLICK_MILK = preload("uid://cgjoekx1nca1v")
const CLICK_ONION = preload("uid://b4j4bwhnr3eok")
const CLICK_PUMPKIN = preload("uid://dtdf2iiyytswv")
const SLICE_BUTTER = preload("uid://c8iwm3ulg4wkh")
const SHAKE_SEASONING = preload("uid://coeo76qvjgdvv")


var actions: Array[TimelineAction] = []
var current_prompt: Node2D
var scroll_speed: float = 200.0
var visual_offset: int = 128
var current_action_idx: int = 0
var fails: int = 0


@onready var timeline_player: AnimationPlayer = $TimelinePlayer
@onready var timer: Timer = $Timer
@onready var output: Label = $Output
@onready var action_holder: Control = %ActionHolder
@onready var action_line: ColorRect = %ActionLine


func _ready() -> void:
	action_line.position.x = visual_offset
	_get_timeline_actions()
	_place_timeline_actions()
	timer.timeout.connect(_on_action_missed)
	output.hide()


func _get_timeline_actions() -> void:
	var animation: Animation = timeline_player.get_animation("default")
	# We must assume only 1 track is present (the method track)
	var track_idx: int = 0
	for key_idx in animation.track_get_key_count(track_idx):
		var action := TimelineAction.new()
		var method_name: StringName = animation.method_track_get_name(track_idx, key_idx)
		action.method = Callable(self, method_name)
		action.start_time = animation.track_get_key_time(track_idx, key_idx)
		action.window_duration = animation.method_track_get_params(track_idx, key_idx)[0]
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


func _process(delta: float) -> void:
	action_holder.position.x -= scroll_speed * delta


func _change_action_color(color: Color) -> void:
	actions[current_action_idx].visual.color = color


func _show_text(text: String) -> void:
	output.text = text
	output.show()
	await get_tree().create_timer(1.0).timeout
	output.hide()


func _start_action(window: float, prompt_node: Node2D) -> void:
	current_prompt = prompt_node
	timer.start(window)
	_change_action_color(Color.LIGHT_BLUE)


func _add_clickable(window: float, clickable_scene: PackedScene) -> void:
	var clickable: ClickableArea = clickable_scene.instantiate()
	add_child(clickable)
	clickable.clicked.connect(_on_action_completed)
	_start_action(window, clickable)

	
func stir(window: float) -> void:
	var circle_input := CircleInput.construct()
	add_child(circle_input)
	circle_input.completed.connect(_on_action_completed)
	_start_action(window, circle_input)


func add_onion(window: float) -> void:
	_add_clickable(window, CLICK_ONION)


func add_cream(window: float) -> void:
	_add_clickable(window, CLICK_CREAM)


func add_garlic(window: float) -> void:
	_add_clickable(window, CLICK_GARLIC)


func add_milk(window: float) -> void:
	_add_clickable(window, CLICK_MILK)


func add_pumpkin(window: float) -> void:
	_add_clickable(window, CLICK_PUMPKIN)


func slice_butter(window: float) -> void:
	var instance: SliceInput = SLICE_BUTTER.instantiate()
	add_child(instance)
	instance.sliced.connect(_on_action_completed)
	_start_action(window, instance)


func shake_seasoning(window: float) -> void:
	var instance: ShakeInput = SHAKE_SEASONING.instantiate()
	add_child(instance)
	instance.completed.connect(_on_action_completed)
	_start_action(window, instance)


func _on_action_completed() -> void:
	timer.stop()
	current_prompt.queue_free()
	_change_action_color(Color.SPRING_GREEN)
	_show_text("Nice!")
	current_action_idx += 1


func _on_action_missed() -> void:
	current_prompt.queue_free()
	_change_action_color(Color.PALE_VIOLET_RED)
	fails += 1
	_show_text("Failed...")
	current_action_idx += 1
