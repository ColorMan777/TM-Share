extends Control

var mainMenuScene: String = "res://Assets/Scenes/Main.tscn"
var exportScene: String = "res://Assets/Scenes/ExportMode.tscn"
var importScene: String = "res://Assets/Scenes/ImportMode.tscn"


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(mainMenuScene)


func _on_export_button_pressed() -> void:
	get_tree().change_scene_to_file(exportScene)


func _on_import_button_pressed() -> void:
	get_tree().change_scene_to_file(importScene)
