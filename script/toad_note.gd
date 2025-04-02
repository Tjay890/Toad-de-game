extends Node3D

@onready var visual : Node3D = $VisualNode

var rotateSpeed = 1
var PosterValue = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	visual.rotate_y(rotateSpeed * delta)


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		queue_free()
		
		body.AddPoster(PosterValue)
