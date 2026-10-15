extends Node2D


# Spawn 2 slices at the pumpkin center point, one normal and one horizontal
# Create seed removal module 
# click on oven, wait...
# click on food processor, wait... 
# lets make this more interesting, you have to time when to click (might make a separate input?)

var slice_count: int = 2
var current_slice: SliceInput

@onready var pumpkin_holder: Node2D = %PumpkinHolder
@onready var pick_off_input: PickOffInput = %PickOffInput
@onready var oven_timed_input: TimedInput = %OvenTimedInput
@onready var food_process_timed_input: TimedInput = %FoodProcessTimedInput
@onready var pumpkin_animation: AnimationPlayer = $PumpkinAnimation


func _ready() -> void:
	pop_slice()
	for node: Node in [pick_off_input, oven_timed_input, food_process_timed_input]:
		node.get_parent().remove_child(node)
	

func pop_slice() -> void:
	var spawn_point: Vector2 = pumpkin_holder.global_position
	var slice := SliceInput.construct()
	current_slice = slice
	add_child(slice)
	slice.line_length = 600
	slice.sliced.connect(_on_slice_sliced)
	slice.global_position = spawn_point
	if slice_count == 1:
		slice.rotation = PI / 2
	slice_count -= 1


func start_pick_off() -> void:
	add_child(pick_off_input)
	pick_off_input.completed.connect(_on_pick_off_input_completed)
	pick_off_input.hide()
	pumpkin_animation.play("pickoff_slide_in")
	await get_tree().process_frame
	pick_off_input.show()


func start_oven() -> void:
	add_child(oven_timed_input)
	oven_timed_input.passed.connect(_on_oven_input_passed)


func start_food_processor() -> void:
	add_child(food_process_timed_input)
	food_process_timed_input.passed.connect(_on_food_processor_input_passed)


func _on_slice_sliced() -> void:
	current_slice.queue_free()
	if slice_count == 1:
		pop_slice()
		pumpkin_animation.play("vertical_slice")
	else:
		pumpkin_animation.play("full_slice")
		await pumpkin_animation.animation_finished
		pumpkin_holder.queue_free()
		start_pick_off()


func _on_pick_off_input_completed() -> void:
	pumpkin_animation.play("pickoff_slide_out")
	await pumpkin_animation.animation_finished
	pick_off_input.queue_free()
	pumpkin_animation.play("show_oven")
	await pumpkin_animation.animation_finished
	start_oven()


func _on_oven_input_passed() -> void:
	await oven_timed_input.tween.finished
	oven_timed_input.queue_free()
	pumpkin_animation.play("show_oven_done")
	await pumpkin_animation.animation_finished
	await get_tree().create_timer(0.6).timeout
	pumpkin_animation.play("show_food_processor")
	await pumpkin_animation.animation_finished
	start_food_processor()


func _on_food_processor_input_passed() -> void:
	await food_process_timed_input.tween.finished
	food_process_timed_input.queue_free()
	pumpkin_animation.play("finish")
	var showcase := ShowOffItem.construct(load("uid://bxia6ay2lv24e") as Texture2D)
	add_child(showcase)
	EventBus.prompt_requested.emit("Pumpkin Purée made!")
	await showcase.finished
	GlobalState.current_item = GlobalState.Items.NONE
	GlobalState.is_pumpkin_done = true
	EventBus.scene_change_requested.emit("uid://cu0hrfgp6mbuy")
