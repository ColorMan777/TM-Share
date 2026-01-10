extends Control

var mapOptionScene:String = "res://Assets/Scenes/MapOptions.tscn"

@export var backButton: Control
@export var optionButton: Control
@export var mainMenu: Control
@export var optionMenu: Control
@export var titleBar: Control
@export var trackmaniaPathButton: Control
@export var mainMenuPathWarning: Control
@export var pathErrorLabel: Control
@export var trackmania2020Button: Control

@export var greenColor: Color
@export var redColor: Color

func _ready() -> void:
	main_menu()
	
	trackmaniaPathButton.default_value = TmShare.default_trackmania_path
	
	if TmShare.trackmania_path != "":
		update_text_colors(true)
	
	else:
		update_text_colors(false)

func main_menu(): # show main menu (same scene)
	backButton.visible = false
	mainMenu.visible = true
	optionMenu.visible = false
	titleBar.text = mainMenu.name

func option_menu(): # show option menu (same scene)
	backButton.visible = true
	mainMenu.visible = false
	optionMenu.visible = true
	titleBar.text = optionMenu.name

func update_text_colors(good_path:bool): # updates colors etc | for ex. text also if path is found or not
	if good_path:
		trackmaniaPathButton.update_value(TmShare.trackmania_path)
		mainMenuPathWarning.text = "INSTALLATION_DETECTED"
		mainMenuPathWarning.set("theme_override_colors/font_color", greenColor)
		pathErrorLabel.set("theme_override_colors/font_color", greenColor)
		pathErrorLabel.text = "INSTALLATION_DETECTED"
		trackmania2020Button.disabled = false
	else:
		mainMenuPathWarning.text = "INSTALLATION_NOT_DETECTED"
		mainMenuPathWarning.set("theme_override_colors/font_color", redColor)
		pathErrorLabel.set("theme_override_colors/font_color", redColor)
		pathErrorLabel.text = "INSTALLATION_NOT_DETECTED"
		trackmania2020Button.disabled = true

func _on_options_button_pressed() -> void:
	if not titleBar.text == optionMenu.name: # toggle option menu
		option_menu()
	else:
		main_menu()

func _on_back_button_pressed() -> void:
	if titleBar.text == optionMenu.name:
		main_menu()

func _on_path_button_container_value_changed(value: Variant) -> void: #UPDATE WHEN FOLDER SELECTED
	TmShare.update_trackmania_path(value)
	if DirAccess.dir_exists_absolute(TmShare.maps_path):
		update_text_colors(true)
	else:
		update_text_colors(false)


func _on_trackmania_2020_button_pressed() -> void:
	get_tree().change_scene_to_file(mapOptionScene)
