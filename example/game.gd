class_name Game
extends Node

func _ready() -> void:
	WS.setup("localhost", 9080)
	
	transition(Preloads.MAIN_MENU_PREFAB)

func transition(scene_prefab: Resource) -> void:
	var scene: Node = scene_prefab.instantiate()
	add_child(scene)
