extends Node2D

@onready var pumpkin: ClickableArea = %Pumpkin

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GlobalState.holds_pumpkin:
		pumpkin.queue_free()


func _on_pumpkin_clicked() -> void:
	GlobalState.holds_pumpkin = true
	pumpkin.queue_free()
