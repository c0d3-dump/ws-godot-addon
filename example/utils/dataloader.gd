extends Node

var token: String = ""
var user_id: String = ""
var lobby_id: String = ""

func load_data() -> void:
	var json_file := FileAccess.open("res://data.json", FileAccess.READ)
	if json_file == null:
		printerr("could not open file")
		save_data()
		return
	
	var data_str := json_file.get_as_text()
	var json := JSON.new()
	if json.parse(data_str) != OK:
		printerr("could not parse json data")
		return
	
	var data: Dictionary = json.data
	token = data["token"]
	user_id = data["user_id"]
	
func save_data() -> void:
	var json_file := FileAccess.open("res://data.json", FileAccess.WRITE)
	if json_file == null:
		printerr("could not find or load data.json")
	
	var data: Dictionary = {}
	data["token"] = token
	data["user_id"] = user_id
	
	json_file.store_string(JSON.stringify(data))

func get_token() -> String:
	return token

func get_user_id() -> String:
	return user_id

func get_lobby_id() -> String:
	return lobby_id

func set_token(value: String) -> void:
	token = value

func set_user_id(value: String) -> void:
	user_id = value

func set_lobby_id(value: String) -> void:
	lobby_id = value
