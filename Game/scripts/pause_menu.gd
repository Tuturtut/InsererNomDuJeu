extends Control

@onready var pause_menu = $pause_menu
@onready var debug_menu = $debug_menu

@onready var crouch_check_button = $debug_menu/GridContainer/HBoxContainer/Crouch/CrouchCheckButton
@onready var dash_check_button = $debug_menu/GridContainer/HBoxContainer/Dash/DashCheckButton
@onready var jump_check_button = $debug_menu/GridContainer/HBoxContainer/Jump/JumpCheckButton

var is_paused: bool = false:
	set = set_paused
	
var is_on_debug_menu := false
	
func _ready():
	visible = false	
	crouch_check_button.button_pressed = true
	dash_check_button.button_pressed = true
	jump_check_button.button_pressed = true

# Change le status de "pause" si le joueur fais pause
func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		is_paused = !is_paused
		
func set_paused(value:bool) -> void:
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused
	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pause_menu.show()
		debug_menu.hide()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_resume_button_pressed():
	is_paused = false


func _on_debug_pressed():
	is_on_debug_menu = true
	hide_and_show(pause_menu, debug_menu)
	
func hide_and_show(hided, showed):
	hided.hide()
	showed.show()

func _on_quit_pressed():
	get_tree().quit()

func _on_debug_back_pressed():
	hide_and_show(debug_menu, pause_menu)


func _on_crouch_check_button_toggled(toggled_on):
	Global.crouch_enabled = toggled_on


func _on_dash_check_button_toggled(toggled_on):
	Global.dash_enabled = toggled_on


func _on_jump_check_button_toggled(toggled_on):
	Global.jump_enabled = toggled_on
