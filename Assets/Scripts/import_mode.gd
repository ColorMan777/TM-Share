extends Control

var modeScene: String = "res://Assets/Scenes/MapOptions.tscn"

var import_files = []
var not_imported = []

func _ready() -> void:
	get_viewport().files_dropped.connect(on_files_dropped)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(modeScene)

func on_files_dropped(files):
	import_files_list(files)
	

func import_files_list(files):
	not_imported = [] # reset not imported (not cumulative like imported)
	
	for f in files:
		if f.ends_with(".Map.Gbx"):
			if import_files.find(f) == -1:
				import_files.append(f) #cumulative import
		else:
			if not_imported.find(f) == -1:
				not_imported.append(f)
	
	#print("imported : " + str(import_files))
	#print("not_imported : " + str(not_imported))
