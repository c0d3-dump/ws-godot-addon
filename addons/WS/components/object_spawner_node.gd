extends Node

@export var lobby_id: String = ""
@export var target: Resource

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if not WS.has_connected():
		return
	
	var sync_data: Variant = WS.get_data(lobby_id)
	if sync_data == null or sync_data["node_name"] != name:
		return

func new_instance(id: String) -> void:
	var target_instance: Node = target.instantiate()
	target_instance.name = id
	add_child(target_instance)

func remove_instance(id: String) -> void:
	var target_instance: Node = get_node(id)
	remove_child(target_instance)
