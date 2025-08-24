class_name Lobby
extends Resource

var id: String
var name: String
var created_at: String

func _init(_id: String, _name: String, _created_at: String) -> void:
	id = _id
	name = _name
	created_at = _created_at
