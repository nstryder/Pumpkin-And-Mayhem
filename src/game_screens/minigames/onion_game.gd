extends Node2D

signal won

@export var cuts_quantity: int = 8

var slice_points: Array[Vector2] = []
var current_slice: SliceInput
var blur_amount: float = 0.0:
	set(value):
		blur_amount = value
		var blur_mat: ShaderMaterial = blur_texture.material
		blur_mat.set_shader_parameter("lod", value)


@onready var onion: TextureRect = %Onion
@onready var blur_texture: ColorRect = %BlurTexture
@onready var wipe_prompt: CanvasLayer = %WipePrompt
@onready var wipe_input: HSlider = %WipeInput

# Blur screen every 3 slices 
# Disable slice input 
# On wipe, unblur and reenable slice input


func _ready() -> void:
	var rect: Rect2 = onion.get_global_rect()
	var mid_height: float = rect.get_center().y
	var segment_width: float = rect.size.x / (cuts_quantity + 1)

	for i in cuts_quantity:
		var slice_point := Vector2()
		slice_point.x = (segment_width * (i + 1)) + rect.position.x
		slice_point.y = mid_height
		slice_points.push_back(slice_point)
	pop_slice()


func pop_slice() -> void:
	var slice_point: Vector2 = slice_points.pop_back()
	var slice := SliceInput.construct()
	current_slice = slice
	slice.sliced.connect(_on_slice_sliced)
	add_child(slice)
	slice.global_position = slice_point


func _on_slice_sliced() -> void:
	current_slice.queue_free()
	if slice_points.is_empty():
		print("Win!")
		won.emit()

		blur_amount = 0
		var win_label: Label = $DebugWin
		Utils.fade_in_item(win_label, 1.0)

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
