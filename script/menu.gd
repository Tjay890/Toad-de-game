extends Control

@export var status_label : Label
@export var ip_line_edit : LineEdit


const MAIN = preload("res://main.tscn")

func _on_start_button_pressed():
	get_tree().change_scene_to_packed(MAIN)



func _on_quit_button_pressed():
	get_tree().quit()


func _on_host_button_pressed():
	status_label.text = "Hosting"
	print("test")

func _on_join_button_pressed():
	status_label.text = "Connecting..."
	print("test")
