class_name Lobby
extends Control

@onready var lobby_name: LineEdit = %LobbyName
@onready var lobbies_container: VBoxContainer = %Lobbies

var lobbies: Array[LobbyResource] = []

func _ready() -> void:
	fetch_lobbies()
	Events.join_lobby.connect(_on_join_lobby.bind())

func _on_refresh_button_pressed() -> void:
	fetch_lobbies()

func fetch_lobbies() -> void:
	for lobby in lobbies_container.get_children():
		lobby.queue_free()
	
	lobbies = WS.get_all_lobbies()
	for lobby in lobbies:
		var lobby_detail: LobbyDetail = Preloads.LOBBY_DETAIL_PREFAB.instantiate()
		lobby_detail.lobby_id = lobby.id
		lobby_detail.lobby_name = lobby.name
		lobbies_container.add_child(lobby_detail)

func _on_join_lobby(lobby_id: String) -> void:
	var status_code := WS.join_lobby(lobby_id)
	if status_code != 200:
		printerr("Failed to join lobby")
		return
	
	Dataloader.set_lobby_id(lobby_id)
	
	queue_free()
	get_parent().transition(Preloads.WORLD_PREFAB)

func _on_create_lobby_button_pressed() -> void:
	var lobby_id := WS.create_lobby(lobby_name.text)
	if lobby_id.is_empty():
		printerr("Failed to create lobby")
		return
	
	Dataloader.set_lobby_id(lobby_id)
	
	queue_free()
	get_parent().transition(Preloads.WORLD_PREFAB)

func _on_back_button_pressed() -> void:
	queue_free()
	get_parent().transition(Preloads.MAIN_MENU_PREFAB)
