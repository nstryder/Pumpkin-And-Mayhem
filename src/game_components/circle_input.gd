extends Node2D
class_name CircleInput


# How do we qualify a circle input?
# Comparing delta theta maxes at 180 deg...
# Every frame, compare delta theta if its positive or negative, add this to an accumulator
# once abs(acc) hits threshold, consider input as complete
# if released too early, reset acc

const SELF_INPUT = preload("uid://bx8rfxo0ogo7m")

signal completed

## How much rotation is needed for the input to register a completion
@export_range(0, 360) var angle_threshold_deg: float = 270

var current_point: Vector2
var accumulated_angle_rad: float = 0.0

@onready var rotation_point: Node2D = %RotationPoint


static func construct() -> CircleInput:
	return SELF_INPUT.instantiate()


func _ready() -> void:
	set_process(false)


func _unhandled_input(event: InputEvent) -> void:
	if not Utils.event_is_left_click(event):
		return

	if event.is_pressed():
		current_point = get_local_mouse_position()
		accumulated_angle_rad = 0
		set_process(true)
	else:
		set_process(false)


func _process(_delta: float) -> void:
	var new_point: Vector2 = get_local_mouse_position()
	var delta_rotation: float = new_point.angle_to(current_point)
	current_point = new_point
	accumulated_angle_rad -= delta_rotation
	
	rotation_point.rotation = accumulated_angle_rad

	if rad_to_deg(absf(accumulated_angle_rad)) >= angle_threshold_deg:
		completed.emit()
		set_process(false)
