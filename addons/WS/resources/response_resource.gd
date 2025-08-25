class_name ResponseResource
extends Resource

var status_code: int
var data: String
var error: String

func _init(_status_code: int, _data: String, _error: String) -> void:
	status_code = _status_code
	data = _data
	error = _error
