extends Node3D

@onready var pause_menu = $PauseMenu
var on_pause = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_menu.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_pause()
	
func handle_pause():
	if Input.is_action_just_pressed("pause"):
		on_pause = !on_pause
		get_tree().paused = not get_tree().paused
		pause_menu.visible = not pause_menu.visible
		
		if on_pause:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
