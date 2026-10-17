@tool
extends SliceInput

@export var twisted_sprite_full: Texture2D
@export var twisted_sprite_cut: Texture2D

@onready var butter_cut: Sprite2D = $Node2D/ButterCut
@onready var butter_full: Sprite2D = $Node2D/ButterFull

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if GlobalState.butter_status == GlobalState.Status.TWISTED:
		butter_full.texture = twisted_sprite_full
		butter_cut.texture = twisted_sprite_cut
