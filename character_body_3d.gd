extends CharacterBody3D

var mouse_sens: float = 0.001
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var camera = $Node3D/Camera3D
const bob_freq = 2.0
const bob_amp = 0.08
var t_bob = 0.0
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
var bullet = load("res://Scenes/bullet.tscn")
var instance
var instance2
@onready var gun_anim = $"Node3D/Camera3D/Root Scene/AnimationPlayer"
@onready var gun_anim2 = $"Node3D/Camera3D/Root Scene2/AnimationPlayer"
@onready var gun_ray_cast = $"Node3D/Camera3D/Root Scene/RayCast3D"
@onready var gun_ray_cast2 = $"Node3D/Camera3D/Root Scene2/RayCast3D"

func _unhandled_input(event: InputEvent) -> void:
	var rot := $Node3D
	var camera := $Node3D/Camera3D
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rot.rotate_y(-event.relative.x * mouse_sens)
			camera.rotate_x(-event.relative.y * mouse_sens)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = ($Node3D.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if Input.is_action_just_pressed("shoot"):
		_on_fire_timer_timeout()
		$FireTimer.start()
	if Input.is_action_just_released("shoot"):
		$FireTimer.stop()
		gun_anim.play("RESET")
		gun_anim2.play("RESET")
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	move_and_slide()


func _on_fire_timer_timeout() -> void:
	gun_anim.play("shoot")
	gun_anim2.play("shoot")
	instance = bullet.instantiate()
	instance2 = bullet.instantiate()
	instance.position = gun_ray_cast.global_position
	instance2.position = gun_ray_cast2.global_position
	instance.transform.basis = gun_ray_cast.global_transform.basis
	instance2.transform.basis = gun_ray_cast2.global_transform.basis
	get_parent().add_child(instance)
	get_parent().add_child(instance2)


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	return pos
