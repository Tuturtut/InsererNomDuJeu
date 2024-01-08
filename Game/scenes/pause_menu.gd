extends Control

var is_paused: bool = false:
	set = set_paused
	
func _ready():
	visible = false	

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
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_resume_button_pressed():
	is_paused = false


func _on_debug_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()
