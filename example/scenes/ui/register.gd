class_name Register
extends Control

@onready var email: LineEdit = %Email
@onready var password: LineEdit = %Password

func _on_register_button_pressed() -> void:
	var status_code: int = WS.register(email.text, password.text)
	if status_code != 200:
		printerr("Enter valid email and password")
		return
	
	queue_free()
	get_parent().transition(Preloads.MAIN_MENU_PREFAB)

func _on_back_button_pressed() -> void:
	queue_free()
	get_parent().transition(Preloads.MAIN_MENU_PREFAB)
