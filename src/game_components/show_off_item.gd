extends Node2D
class_name ShowOffItem

signal finished

const SELF_SCENE = preload("uid://crao4dskw6ap5")


@export var _texture: Texture2D
@onready var sprite_2d: Sprite2D = $SpriteHolder/Sprite2D


static func construct(texture: Texture2D) -> ShowOffItem:
	var instance: ShowOffItem = SELF_SCENE.instantiate()
	instance._texture = texture
	return instance


func _ready() -> void:
	sprite_2d.texture = _texture


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	finished.emit()
