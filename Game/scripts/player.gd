extends CharacterBody3D

# Player nodes
@onready var head = $head
@onready var standing_collision_shape = $Standing_collision_shape
@onready var crouching_collision_shape = $Crouching_collision_shape
@onready var ray_cast_3d = $RayCast3D
@onready var dash_timer = $dash_timer
@onready var dash_again_timer = $dash_again_timer

# Variables
# Movement Speed variables
const WALFING_SPEED := 10
const DASH_SPEED := 40
const CROUCH_SPEED:= 7
var current_speed := WALFING_SPEED

# Movement variables
var jump_velocity := 8
const LERP_SPEED := 15
const AIR_LERP_SPEED := 2 
var current_lerp_speed := LERP_SPEED
var dashing := false
var can_dash = true

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
		current_speed = CROUCH_SPEED
		
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		
		head.position.y = lerp(head.position.y, head_y_position + crouching_depth, delta * LERP_SPEED * 2)
	elif !ray_cast_3d.is_colliding():
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		
		head.position.y = lerp(head.position.y, head_y_position, delta * LERP_SPEED)
				
		current_speed = WALFING_SPEED
	if Input.is_action_just_pressed("dash") and can_dash:
		dashing = true
		can_dash = false
		dash_timer.start()
		dash_again_timer.start()
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		current_lerp_speed = AIR_LERP_SPEED
	else:
		current_lerp_speed = LERP_SPEED

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * current_lerp_speed)
	if direction:
		if dashing:
			velocity.x = direction.x * DASH_SPEED
			velocity.z = direction.z * DASH_SPEED
		else:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()


func _on_dash_timer_timeout():
	dashing = false


func _on_dash_again_timer_timeout():
	can_dash = true
