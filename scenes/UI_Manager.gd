extends Control

@onready var posterLabel:Label = $HBoxContainer_Poster/Label_Poster

@export var player:Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	player.posterUpdated.connect(UpdatePosterLabel)

func UpdatePosterLabel(newValue:int):
	posterLabel.text = str(newValue)


