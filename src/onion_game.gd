extends Node2D

signal won

@export var cuts_quantity: int = 8

var slice_points: Array[Vector2] = []
var current_slice: SliceInput

@onready var onion: TextureRect = %Onion


func _ready() -> void:
	var rect: Rect2 = onion.get_global_rect()
	print(rect)
	var mid_height: float = rect.get_center().y
	var segment_width: float = rect.size.x / (cuts_quantity + 1)

	for i in cuts_quantity:
		var slice_point := Vector2()
		slice_point.x = (segment_width * (i + 1)) + rect.position.x
		slice_point.y = mid_height
		slice_points.push_back(slice_point)
	print(slice_points)
	pop_slice()


func pop_slice() -> void:
	print("Spawning a slice!")
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
		
		var win_label: Label = $DebugWin
		win_label.modulate.a = 0
		win_label.show()
		var tween := create_tween()
		tween.tween_property(win_label, "modulate:a", 1.0, 1.0)
	else:
		pop_slice()
