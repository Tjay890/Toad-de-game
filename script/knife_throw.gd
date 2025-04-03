extends Node3D

const SPEED = 5.0

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
var dropped = false
func _ready():
	print(multiplayer.is_server())

func _process(delta):
	if dropped == true:
		if ray.is_colliding():
			if ray.get_collider().is_in_group("toad"):
				print("collected")
				ray.get_collider().picked_up()
				remove.rpc_id(1)
				
		return
	position += transform.basis * Vector3(0,0,-SPEED)* delta
	if ray.is_colliding() and not(ray.get_collider().is_in_group("toad")):
		dropped = true
		print("collission")
		if ray.get_collider().is_in_group("players"):
			print("ray hit")
			ray.get_collider().hit.rpc()
		await get_tree().create_timer(0.3).timeout
		drop()
		position -= transform.basis * Vector3(0,0,-0.3)
		
		


func _on_timer_timeout():
	if dropped != true:
		dropped = true
		drop()

func drop():
	print("drop")
	position.y = 0.1
	rotation.x = 0

@rpc ("call_local", "any_peer", "reliable")
func remove():
	if not multiplayer.is_server():
		return
	print("quefree")
	queue_free()
