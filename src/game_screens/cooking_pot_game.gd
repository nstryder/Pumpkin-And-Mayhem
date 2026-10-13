extends Node2D


class TimelineAction:
	var method: Callable
	var start_time: float
	var window_duration: float
	var visual: TimelineActionItem


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

	
func stir(window: float) -> void:
	var circle_input := CircleInput.construct()
	add_child(circle_input)
	circle_input.completed.connect(_on_action_completed)
	current_prompt = circle_input
	timer.start(window)
	_change_action_color(Color.LIGHT_YELLOW)
	

func show_text(text: String) -> void:
	output.text = text
	output.show()
	await get_tree().create_timer(1.0).timeout
	output.hide()


func _on_action_completed() -> void:
	timer.stop()
	current_prompt.queue_free()
	_change_action_color(Color.SPRING_GREEN)
	show_text("Nice!")
	current_action_idx += 1


func _on_action_missed() -> void:
	current_prompt.queue_free()
	_change_action_color(Color.PALE_VIOLET_RED)
	fails += 1
	show_text("Failed...")
	current_action_idx += 1
