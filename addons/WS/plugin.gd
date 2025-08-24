@tool
extends EditorPlugin

func _enable_plugin() -> void:
	add_autoload_singleton("WS", "scripts/ws.gd")

func _disable_plugin() -> void:
	remove_autoload_singleton("WS")

func _enter_tree() -> void:
	add_custom_type("spawner_node", "Node", preload("components/spawner_node/spawner_node.gd"), preload("assets/play.png"))
	add_custom_type("sync_node", "Node", preload("components/sync_node/sync_node.gd"), preload("assets/refresh.png"))

func _exit_tree() -> void:
	remove_custom_type("spawner_node")
	remove_custom_type("sync_node")
