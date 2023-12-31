extends CharacterBody3D

# Player nodes
@onready var head = $head
@onready var standing_collision_shape = $Standing_collision_shape
@onready var crouching_collision_shape = $Crouching_collision_shape
@onready var ray_cast_3d = $RayCast3D

# Variables
# Movement Speed variables
const walking_speed := 10
const dash_speed := 40
const crouch_speed:= 7
var current_speed := walking_speed

# Movement variables
var jump_velocity := 8
const lerp_speed := 10.0
const air_lerp_speed := 2
var current_lerp_speed := lerp_speed

# Informative variable
const head_y_position := 1.8
const crouching_depth := -0.5

# Input variables
const mouse_sensitivity := 0.05
var direction = Vector3.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))		
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Crouch
	if Input.is_action_pressed("crouch"):
		current_speed = crouch_speed
		
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		
		head.position.y = lerp(head.position.y, head_y_position + crouching_depth, delta * lerp_speed * 2)
	elif !ray_cast_3d.is_colliding():
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		
		head.position.y = lerp(head.position.y, head_y_position, delta * lerp_speed)
		
		# Dash
		if Input.is_action_pressed("dash"):
			current_speed = dash_speed
		else:
			current_speed = walking_speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		current_lerp_speed = 3
	else:
		current_lerp_speed = 15

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * current_lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
