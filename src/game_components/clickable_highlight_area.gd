extends ClickableArea

## You MUST add a CollisionPolygon2D for this node to work.

var tween: Tween

@onready var highlight: Polygon2D = $Highlight


func _ready() -> void:
	var collision: CollisionPolygon2D = get_node("CollisionPolygon2D")
	highlight.polygon = collision.polygon
	highlight.modulate.a = 0


func _on_mouse_entered() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(highlight, "modulate:a", 1, 0.1)


func _on_mouse_exited() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(highlight, "modulate:a", 0, 0.1)
