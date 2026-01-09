extends Control

@export var mainMenuScene: String = "res://Assets/Scenes/Main.tscn"

@export var backButton: Control


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(mainMenuScene)
