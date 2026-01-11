extends Control

@export var fileDialog:Window
@export var importButton:Control
@export var importSection:Control
@export var itemList:Control
@export var mapsIcons:Texture2D
@export var warningDialog:Window


var modeScene: String = "res://Assets/Scenes/MapOptions.tscn"

var map_selection = [] # for menu selection only

var import_files = [] # files to import at the end
var not_imported = [] # failed import (not good extension etc)

func _ready() -> void:
	get_viewport().files_dropped.connect(on_files_dropped)
	show_import_button()
	itemList.clear()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(modeScene)

func on_files_dropped(files): # DRAG AND DROP ADD MAPS
	import_files_list(files)
	
func _on_file_dialog_files_selected(paths: PackedStringArray) -> void: # FILE DIALOG ADD MAPS
	import_files_list(paths)

func import_files_list(files):
	not_imported = [] # reset not imported (not cumulative like imported)
	
	for f in files:
		if f.ends_with(".zip"): # zip archive filtering
			if import_files.find(f) == -1:
				import_files.append(f) #cumulative import
				itemList.add_item(f.get_file(), mapsIcons)
		else:
			if not_imported.find(f) == -1:
				not_imported.append(f)
	
	if not_imported.size() > 0:
		var error = ""
		for bad in not_imported:
			error += bad.get_file() + "\n" # list files names in String
		warningDialog.dialog_text = tr("NOT_IMPORTED") + "\n" + error
		warningDialog.show()
	
	#print("imported : " + str(import_files))
	#print("not_imported : " + str(not_imported))
	if import_files.size() > 0: # if files imported show import section (prevent to show it with bad drag and drop)
		show_import_section()


func show_import_button():
	importButton.visible = true
	importSection.visible = false

func show_import_section():
	importButton.visible = false
	importSection.visible = true

func reset_import(all=false):
	if all:
		show_import_button()
		import_files = []
		map_selection = []
		not_imported = []
		itemList.clear()
	else:
		pass

func _on_import_button_pressed() -> void:
	fileDialog.visible = true
	

func _on_remove_all_button_pressed() -> void:
	reset_import(true)
	
func _on_remove_button_2_pressed() -> void:
	reset_import()
