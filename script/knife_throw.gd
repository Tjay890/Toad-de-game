extends Node3D

const SPEED = 40.0

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D

func _ready():
	pass

func _process(delta):
	position += transform.basis * Vector3(0,0,-SPEED)* delta
	if ray.is_colliding():
		mesh.visible =false
		ray.enabled = false
		if ray.get_collider().is_in_group("players"):
			print("ray hit")
			ray.get_collider().hit()
		await get_tree().create_timer(1.0).timeout
		queue_free()

func _on_timer_timeout():
	queue_free()
