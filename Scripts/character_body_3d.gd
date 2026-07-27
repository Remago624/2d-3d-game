extends CharacterBody3D
var mouse_sens: float = 0.001
var speed = 5.0
const walk_speed = 5.0
const sprint_speed = 8.0
const maya3a_speed = 3.0
var JUMP_VELOCITY = 4.5
const crouchJ_change = 1.0
const crouchV_change = 0.3
@onready var camera = $Node3D/Camera3D
const FOV = 70.0
const FOV_change = 1.5
const bob_freq = 2.0
const bob_amp = 0.08
var t_bob = 0.0
var FireDamage = 1.5
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
var bullet = load("res://Scenes/bullet.tscn")
var instance
var instance2
@onready var gun_anim = $"Node3D/Camera3D/Root Scene/AnimationPlayer"
@onready var gun_anim2 = $"Node3D/Camera3D/Root Scene2/AnimationPlayer"
@onready var gun_ray_cast = $"Node3D/Camera3D/Root Scene/RayCast3D"
@onready var gun_ray_cast2 = $"Node3D/Camera3D/Root Scene2/RayCast3D"
@onready var gun = $"Node3D/Camera3D/Root Scene"
@onready var node3d = $Node3D
signal player_hit
const hit_stagger = 8.0

func _ready():
	#add_to_group("player") and this is the rest of the problem. You may know the solution to the problem and laugh at me for how it easy. get lost, why are you reading this rn :|
	pass

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
		
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = ($Node3D.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#walk and sprint
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
	elif Input.is_action_pressed("maya3a"):
		speed = maya3a_speed
	else:
		speed = walk_speed
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)	
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
		
	if Input.is_action_just_pressed("shoot"):
		_on_fire_timer_timeout()
		$FireTimer.start()
	if Input.is_action_just_released("shoot"):
		$FireTimer.stop()
		gun_anim.play("RESET")
		gun_anim2.play("RESET")
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	#FOV
	var velocity_clamped = clamp(velocity.length(), 5.0, sprint_speed * 2)
	var target_FOV = FOV + FOV_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_FOV, delta * 6.0)
	_crouch()
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
	pos.x = cos(time * bob_freq / 2) * bob_amp
	return pos

func hit(dir):
	emit_signal("player_hit")
	velocity += dir * hit_stagger
func _crouch():
	if Input.is_action_just_pressed("maya3a"):
		node3d.global_position.y -= crouchV_change
		JUMP_VELOCITY -= crouchJ_change
	elif Input.is_action_just_released("maya3a"):
		node3d.global_position.y += crouchV_change
		JUMP_VELOCITY += crouchJ_change
