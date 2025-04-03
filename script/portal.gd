extends Node3D

var posterRequired : int = 3
@onready var textLabel : Label = $Sprite3D/SubViewport/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	textLabel.text = str(posterRequired)



func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		if body.Poster >= posterRequired:
			print("Big Black Monkey")
		else:
			print("niet genoeg poster man aap")
