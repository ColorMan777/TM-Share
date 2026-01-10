extends Control


var modeScene: String = "res://Assets/Scenes/MapOptions.tscn"
var export_path = ""

var map_selection = []

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(modeScene)


func _on_item_list_multi_selected(index: int, selected: bool) -> void: #Make array from multiple selection
	if selected:
		if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CTRL): # add to selection if CTRL or SHIFT is pressed
			if map_selection.find(index) == -1:
				map_selection.append(index)
		else:
			map_selection = [index] #Put back selection to one item if no keys pressed
	else:
		map_selection.remove_at(map_selection.find(index)) #Deselction
