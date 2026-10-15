extends CharacterBody3D

# PLAYER MOVEMENT SETTINGS #
@export var walk_speed: float = 4.0
@export var sprint_speed: float = 6.5
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002

@export var crouch_speed: float = 2.0

# Collision height
@export var standing_height: float = 1.8
@export var crouching_height: float = 1.0

@export var standing_eye_height: float = 1.6
@export var crouching_eye_height: float = 0.8

# How quickly the player changes between standing and crouching
@export var crouch_transition_speed: float = 6.0

# Reference to the player's collision and interactables
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var ceiling_check: RayCast3D = $CeilingCheck
@onready var interaction_ray: RayCast3D = $Head/Camera3D/InteractionRay
@onready var interaction_prompt: Label = $InteractionUI/InteractionPrompt

# Check for whether there's room to stand up
var is_crouching: bool = false

@onready var head: Node3D = $Head

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Runs once when the player enters the scene.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	interaction_prompt.hide()

# Handles mouse movement and releasing the cursor.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)

		# Stop the player looking too far up or down.
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-85), deg_to_rad(85))
		
	# Press E to interact with objects
	if event.is_action_pressed("interact") and not event.is_echo():
		interact()


# Runs every physics frame to handle movement.
func _physics_process(delta: float) -> void:

	handle_crouch(delta)

	# Apply gravity while airborne
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump only when standing on the ground
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity

	# Choose movement speed depending on whether Shift is held
	var current_speed: float = walk_speed

	if is_crouching:
		current_speed = crouch_speed
	elif Input.is_action_pressed("sprint"):
		current_speed = sprint_speed

	# Read WASD input as a 2D direction.
	var input_dir: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	# Convert the input direction into the player's 3D direction.
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Apply horizontal movement.
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed

	# Check whether the player is looking at something interactable
	update_interaction_prompt()
	
	# Move the player and handle collisions.
	move_and_slide()


func handle_crouch(delta: float) -> void:
	var wants_to_crouch: bool = Input.is_action_pressed("crouch")

	# If there's a ceiling above, stay crouched
	if ceiling_check.is_colliding():
		wants_to_crouch = true

	is_crouching = wants_to_crouch

	# Decide which height we should move towards
	var target_height: float = standing_height
	var target_eye_height: float = standing_eye_height

	if is_crouching:
		target_height = crouching_height
		target_eye_height = crouching_eye_height

	# Resize the capsule smoothly
	var player: CapsuleShape3D = collision_shape.shape as CapsuleShape3D

	player.height = move_toward(
		player.height,
		target_height,
		crouch_transition_speed * delta
	)

	# Keep the bottom of the capsule on the floor.
	collision_shape.position.y = player.height / 2.0

	# Smoothly raise or lower the camera
	head.position.y = move_toward(
		head.position.y,
		target_eye_height,
		crouch_transition_speed * delta
	)
	
# If dialogue is open, advance it - Otherwise interact with an object
func interact() -> void:
	var dialogue_ui = get_tree().current_scene.get_node_or_null("DialogueUI")

	if dialogue_ui != null and dialogue_ui.dialogue_open:
		dialogue_ui.next_dialogue()
		return

	if interaction_ray.is_colliding():
		var object = interaction_ray.get_collider()

		if object.has_method("interact"):
			object.interact()

# Show prompt when looking at something interactable
func update_interaction_prompt() -> void:
	interaction_prompt.hide()

	# Hide the prompt while reading dialogue
	var dialogue_ui = get_tree().current_scene.get_node_or_null("DialogueUI")

	if dialogue_ui != null and dialogue_ui.dialogue_open:
		return

	# Check whether the object we're looking at can be interacted with
	if interaction_ray.is_colliding():
		var object = interaction_ray.get_collider()

		if object.has_method("interact"):
			interaction_prompt.show()
