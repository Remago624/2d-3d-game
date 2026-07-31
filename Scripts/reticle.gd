extends CenterContainer
@export var reticle_lines : Array[Line2D]
@export var player_controller : CharacterBody3D
@export var reticle_speed : float = 0.025
@export var reticle_distance : float = 2.0
@export var dot_radius : float =1.0
@export var dot_color : Color = Color.WHITE
const center = Vector2(20,20)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_redraw()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	adjust_reticel_lines()

func _draw():
	draw_circle(center, dot_radius, dot_color)

func adjust_reticel_lines():
	var vel = clamp(player_controller.get_real_velocity().length(), 0, 25)
	reticle_lines[0].position = lerp(reticle_lines[0].position, center + Vector2(0, -vel * reticle_distance), reticle_speed)
	reticle_lines[1].position = lerp(reticle_lines[1].position, center + Vector2(vel * reticle_distance, 0), reticle_speed)
	reticle_lines[2].position = lerp(reticle_lines[2].position, center + Vector2(0, vel * reticle_distance), reticle_speed)
	reticle_lines[3].position = lerp(reticle_lines[3].position, center + Vector2(-vel * reticle_distance, 0), reticle_speed)
