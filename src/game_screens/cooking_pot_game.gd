extends Node2D


class TimelineAction:
	var method: Callable
	var start_time: float
	var window_duration: float


var actions: Array[TimelineAction] = []
var current_prompt: Node2D
var scroll_speed: float = 200.0


@onready var timeline_player: AnimationPlayer = $TimelinePlayer
@onready var timer: Timer = $Timer
@onready var output: Label = $Output
@onready var action_holder: Control = %ActionHolder


func _ready() -> void:
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
		var action_item := ColorRect.new()
		action_item.color = Color.WHITE
		action_item.size.y = action_holder.size.y
		# general eq: d = vt
		# Position:x determined by time 
		# Size:x determined by time + window 
		action_item.position.x = scroll_speed * action.start_time
		action_item.size.x = scroll_speed * action.window_duration
		action_holder.add_child(action_item)


func _process(delta: float) -> void:
	action_holder.position.x -= scroll_speed * delta

	
func act_circle(window: float) -> void:
	var circle_input := CircleInput.construct()
	add_child(circle_input)
	circle_input.completed.connect(_on_action_completed)
	current_prompt = circle_input
	timer.start(window)


func show_text(text: String) -> void:
	output.text = text
	output.show()
	await get_tree().create_timer(1.0).timeout
	output.hide()


func _on_action_completed() -> void:
	timer.stop()
	current_prompt.queue_free()
	actions.pop_front()
	show_text("Nice!")


func _on_action_missed() -> void:
	timeline_player.stop()
	current_prompt.queue_free()
	show_text("Failed...")
	set_process(false)
