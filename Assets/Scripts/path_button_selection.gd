extends HBoxContainer

@onready var pathButton = $PathButton
@onready var folderButton = $FolderButton
@onready var fileDialog = $FileDialog
@onready var revertButton = $RevertButton

@export_enum("FOLDER", "MAPS") var MODE: int
@export var no_revert = false


signal value_changed(value)

var default_value = "" # to revert back
var value
var file_extension: PackedStringArray = ["*.Gbx", "*.gbx"] # maps extensions


func _ready() -> void:
	revertButton.visible = false
	if value != null:
		default_value = value
		pathButton.text = value
	else:
		value = default_value
		pathButton.text = value
		
	match MODE:
		0: #FOLDER
			fileDialog.use_native_dialog = true
			fileDialog.set_file_mode(2)
		
		1: #MAPS
			fileDialog.set_file_mode(1)
			fileDialog.use_native_dialog = false
			fileDialog.filters = file_extension

func revert(state=true):
	revertButton.visible = state

func update_value(val):
	value = val
	pathButton.text = str(value).replace('"', "").replace("[", "").replace("]", "")

func _on_path_button_pressed() -> void:
	fileDialog.show()

func _on_file_dialog_dir_selected(dir: String) -> void:
	update_value(dir)
	emit_signal("value_changed", value)
	if not no_revert:
		revertButton.visible = true

func _on_folder_button_pressed() -> void:
	_on_path_button_pressed()

func _on_revert_button_pressed() -> void:
	update_value(default_value)
	emit_signal("value_changed", value)
	revertButton.visible = false

func _on_file_dialog_files_selected(paths: PackedStringArray) -> void:
	update_value(paths)
	if not no_revert:
		revertButton.visible = true
