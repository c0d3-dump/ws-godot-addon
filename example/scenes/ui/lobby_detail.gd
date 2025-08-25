class_name LobbyDetail
extends Control

@onready var name_label: Label = %NameLabel

var lobby_id: String = ""
var lobby_name: String = ""

func _ready() -> void:
	name_label.text = lobby_name

func _on_join_button_pressed() -> void:
	Events.join_lobby.emit(lobby_id)
