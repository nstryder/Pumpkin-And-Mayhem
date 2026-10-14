extends Node2D
class_name ShakeInput

signal completed


var touched_end: bool = false


@onready var slider: VSlider = $Slider


func _on_slider_value_changed(value: float) -> void:
	if value == 0:
		touched_end = true
	elif touched_end and value == 100:
		completed.emit()
