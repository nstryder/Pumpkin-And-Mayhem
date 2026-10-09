extends Area2D
class_name DraggableArea


var click_offset := Vector2()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = get_global_mouse_position() + click_offset


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if get_viewport().is_input_handled():
		return

	if not Utils.event_is_left_click(event):
		return
	
	click_offset = global_position - get_global_mouse_position()
	set_process(event.is_pressed())
	get_viewport().set_input_as_handled()
