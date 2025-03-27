extends Node3D

const SPEED = 5.0

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D

func _ready():
	pass

func _process(delta):
	position += transform.basis * Vector3(0,0,-SPEED)* delta
	if ray.is_colliding():
		mesh.visible =false
		ray.enabled = false
		print("collission")
		if ray.get_collider().is_in_group("players"):
			print("ray hit")
			ray.get_collider().hit.rpc()
		await get_tree().create_timer(1.0).timeout
		queue_free()

func _on_timer_timeout():
	queue_free()
