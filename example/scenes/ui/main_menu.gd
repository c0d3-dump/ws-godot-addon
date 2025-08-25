class_name MainMenu
extends Control

func _on_register_button_pressed() -> void:
	queue_free()
	get_parent().transition(Preloads.REGISTER_PREFAB)

func _on_login_button_pressed() -> void:
	queue_free()
	get_parent().transition(Preloads.LOGIN_PREFAB)

func _on_custom_game_button_pressed() -> void:
	queue_free()
	get_parent().transition(Preloads.LOBBY_PREFAB)
