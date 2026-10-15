extends Node2D


# Spawn 2 slices at the pumpkin center point, one normal and one horizontal
# Create seed removal module 
# click on oven, wait...
# click on food processor, wait... 
# lets make this more interesting, you have to time when to click (might make a separate input?)

var slice_count: int = 2
var current_slice: SliceInput
var pick_off_input: PickOffInput
var oven_timed_input: TimedInput
var food_process_timed_input: TimedInput

@onready var pumpkin_holder: Node2D = %PumpkinHolder
@onready var pumpkin: Label = %Pumpkin
@onready var pick_off_input_placeholder: InstancePlaceholder = %PickOffInput
@onready var oven_timed_input_placeholder: InstancePlaceholder = %OvenTimedInput
@onready var food_process_timed_input_placeholder: InstancePlaceholder = %FoodProcessTimedInput


func _ready() -> void:
	pop_slice()


func pop_slice() -> void:
	var spawn_point: Vector2 = pumpkin.get_global_rect().get_center()
	var slice := SliceInput.construct()
	current_slice = slice
	add_child(slice)
	slice.sliced.connect(_on_slice_sliced)
	slice.global_position = spawn_point
	if slice_count == 1:
		slice.rotation = PI / 2
	slice_count -= 1


func start_pick_off() -> void:
	pick_off_input = pick_off_input_placeholder.create_instance()
	pick_off_input.show()
	pick_off_input.completed.connect(_on_pick_off_input_completed)


func start_oven() -> void:
	oven_timed_input = oven_timed_input_placeholder.create_instance()
	oven_timed_input.show()
	oven_timed_input.passed.connect(_on_oven_input_passed)


func start_food_processor() -> void:
	food_process_timed_input = food_process_timed_input_placeholder.create_instance()
	food_process_timed_input.show()
	food_process_timed_input.passed.connect(_on_food_processor_input_passed)


func _on_slice_sliced() -> void:
	current_slice.queue_free()
	if slice_count > 0:
		pop_slice()
	else:
		pumpkin_holder.queue_free()
		start_pick_off()


func _on_pick_off_input_completed() -> void:
	pick_off_input.queue_free()
	start_oven()


func _on_oven_input_passed() -> void:
	oven_timed_input.queue_free()
	start_food_processor()


func _on_food_processor_input_passed() -> void:
	pass
