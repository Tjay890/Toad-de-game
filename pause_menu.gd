extends ColorRect

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var play_button : Button = find_child("ResumeButton")
@onready var quit_button : Button = find_child("QuitButton")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_button.pressed.connect(unpause)
	quit_button.pressed.connect(get_tree().quit)
	self.visible = false

func unpause():
	animator.play("unpause")
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.visible = false
	
func pause():
	animator.play("pause")
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	self.visible = true
