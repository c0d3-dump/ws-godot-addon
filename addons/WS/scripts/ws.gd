extends Node

signal received_data(data: Dictionary)
signal member_joined_ws(id: String)
signal member_left_ws(id: String)

var socket := WebSocketPeer.new()
var tick_rate: int = 0
var last_tick_time: int
var connected: bool = false
var host: String
var port: int
var token: String
var user_id: String
var sync_data: Dictionary

func _ready() -> void:
	set_process(false)

func setup(_host: String, _port: int) -> void:
	host = _host
	port = _port

func register(email: String, password: String) -> int:
	var body := {"email": email, "password": password}
	var response: Response = Http.request(HTTPClient.METHOD_POST, "/auth/register", body)
	
	if response.status_code == 200:
		var data: Dictionary = JSON.parse_string(response.data)
		token = data["token"]
		user_id = data["user_id"]
	else:
		printerr(response.error)
	
	return response.status_code

func login(email: String, password: String) -> int:
	var body := {"email": email, "password": password}
	var response: Response = Http.request(HTTPClient.METHOD_POST, "/auth/login", body)
	
	if response.status_code == 200:
		var data: Dictionary = JSON.parse_string(response.data)
		token = data["token"]
		user_id = data["user_id"]
	else:
		printerr(response.error)
	
	return response.status_code

func create_lobby(lobby_name: String) -> int:
	var body := {"lobby_name": lobby_name}
	var response: Response = Http.request(HTTPClient.METHOD_POST, "/lobby", body)
	
	if response.status_code != 200:
		printerr(response.error)
	
	return response.status_code

func get_all_lobbies() -> Array[Lobby]:
	var response: Response = Http.request(HTTPClient.METHOD_GET, "/lobby/all")
	
	if response.status_code != 200:
		printerr(response.error)
		return []
	
	var data = JSON.parse_string(response.data)
	var lobbies: Array[Lobby] = []
	for lobby in data["lobbies"]:
		lobbies.append(Lobby.new(lobby["id"], lobby["name"], lobby["created_at"]))
	return lobbies

func join_lobby(lobby_id: String) -> int:
	var body := {"lobby_id": lobby_id}
	var response: Response = Http.request(HTTPClient.METHOD_POST, "/lobby/join", body)
	
	if response.status_code != 200:
		printerr(response.error)
	
	return response.status_code

func leave_lobby(lobby_id: String) -> int:
	var body := {"lobby_id": lobby_id}
	var response: Response = Http.request(HTTPClient.METHOD_DELETE, "/lobby/leave", body)
	
	if response.status_code != 200:
		printerr(response.error)
	
	return response.status_code

func get_all_ws_lobby_members(lobby_id: String) -> Array[String]:
	var response: Response = Http.request(HTTPClient.METHOD_GET, "/lobby/ws/members?lobby_id=%s"%[lobby_id])
	
	if response.status_code != 200:
		printerr(response.error)
		return []
	
	var data: Array = JSON.parse_string(response.data)
	var res: Array[String] = []
	for d in data:
		res.append(str(d))
	return res

func connect_to_server(lobby_id: String, rate: int) -> void:
	var err := socket.connect_to_url("ws://%s:%d/ws?token=%s&lobby_id=%s"%[host, port, token, lobby_id])
	socket.heartbeat_interval = 2
	if err != OK:
		print("Unable to connect: ", err)
		set_process(false)
		return
	
	tick_rate = rate
	last_tick_time = Time.get_ticks_msec()
	set_process(true)

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - last_tick_time < tick_rate:
		return
	
	socket.poll()
	match socket.get_ready_state():
		WebSocketPeer.STATE_CLOSED:
			connected = false
			var code := socket.get_close_code()
			print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
			set_process(false)
		WebSocketPeer.STATE_CLOSING:
			pass
		WebSocketPeer.STATE_CONNECTING:
			pass
		WebSocketPeer.STATE_OPEN:
			connected = true
			while socket.get_available_packet_count():
				var data := socket.get_packet().get_string_from_utf8()
				var json_data: Dictionary = JSON.parse_string(data)
				
				if json_data["message"] is Dictionary:
					sync_data[json_data["from"]] = json_data["message"]
				elif json_data["message"] == "member_joined":
					member_joined_ws.emit(json_data["from"])
				elif json_data["message"] == "member_left":
					member_left_ws.emit(json_data["from"])
				else:
					received_data.emit(json_data)

func get_tick_rate() -> int:
	return tick_rate

func has_connected() -> bool:
	return connected

func is_authority(id: String) -> bool:
	return user_id == id

func send_data(data: Dictionary) -> void:
	var d := JSON.stringify(data)
	var err := socket.send_text(d)
	if err != OK:
		print("Unable to send data: ", err)

func get_data(id: String) -> Variant:
	if sync_data == null:
		return null
	
	return sync_data.get(id)

func _exit_tree() -> void:
	connected = false
	socket.close()
