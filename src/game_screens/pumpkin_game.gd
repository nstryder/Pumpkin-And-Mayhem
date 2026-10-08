extends Node2D


# Spawn 2 slices at the pumpkin center point, one normal and one horizontal
# Create seed removal module 
# click on oven
# click on food processor 

var slice_count: int = 2
var current_slice: SliceInput

@onready var pumpkin_holder: Node2D = %PumpkinHolder
@onready var pumpkin: Label = %Pumpkin


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


func _on_slice_sliced() -> void:
	current_slice.queue_free()
	if slice_count > 0:
		pop_slice()
