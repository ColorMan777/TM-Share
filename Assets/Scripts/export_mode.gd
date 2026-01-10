extends Control


var modeScene: String = "res://Assets/Scenes/MapOptions.tscn"
var export_path = ""

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(modeScene)
