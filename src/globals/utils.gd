class_name Utils


static func fade_in_item(canvas_item: CanvasItem, duration_secs: float = 1.0) -> void:
    canvas_item.modulate.a = 0
    canvas_item.show()
    var tween := canvas_item.get_tree().create_tween()
    tween.tween_property(canvas_item, "modulate:a", 1.0, duration_secs)


static func event_is_left_click(event: InputEvent) -> bool:
    if event is not InputEventMouseButton:
        return false

    var button_event: InputEventMouseButton = event
    return button_event.button_index == MOUSE_BUTTON_LEFT
