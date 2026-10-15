extends ClickableArea

# For this to work properly, children sprites should have "Use parent material" enabled.

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	set_stroke_width(0)
	for node in get_children():
		if node is not CanvasItem:
			continue
		var canvas_item: CanvasItem = node
		canvas_item.use_parent_material = true


func set_stroke_width(width: float) -> void:
	var shader: ShaderMaterial = material
	shader.set_shader_parameter("width", width)


func _on_mouse_entered() -> void:
	animation_player.play("pulse")

func _on_mouse_exited() -> void:
	animation_player.stop()
	set_stroke_width(0)
