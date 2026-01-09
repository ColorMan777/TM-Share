extends Control

@export var backButton: Control
@export var optionButton: Control
@export var mainMenu: Control
@export var optionMenu: Control
@export var titleBar: Control
@export var trackmaniaPathButton: Control
@export var mainMenuPathWarning: Control

@export var greenColor: Color
@export var redColor: Color

func _ready() -> void:
	main_menu()
	
	trackmaniaPathButton.default_value = TmShare.default_trackmania_path
	
	if TmShare.trackmania_path != "":
		trackmaniaPathButton.update_value(TmShare.trackmania_path)
		mainMenuPathWarning.text = "INSTALLATION_DETECTED"
		mainMenuPathWarning.set("theme_override_colors/font_color", greenColor)
	
	else:
		mainMenuPathWarning.text = "INSTALLATION_NOT_DETECTED"
		mainMenuPathWarning.set("theme_override_colors/font_color", redColor)

func main_menu():
	backButton.visible = false
	mainMenu.visible = true
	optionMenu.visible = false
	titleBar.text = mainMenu.name

func option_menu():
	backButton.visible = true
	mainMenu.visible = false
	optionMenu.visible = true
	titleBar.text = optionMenu.name

func _on_options_button_pressed() -> void:
	option_menu()

func _on_back_button_pressed() -> void:
	if titleBar.text == optionMenu.name:
		main_menu()

func _on_path_button_container_value_changed(value: Variant) -> void: #UPDATE WHEN FOLDER SELECTED
	TmShare.trackmania_path = value
