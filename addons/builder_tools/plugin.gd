@tool
extends EditorPlugin

var dock

func _enter_tree():
	dock = preload("res://addons/builder_tools/dock.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)

func _exit_tree():
	if dock:
		remove_control_from_docks(dock)
		dock.queue_free()
