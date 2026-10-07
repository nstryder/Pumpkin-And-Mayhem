extends Line2D
class_name SliceVfx


var _length: int
var _from: Vector2
var _to: Vector2
var _duration_secs: float
var _current_time: float = 0.0


func _ready() -> void:
	set_process(false)


func show_slice(from: Vector2, to: Vector2, duration_secs: float, length: int = 32) -> void:
	_from = from
	_to = to
	_duration_secs = duration_secs
	_length = length
	_current_time = 0.0
	clear_points()
	set_process(true)


func _process(delta: float) -> void:
	var new_point: Vector2 = _from.lerp(_to, _current_time / _duration_secs)
	if _current_time < _duration_secs:
		_current_time += delta
		add_point(new_point)
		if points.size() > _length:
			remove_point(0)
	else:
		if not points.is_empty():
			remove_point(0)
		else:
			queue_free()
