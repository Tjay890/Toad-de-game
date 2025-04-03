extends Node3D

@export var player_scene: PackedScene
@export var players_container: Node3D
@export var spawn_points: Array[Node3D]
@export var toad_scene: PackedScene
@export var spectator_ui: Control
@export var toad_winner: TextureRect
@export var player_lose: TextureRect
@export var death_screen: Control
@export var next_button: Button
@export var quit_toad: Button
@export var quit_player: Button
var player_id = 1
var players = []
var spectator_index = 0
var next_spawn_point_index = 0
@onready var camera = $Players/Dood_camera
var player_count = 0
func _ready():
	SignalManager.spectator.connect(_on_spectator)
	SignalManager.player_dead.connect(toad_win)
	quit_toad.pressed.connect(get_tree().quit)
	quit_player.pressed.connect(get_tree().quit)
	print(Lobby.player_list)
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_disconnected.connect(delete_player)
	
	for id in multiplayer.get_peers():
		if id == Lobby.toad_id :
			add_toad(id)
		else:
			add_player(id)
	if Lobby.toad_id == 1:
		add_toad(1)
	else:
		add_player(1)
	player_count = players_container.get_child_count()
	print("player count:", player_count)

func _exit_tree():
	if not multiplayer.is_server():
		return
		
	multiplayer.peer_disconnected.disconnect(delete_player)

func add_player(id):
	var player_instance = player_scene.instantiate()
	player_instance.position = get_spawn_point()
	player_instance.name = str(id)
	players_container.add_child(player_instance)

func add_toad(id):
	var toad_instance = toad_scene.instantiate()
	toad_instance.position = get_spawn_point()
	toad_instance.name = str(id)
	players_container.add_child(toad_instance)
	print(toad_instance.position)


func delete_player(id):
	if not players_container.has_node(str(id)):
		return
	SignalManager.player_dead.emit()
	players_container.get_node(str(id)).queue_free()

func get_spawn_point():
	var spawn_point = spawn_points[next_spawn_point_index].position
	next_spawn_point_index += 1
	if next_spawn_point_index >= len(spawn_points):
		next_spawn_point_index = 0
	return spawn_point


func _on_player_spawner_spawned(node):
	node.position = get_spawn_point()


func _on_toad_spawner_spawned(node):
	node.position = get_spawn_point()

func _on_spectator(id):
	players = players_container.get_children()
	player_id = id
	spectator_ui.show()
	death_screen.show()


func _on_button_pressed():
	players = players_container.get_children()
	if spectator_index >= len(players):
		spectator_index = 0
		camera = $Players/Dood_camera
		camera.current = true
	else:
		camera = players[spectator_index].get_node("Nek/Camera3D")
		camera.current = true
		spectator_index += 1
	


func toad_win():
	if not multiplayer.is_server():
		return
	player_count -= 1
	print(player_count)
	if player_count <= 1:
		end_game.rpc()
	

@rpc("authority", "call_local", "reliable")
func end_game():
	spectator_ui.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Lobby.player_list[0] == Lobby.toad_id:
		print("toad_win")
		toad_winner.show()
	else:
		print("Player lost")
		player_lose.show()

func _on_quit_button_pressed():
	death_screen.hide()
	remove_player.rpc_id(1, player_id)
	next_button.show()

@rpc ("call_local","any_peer", "reliable")
func remove_player(id):
	players_container.get_node(str(id)).queue_free()

