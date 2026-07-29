extends Node3D
@onready var hit_rect = $UI/ColorRect
@onready var spawns = $Spawns
@onready var nav_region = $NavigationRegion3D
var zombie = load("res://Scenes/zombie.tscn")
var instance
@onready var death_screen = $UI/DeathScreen
@onready var player = $NavigationRegion3D/Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()


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
	instance = zombie.instantiate()
	
	instance.position = spawn_point + Vector3(
	randf_range(-2.0, 2.0),
	0,
	randf_range(-2.0, 2.0))
	#instance.position = spawn_point
	nav_region.add_child(instance)

func _on_player_player_died() -> void:
	death_screen.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
