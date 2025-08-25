extends Node

@export var sync_position: bool
@export var sync_rotation: bool
@export var sync_node: Node
@export var lerp_position: float = 0
@export var lerp_rotation: float = 0

var is_authority: bool
var last_tick_time: int
var parent_id: String

func _ready() -> void:
	parent_id = get_multiplayer_parent_id()
	is_authority = WS.is_authority(parent_id)
	last_tick_time = Time.get_ticks_msec()

func _process(_delta: float) -> void:
	if not WS.has_connected():
		return
	
	if is_authority:
		if Time.get_ticks_msec() - last_tick_time < WS.get_tick_rate():
			return
		last_tick_time = Time.get_ticks_msec()
		_send_sync_data()
	else:
		_receive_sync_data()

func _send_sync_data() -> void:
	var data := {"message_type": "broadcast"}
	if sync_node is Node2D:
		var pos: Vector2 = sync_node.position
		var rot: float = sync_node.rotation
		
		data["message"] = {"node_name": name}
		if sync_position:
			data["message"]["position"] = [snappedf(pos.x, 0.01), snappedf(pos.y, 0.01)]
		if sync_rotation:
			data["message"]["rotation"] = snappedf(rot, 0.01)
	elif sync_node is Node3D:
		var pos: Vector3 = sync_node.position
		var rot: Vector3 = sync_node.rotation
		
		data["message"] = {"node_name": name}
		if sync_position:
			data["message"]["position"] = [snappedf(pos.x, 0.01), snappedf(pos.y, 0.01), snappedf(pos.z, 0.01)]
		if sync_rotation:
			data["message"]["rotation"] = [snappedf(rot.x, 0.01), snappedf(rot.y, 0.01), snappedf(rot.z, 0.01)]
	
	WS.send_data(data)

func _receive_sync_data() -> void:
	var sync_data: Variant = WS.get_data(parent_id)
	if sync_data == null or sync_data["node_name"] != name:
		return
	
	if sync_node is Node2D:
		if sync_position:
			var pos: Array = sync_data["position"]
			var pos_vector: Vector2 = Vector2(pos[0], pos[1])
			var current_position: Vector2 = sync_node.global_position
			sync_node.position = pos_vector if lerp_position == 0 else lerp(current_position, pos_vector, lerp_position)
		if sync_rotation:
			var rot: float = sync_data["rotation"]
			var current_rotation: float = sync_node.global_rotation
			sync_node.rotation = rot if lerp_rotation == 0 else lerp_angle(current_rotation, rot, lerp_rotation)
	elif sync_node is Node3D:
		if sync_position:
			var pos: Array = sync_data["position"]
			var pos_vector: Vector3 = Vector3(pos[0], pos[1], pos[2])
			var current_position: Vector3 = sync_node.global_position
			sync_node.position = pos_vector if lerp_position == 0 else lerp(current_position, pos_vector, lerp_position)
		if sync_rotation:
			var rot: Array = sync_data["rotation"]
			var rot_vector: Vector3 = Vector3(rot[0], rot[1], rot[2])
			var current_rotation: Vector3 = sync_node.global_rotation
			sync_node.rotation = rot_vector if lerp_rotation == 0 else lerp(current_rotation, rot_vector, lerp_rotation)

func get_multiplayer_parent_id() -> String:
	var node := get_parent()
	while node != null:
		var groups := node.get_groups()
		var res := groups.find_custom(func(group: StringName): return group.contains("userId:"))
		if res != -1:
			return groups.get(res).replace("userId:", "")
		node = node.get_parent()
	return ""
