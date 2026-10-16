extends Node2D

@export var cuts_quantity: int = 8

var slice_points: Array[Vector2] = []
var current_slice: SliceInput
var blur_amount: float = 0.0:
	set(value):
		blur_amount = value
		var blur_mat: ShaderMaterial = blur_texture.material
		blur_mat.set_shader_parameter("lod", value)


var onion_slices: Array[Sprite2D] = []

@onready var onion_holder: Node2D = $OnionHolder
@onready var onion: Sprite2D = %Onion
@onready var blur_texture: ColorRect = %BlurTexture
@onready var wipe_prompt: CanvasLayer = %WipePrompt
@onready var wipe_input: HSlider = %WipeInput
@onready var background: Sprite2D = $Background

# Blur screen every 3 slices 
# Disable slice input 
# On wipe, unblur and reenable slice input


func _ready() -> void:
	var rect: Rect2 = onion.get_rect()

	# Calculate Slice locations
	var mid_height: float = onion_holder.position.y
	var segment_width: float = rect.size.x / (cuts_quantity + 1)
	for i in cuts_quantity:
		var slice_point := Vector2()
		slice_point.x = (segment_width * (i + 1)) + onion_holder.global_position.x - (rect.size.x / 2)
		slice_point.y = mid_height
		slice_points.push_back(slice_point)

	# Visually slice sprite by splitting it
	# Divide rect into (slice_count + 1) fragments
	for i in (cuts_quantity + 1):
		var fragment: Sprite2D = onion.duplicate()
		fragment.region_enabled = true
		fragment.centered = false

		var fragment_width: float = rect.size.x / (cuts_quantity + 1)
		var fragment_height: float = rect.size.y
		var fragment_size := Vector2(fragment_width, fragment_height)
		
		fragment.region_rect.size = fragment_size
		fragment.region_rect.position.x = fragment_width * i
		fragment.position = Vector2(fragment_width * i, 0) - (rect.size / 2)
		onion_slices.append(fragment)
		onion_holder.add_child(fragment)
	onion.hide()

	pop_slice()


func pop_slice() -> void:
	var slice_point: Vector2 = slice_points.pop_back()
	var slice := SliceInput.construct()
	current_slice = slice
	slice.sliced.connect(_on_slice_sliced)
	add_child(slice)
	slice.global_position = slice_point


func move_slice() -> void:
	pass
	# On the first slice, we need the last fragment
	# safe to use slice points count?
	var i: int = slice_points.size()
	var fragment: Sprite2D = onion_slices[i]
	var new_position := Vector2()
	new_position.x = fragment.position.x + 64 + (i * 4)
	var polarity: int = 1 if i % 2 == 0 else -1
	new_position.y = fragment.position.y + (polarity * 64)

	var tween := create_tween()

	(tween
		.tween_property(fragment, "position", new_position, 0.2)
		.set_trans(Tween.TRANS_CUBIC)
		.set_ease(Tween.EASE_OUT)
	)


func win() -> void:
	blur_amount = 0
	onion_holder.hide()
	var tween := create_tween()
	tween.tween_property(background, "modulate:a", 0.2, 0.2)
	var showcase := ShowOffItem.construct(load("uid://c43figngusf10") as Texture2D)
	add_child(showcase)
	EventBus.prompt_requested.emit("Onions sliced!")
	await showcase.finished
	GlobalState.current_item = GlobalState.Items.NONE
	GlobalState.is_onion_done = true
	EventBus.scene_change_requested.emit("uid://cu0hrfgp6mbuy")


func _on_slice_sliced() -> void:
	current_slice.queue_free()
	move_slice()
	if slice_points.is_empty():
		win()
		return
	pop_slice()
	blur_amount += 1.0
	if blur_amount >= 3:
		obscure_eyes()


func obscure_eyes() -> void:
	current_slice.enabled = false
	wipe_prompt.show()
	for node: CanvasItem in wipe_prompt.get_children():
		Utils.fade_in_item(node, 0.2)
	

func wipe_eyes() -> void:
	wipe_input.value = 0
	wipe_prompt.hide()
	blur_amount = 0
	current_slice.enabled = true


func _on_wipe_input_value_changed(value: float) -> void:
	if value == 100.0:
		wipe_eyes()
