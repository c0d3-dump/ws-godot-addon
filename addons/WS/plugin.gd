@tool
extends EditorPlugin

func _enable_plugin() -> void:
	add_autoload_singleton("WS", "scripts/ws.gd")

func _disable_plugin() -> void:
	remove_autoload_singleton("WS")

func _enter_tree() -> void:
	add_custom_type("PlayerSpawnerNode", "Node", preload("components/player_spawner_node.gd"), preload("assets/play.png"))
	add_custom_type("ObjectSpawnerNode", "Node", preload("components/object_spawner_node.gd"), preload("assets/object.png"))
	add_custom_type("SyncNode", "Node", preload("components/sync_node.gd"), preload("assets/refresh.png"))

func _exit_tree() -> void:
	remove_custom_type("PlayerSpawnerNode")
	remove_custom_type("ObjectSpawnerNode")
	remove_custom_type("SyncNode")
