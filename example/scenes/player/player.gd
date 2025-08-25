class_name Player
extends CharacterBody3D

@onready var camera: Camera3D = %Camera3D
@onready var camera_holder: Node3D = %CameraHolder

@export var gravity: float = 150
@export var speed: float = 550
@export var jump_velocity: float = 40
@export var mouse_sensitivity: float = 0.005

var is_authority: bool = false

func _ready() -> void:
	is_authority = WS.is_authority(name)
	camera.current = is_authority
	if is_authority:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if not is_authority:
		return
	
	if event.is_action_pressed("ui_accept"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		var pos: Vector2 = -event.screen_relative
		self.rotation.y += pos.x * mouse_sensitivity
		camera_holder.rotation.x += pos.y * mouse_sensitivity
		camera_holder.rotation.x = clampf(camera_holder.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	if not is_authority or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("jump"):
		velocity.y += jump_velocity   
	
	var direction := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = direction.rotated(-self.rotation.y)
	velocity.x = direction.x * speed * delta
	velocity.z = direction.y * speed * delta
	move_and_slide()
