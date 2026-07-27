extends CharacterBody3D

const speed = 4.0
var player = null
var state
@export var player_path := "/root/world/NavigationRegion3D/Player"
@onready var new_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var Skeleton = $Armature/Skeleton3D
const attack_range = 2.0
var fi = "metadata/FireDamage"
var health = 200
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#player = get_tree().get_first_node_in_group("player") this for old issue, and don't worry I solved it
	player = get_node(player_path)
	state = anim_tree.get("parameters/playback")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity = Vector3.ZERO
	match state.get_current_node():
		"running":
			new_agent.set_target_position(player.global_transform.origin)
			var nvp = new_agent.get_next_path_position()
			velocity = (nvp - global_transform.origin).normalized() * speed
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"attack2":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		

	
	#look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())

	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.global_position) < attack_range

func _hit_finished():
	if global_position.distance_to(player.global_position) < attack_range + 1.0 :
		var dir = global_position.direction_to(player.global_position)
		dir.y = clamp(dir.y, 0.0, 0.4)
		player.hit(dir)


func _on_area_3d_body_part_hit(dam: Variant) -> void:
	health -= dam * player.FireDamage
	if health <= 0:
		queue_free()
