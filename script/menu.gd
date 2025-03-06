extends Control

@export var start_vbox: VBoxContainer
@export var status_label : Label
@export var ip_line_edit : LineEdit
@export var start_button : Button
@export var host_button: Button
@export var join_button: Button
@export var host_vbox: VBoxContainer
@export var connected_players: Label

const MAIN = preload("res://main.tscn")

func _ready():
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
func _on_start_button_pressed():
	get_tree().change_scene_to_packed(MAIN)



func _on_quit_button_pressed():
	get_tree().quit()


func _on_host_button_pressed():
	status_label.text = "Hosting!"
	Lobby.create_game()
	start_vbox.hide()
	host_vbox.show()

func _on_join_button_pressed():
	status_label.text = "Connecting..."
	Lobby.join_game(ip_line_edit.text)
	start_vbox.hide()

func _on_connection_failed():
	status_label.text = "Failed to connect"
	start_vbox.show()

func _on_connected_to_server():
	status_label.text = "Connected!"
