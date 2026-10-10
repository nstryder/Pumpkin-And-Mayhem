extends Node2D
class_name TimedInput

## This input requires the user to wait a certain amount of time
## and then click when the timer is in the pass region [member passed]
## Beyond that means you [member failed].
## Before it should probably mean you can just retry as it is [member incomplete]

signal passed
signal failed
signal incomplete


## Total seconds allotted for this timed input
@export var total_time: float = 1.2

## When the user is allowed to click to pass
@export var pass_time_start: float = 0.9

## How long the window is for the user to click and still pass
@export var pass_time_duration: float = 0.2


@onready var timer: Timer = $Timer
@onready var pass_region: TextureProgressBar = %PassRegion
@onready var fail_region: TextureProgressBar = %FailRegion
@onready var progress: TextureProgressBar = %Progress
@onready var prompt: Label = $Prompt


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = total_time
	timer.start()
	set_process(true)

	# Calculate region for pass visuals
	pass_region.radial_initial_angle = 360 * pass_time_start / total_time
	pass_region.value = pass_time_duration / total_time * 100

	# Calculate region for failure
	fail_region.value = (total_time - pass_time_start - pass_time_duration) / total_time * 100


func _unhandled_input(event: InputEvent) -> void:
	if not Utils.event_is_left_click(event) or not event.is_pressed():
		return
	
	set_process(false)
	set_process_unhandled_input(false)
	var time_elapsed: float = total_time - timer.time_left
	if pass_time_start <= time_elapsed and time_elapsed <= (pass_time_start + pass_time_duration):
		on_pass()
	elif time_elapsed < pass_time_start:
		await on_incomplete()
	else:
		on_fail()


func _process(_delta: float) -> void:
	progress.value = (total_time - timer.time_left) / total_time * 100


func on_pass() -> void:
	print("Passed!")
	prompt.text = "Passed!"
	prompt.show()
	timer.stop()
	passed.emit()


func on_fail() -> void:
	print("Failed!")
	prompt.text = "Failed..."
	prompt.show()
	timer.stop()
	failed.emit()


func on_incomplete() -> void:
	print("Incomplete. Retry")
	prompt.text = "Try again..."
	prompt.show()
	prompt.offset_transform_position.y = 0
	var tween := create_tween()
	(tween.tween_property(prompt, "offset_transform_position:y", -64, 0.2)
		.set_trans(Tween.TRANS_CUBIC)
		.set_ease(Tween.EASE_OUT)
	)
	await get_tree().create_timer(0.6).timeout
	prompt.hide()
	timer.start()
	set_process_unhandled_input(true)
	set_process(true)
	incomplete.emit()


func _on_timer_timeout() -> void:
	on_fail()
