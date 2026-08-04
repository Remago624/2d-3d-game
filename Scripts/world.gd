extends Node3D
@onready var hit_rect = $UI/ColorRect
@onready var spawns = $Spawns
@onready var ghost_spawns = $G_Spawns
@onready var nav_region = $NavigationRegion3D
var zombie = load("res://Scenes/zombie.tscn")
var ghsot = load("res://Scenes/ghost.tscn")
var instance_zombie
var instance_ghost
@onready var death_screen = $UI/DeathScreen
@onready var player = $NavigationRegion3D/Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	$"NavigationRegion3D/crypt-small/crypt-door2/AnimationPlayer".play("open")
	$"NavigationRegion3D/crypt-large/crypt-large-door2/AnimationPlayer".play("open")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_player_hit() -> void:
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false

func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)


func _on_spawn_timer_timeout() -> void:
	var spawn_point = _get_random_child(spawns).global_position
	instance_zombie = zombie.instantiate()
	instance_zombie.position = spawn_point + Vector3(
	randf_range(-0.1, 0.1),
	0,
	randf_range(-0.1, 0.1))
	
	#instance_zombie.position = spawn_point
	nav_region.add_child(instance_zombie)

func _on_player_player_died() -> void:
	death_screen.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_g_spawn_timer_timeout() -> void:
	var spawn_point2 = _get_random_child(ghost_spawns).global_position
	instance_ghost = ghsot.instantiate()
	instance_ghost.position = spawn_point2 + Vector3(
	randf_range(-0.1, 0.1),
	0,
	randf_range(-0.1, 0.1))
	nav_region.add_child(instance_ghost)
