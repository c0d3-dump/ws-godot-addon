class_name World
extends Node

@onready var player_spawner_node = %PlayerSpawnerNode

func _ready() -> void:
	player_spawner_node.lobby_id = Dataloader.get_lobby_id()
	WS.connect_to_server(Dataloader.get_lobby_id(), 100)
