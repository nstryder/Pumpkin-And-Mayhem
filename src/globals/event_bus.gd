extends Node

@warning_ignore_start("unused_signal")
signal scene_change_requested(new_scene_path: String)

## Used for showing text to the user.
signal prompt_requested(text: String)

signal hide_recipe
signal show_recipe
