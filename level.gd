extends Node3D

@export var player_scene: PackedScene
@export var players_container: Node3D
@export var spawn_points: Array[Node3D]
@export var toad_scene: PackedScene

var next_spawn_point_index = 0

func _ready():
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
