extends Node2D


# click on garlic area, makes garlic visible and enables garlicpress
# animationplayer to control movement? 
# on click of screen, pause animation, slam press down, if it touches garlic area then you win 

var is_placed: bool = false
var tween: Tween

@onready var garlic_press_holder: Node2D = %GarlicPressHolder
@onready var garlic_press: Sprite2D = %GarlicPress
@onready var garlic_press_animation: AnimationPlayer = %GarlicPressAnimation
@onready var garlic_press_hitbox: Area2D = %GarlicPressHitbox

@onready var prompt_add_garlic: Sprite2D = %PromptAddGarlic
@onready var garlic: Sprite2D = %Garlic
@onready var garlic_place_area: Area2D = %GarlicPlaceArea


func _unhandled_input(event: InputEvent) -> void:
	if not is_placed or not (Utils.event_is_left_click(event) and event.is_pressed()):
		return
	attempt_press()


func _ready() -> void:
	Audio.play_instrument(Audio.Instruments.PERCUSSION)
	garlic_press_holder.hide()
	prompt_add_garlic.show()
	garlic.modulate.a = 0.2
	garlic_press.modulate.a = 0.5


func attempt_press() -> void:
	garlic_press_animation.pause()
	garlic_press.modulate.a = 1.0
	if tween:
		tween.kill()
	tween = create_tween()
	tween.finished.connect(_on_tween_finished)
	(tween.tween_property(garlic_press, "position:y", 256, 1.0)
		.set_trans(Tween.TRANS_CUBIC)
		.set_ease(Tween.EASE_OUT)
	)


func restart_press() -> void:
	garlic_press.modulate.a = 0.3
	garlic_press_animation.play()


func _on_garlic_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_placed or not (Utils.event_is_left_click(event) and event.is_pressed()):
		return

	prompt_add_garlic.hide()
	garlic.modulate.a = 1.0
	garlic_press_holder.show()
	is_placed = true
	garlic_press_animation.play("oscillate")


func _on_garlic_press_hitbox_area_entered(_area: Area2D) -> void:
	tween.kill()
	set_process_input(false)
	var showcase := ShowOffItem.construct(load("uid://bq8680d4gurff") as Texture2D)
	add_child(showcase)
	EventBus.prompt_requested.emit("Garlic successfully pressed!")
	await showcase.finished
	GlobalState.current_item = GlobalState.Items.NONE
	GlobalState.is_garlic_done = true
	EventBus.scene_change_requested.emit("uid://cu0hrfgp6mbuy")


func _on_tween_finished() -> void:
	restart_press()
