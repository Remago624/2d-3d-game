@tool
extends VBoxContainer

@onready var arrange_by_name: Button = $ArrangeByName
@onready var arrange_grid: Button = $ArrangeGrid

@onready var spacing_x: SpinBox = $SpacingX
@onready var spacing_z: SpinBox = $SpacingZ
@onready var columns: SpinBox = $Columns


func _ready():
	arrange_by_name.pressed.connect(_on_arrange_name_pressed)
	arrange_grid.pressed.connect(_on_arrange_grid_pressed)

	spacing_x.value = 5
	spacing_z.value = 5
	columns.value = 8


func _get_nodes() -> Array:
	var root = get_tree().edited_scene_root

	if root == null:
		return []

	var result := []
	_collect(root, result)
	return result


func _collect(node: Node, arr: Array):
	for child in node.get_children():
		if child is Node3D:
			arr.append(child)
		_collect(child, arr)


func _on_arrange_grid_pressed():

	var nodes = _get_nodes()

	nodes.sort_custom(func(a, b):
		return a.name.naturalnocasecmp_to(b.name) < 0
	)

	var index := 0

	for node in nodes:

		var col = index % int(columns.value)
		var row = index / int(columns.value)

		node.position = Vector3(
			col * spacing_x.value,
			0,
			row * spacing_z.value
		)

		index += 1


func _on_arrange_name_pressed():

	var nodes = _get_nodes()

	nodes.sort()

	var col := 0
	var row := 0

	for node in nodes:

		node.position.x = col * spacing_x.value
		node.position.y = 0
		node.position.z = row * spacing_z.value

		col += 1

		if col >= int(columns.value):
			col = 0
			row += 1
