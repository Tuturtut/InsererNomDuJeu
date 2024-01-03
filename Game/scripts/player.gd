extends CharacterBody3D

# Player nodes
@onready var head = $head
@onready var eyes = $head/eyes

@onready var standing_collision_shape = $Standing_collision_shape
@onready var crouching_collision_shape = $Crouching_collision_shape
@onready var ray_cast_3d = $RayCast3D
@onready var dash_timer = $dash_timer
@onready var dash_again_timer = $dash_again_timer
@onready var camera_3d = $head/eyes/Camera3D

# Variables
# Movement Speed variables
const WALKING_SPEED := 10
const DASH_SPEED := 40
const CROUCH_SPEED:= 7
var current_speed := WALKING_SPEED
var previous_speed := WALKING_SPEED

# Movement variables
var jump_velocity := 10
const LERP_SPEED := 15
const AIR_LERP_SPEED := 2 
var current_lerp_speed := LERP_SPEED


# State
var walking := true
var crouching := false
var dashing := false
var can_dash = true

# Head bobbing variables
const HEAD_BOBBING_WALKING_SPEED = 14.0
const HEAD_BOBBING_CROUCHING_SPEED = 10
 
const HEAD_BOBBING_WALKING_INTENSITY = 0.1
const HEAD_BOBBING_CROUCHING_INTENSITY = 0.05

var head_bobbing_current_intensity = 0.0
var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0

# Informative variable
const head_y_position := 1.8
const crouching_depth := -0.5

# Input variables
const mouse_sensitivity := 0.05
var direction = Vector3.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Debug
var dash_time := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))		
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Dash
	if Input.is_action_just_pressed("dash") and can_dash:
		print("start")
		dashing = true
		can_dash = false
		dash_timer.start()
		dash_again_timer.start()
		# Dash sans mouvement du joueur
		if input_dir == Vector2.ZERO:
			direction = transform.basis * Vector3(0, 0, -1)
			
		# Dash avec mouvement du joueur
		else:
			direction = transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	# Reset speed
	if Input.is_action_just_pressed("reset_speed"):
		direction.x = 0
		direction.z = 0
		
	# Crouch
	if Input.is_action_pressed("crouch"):
		current_speed = CROUCH_SPEED
		
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		walking = false
		crouching = true
		
		head.position.y = lerp(head.position.y, head_y_position + crouching_depth, delta * LERP_SPEED * 2)
	elif !ray_cast_3d.is_colliding():
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		
		head.position.y = lerp(head.position.y, head_y_position, delta * LERP_SPEED)
				
		current_speed = WALKING_SPEED
		walking = true
		crouching = false
		
	
	# Handle headbobbing
	if walking:
		head_bobbing_current_intensity = HEAD_BOBBING_WALKING_INTENSITY
		head_bobbing_index += HEAD_BOBBING_WALKING_SPEED * delta
	elif crouching:
		head_bobbing_current_intensity = HEAD_BOBBING_CROUCHING_INTENSITY
		head_bobbing_index += HEAD_BOBBING_CROUCHING_SPEED * delta
	
	if is_on_floor() && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2)+0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y*(head_bobbing_current_intensity/2.0), delta * LERP_SPEED)	
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x*head_bobbing_current_intensity, delta * LERP_SPEED)
		
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * LERP_SPEED)	
		eyes.position.x = lerp(eyes.position.y, 0.0, delta * LERP_SPEED)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		current_lerp_speed = AIR_LERP_SPEED
	else:
		current_lerp_speed = LERP_SPEED


	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	if dashing: 
		current_speed = DASH_SPEED
	elif crouching:
		current_speed = CROUCH_SPEED
	else:
		current_speed = WALKING_SPEED
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * current_lerp_speed)
	

	
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed



	move_and_slide()


func _on_dash_timer_timeout():
	dashing = false
	print("end")


func _on_dash_again_timer_timeout():
	can_dash = true
