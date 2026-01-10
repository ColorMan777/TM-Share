extends Control

@export var itemList:Control
@export var mapsIcons:Texture2D
@export var exportButton:Control
@export var progressBar:Control

var modeScene: String = "res://Assets/Scenes/MapOptions.tscn"
var export_path = ""

var available_maps = []
var map_selection = []

func _ready() -> void:
	progressBar.value = 0.0
	refresh_list()
	if export_path == "":
		exportButton.disabled = true

func refresh_list():
	itemList.clear()
	map_selection = []
	exportButton.disabled = true
	available_maps = TmShare.list_maps()
	
	for map in available_maps:
		#itemList.add_item(map.replace(".Map.Gbx", ""), mapsIcons) #without file extension
		itemList.add_item(map, mapsIcons) # with file extension
	

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
	
	if map_selection != [] and export_path != "":
		exportButton.disabled = false
	else:
		exportButton.disabled = true


func _on_refresh_button_pressed() -> void:
	refresh_list()

func _on_path_button_container_value_changed(value: Variant) -> void:
	export_path = value
	if export_path != "" and map_selection != []:
		exportButton.disabled = false


func _on_export_button_pressed() -> void:
	progressBar.value = 0
	for map in map_selection:
		var export_map = available_maps.get(map)
		#print(export_map)
		TmShare.export_maps(TmShare.maps_path + export_map, export_path)
		progressBar.value += 100.0 / map_selection.size() # progress bar based on how many maps exported (I don't know how to do it better... call deferred maybe idk)
		#print(progressBar.value)
		await get_tree().process_frame
	progressBar.value = 100.0
