extends Control

@export var fileDialog:Window
@export var importButton:Control
@export var importSection:Control
@export var itemList:Control
@export var mapsIcons:Texture2D
@export var warningDialog:Window # for not imported
@export var warningDialog2:Window # for not made in tmshare
@export var logsLabel:Control
@export var progressBar:Control

var modeScene: String = "res://Assets/Scenes/MapOptions.tscn"

var map_selection = [] # for menu selection only

var import_files = [] # files to import at the end
var not_imported = [] # failed import (not good extension etc)
var not_made_tmshare = [] # for files not made in tmshare and not imported

func _ready() -> void:
	get_viewport().files_dropped.connect(on_files_dropped)
	show_import_button()
	itemList.clear()
	TmShare.import_logs_label = logsLabel

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(modeScene)

func on_files_dropped(files): # DRAG AND DROP ADD MAPS
	import_files_list(files)
	
func _on_file_dialog_files_selected(paths: PackedStringArray) -> void: # FILE DIALOG ADD MAPS
	import_files_list(paths)

func import_files_list(files):
	not_imported = [] # reset not imported (not cumulative like imported)
	not_made_tmshare = []
	
	for f in files:
		if f.ends_with(".zip"): # zip archive filtering
			
			if have_zip_config_file(f):
				if import_files.find(f) == -1:
					import_files.append(f) #cumulative import
					itemList.add_item(f.get_file(), mapsIcons)
			else:
				if not_made_tmshare.find(f) == -1:
					not_made_tmshare.append(f)
		else:
			if not_imported.find(f) == -1:
				not_imported.append(f)
	
	error_message(warningDialog, "NOT_IMPORTED", not_imported)
	error_message(warningDialog2, "NOT_TMSHARE_MADE", not_made_tmshare)
		
	#print("imported : " + str(import_files))
	#print("not_imported : " + str(not_imported))
	if import_files.size() > 0: # if files imported show import section (prevent to show it with bad drag and drop)
		show_import_section()

func error_message(w_dialog, message:String, w_array:Array): # warning dialog node / error message (for translation) / array with files affected
	if w_array.size() > 0:
		var error = ""
		for bad in w_array:
			error += bad.get_file() + "\n" # list files names in String
		w_dialog.dialog_text = tr(message) + "\n" + error
		w_dialog.show()
		w_array = [] # reset not imported after warning showed up (or any warning arrays)

func have_zip_config_file(path:String):
	var reader = ZIPReader.new()
	var err = reader.open(path)
	if err != OK:
		return false
	#var res = reader.read_file("LevelDesign_Exercise01.Map.Gbx.json")
	var res = reader.get_files()
	reader.close()
	var config_present = false
	for f in res:
		if f.ends_with(".Map.Gbx.json"):
			config_present = true
	return config_present


func show_import_button():
	importButton.visible = true
	importSection.visible = false
	logsLabel.text = ""
	progressBar.value = 0

func show_import_section():
	importButton.visible = false
	importSection.visible = true

func reset_import(all=false):
	if all: # remove all
		show_import_button()
		import_files = []
		map_selection = []
		not_imported = []
		itemList.clear()
	else:
		itemList.deselect_all() # deselect all maps in item list
		map_selection.sort() # sort selection bigger smaller numbers first
		map_selection.reverse() # reverse to get bigger number first since we're going to remove by id : remove the end of the array first
		for r in map_selection: # remove maps in selection
			import_files.remove_at(r) # the inverted array stuff was so hard and so dumb to figure out it's killing me lol
			itemList.remove_item(r)
		map_selection = [] # reset map selection after every selected maps is removed
		
	if import_files.size() == 0: #0 maps = reset to button
		show_import_button()

func _on_import_button_pressed() -> void:
	fileDialog.visible = true
	

func _on_remove_all_button_pressed() -> void:
	reset_import(true)
	
func _on_remove_button_2_pressed() -> void:
	reset_import()

func _on_item_list_multi_selected(index: int, selected: bool) -> void: # SELECTION TO REMOVE MAPS
	if selected:
		if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CTRL): # add to selection if CTRL or SHIFT is pressed
			if map_selection.find(index) == -1:
				map_selection.append(index)
		else:
			map_selection = [index] #Put back selection to one item if no keys pressed
	else:
		map_selection.remove_at(map_selection.find(index)) #Deselction
	

func _on_import_maps_button_pressed() -> void:
	for map in import_files:
		#NOT IMPORT FILE FUNCTION -> IMPORT MAPS
		TmShare.import_maps(map)
