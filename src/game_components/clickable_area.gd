extends Area2D
class_name ClickableArea

signal clicked


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if get_viewport().is_input_handled():
		return
	
	if not Utils.event_is_left_click(event):
		return
	
	get_viewport().set_input_as_handled()
	clicked.emit()
