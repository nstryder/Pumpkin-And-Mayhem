extends Polygon2D

signal clicked

var tween: Tween

@onready var collision_polygon_2d: CollisionPolygon2D = %CollisionPolygon2D

func _ready() -> void:
	collision_polygon_2d.polygon = polygon
	modulate.a = 0


func _on_clickable_area_clicked() -> void:
	clicked.emit()


func _on_clickable_area_mouse_entered() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.1)


func _on_clickable_area_mouse_exited() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.1)
