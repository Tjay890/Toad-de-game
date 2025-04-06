extends Area3D

@export var damage:= 1

signal body_part_hit(dam)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@rpc ("call_local","any_peer", "reliable")
func hit():
	if get_parent().name == str(Lobby.peer_id):
		print("player hit")
		emit_signal("body_part_hit", damage)
