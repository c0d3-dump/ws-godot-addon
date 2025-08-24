extends Node

@export var lobby_id: String = ""
@export var target: Resource
@export var target_positions: Array[Vector3]
@export var target_rotations: Array[Vector3]

func _ready() -> void:
	WS.member_joined_ws.connect(_on_member_joined.bind())
	WS.member_left_ws.connect(_on_member_left.bind())

func _process(_delta: float) -> void:
	if WS.has_connected():
		set_process(false)
		
		var sockets := WS.get_all_ws_lobby_members(lobby_id)
		for socket in sockets:
			new_instance(socket)

func _on_member_joined(id: String) -> void:
	new_instance(id)

func _on_member_left(id: String) -> void:
	remove_instance(id)

func new_instance(id: String) -> void:
	var target_instance: Node = target.instantiate()
	target_instance.name = id
	add_child(target_instance)

func remove_instance(id: String) -> void:
	var target_instance: Node = get_node(id)
	remove_child(target_instance)
