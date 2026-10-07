extends Line2D
class_name Trail

@export var length: int = 32

# We only want a one-way enablement so we can fade out points when disabling the trail
var enabled: bool = false:
	set(value):
		enabled = value
		if value == true:
			set_process(true)


func _process(_delta: float) -> void:
	if enabled:
		add_point(get_global_mouse_position())
		if points.size() > length:
			remove_point(0)
	elif not points.is_empty():
		remove_point(0)
	
	if points.is_empty():
		set_process(false)