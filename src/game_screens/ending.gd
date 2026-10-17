extends Node2D

@onready var feedback: Label = %Feedback
@onready var grade: Label = %Grade


func _ready() -> void:
	if GlobalState.mistakes_made == 0:
		feedback.text = "The soup turned out great!\nEveryone had a great time."
		grade.text = "Superb!"
	elif GlobalState.mistakes_made <= 3:
		feedback.text = "The soup was okay.\nPeople chatted away, not saying much about the soup."
		grade.text = "O.K."
	else:
		feedback.text = "The soup was pretty bad.\nEveryone sat at the table in awkward silence."
		grade.text = "Poor."
	
	if GlobalState.garlic_status == GlobalState.Status.TWISTED:
		feedback.text += "\n\nYour vampire Uncle Ben does not\nseem pleased to find his note in your soup."


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	get_tree().change_scene_to_packed(load("uid://1dnht4lmf0om") as PackedScene)
