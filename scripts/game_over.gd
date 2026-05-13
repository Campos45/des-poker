extends Control

func _on_restart_button_pressed():
	# Volta a carregar o jogo do zero
	get_tree().change_scene_to_file("res://scenes/main.tscn")