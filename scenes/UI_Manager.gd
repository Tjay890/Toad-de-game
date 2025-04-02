extends Control

@onready var posterLabel:Label = $HBoxContainer_Poster/Label_Poster

@export var player:Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	if Lobby.toad_id == multiplayer.get_unique_id():
		return
	player.posterUpdated.connect(UpdatePosterLabel)

func UpdatePosterLabel(newValue:int):
	posterLabel.text = str(newValue)


