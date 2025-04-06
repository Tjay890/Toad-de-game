extends CharacterBody3D

#@onready var visual : Node3D = $MeshInstance3D

var speed = 0
var sprint_drain_amount = 0.7
var sprint_refresh_amount = 0.1
const WALK_SPEED = 3.0
const SPRINT_SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005
var health = 2
#bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.81

enum{IDLE,RUN}
var curanim = IDLE

@onready var nek = $Nek
@onready var camera = $Nek/Camera3D
@onready var pause_menu = $pause_menu
@onready var playerbody = $Playerbody
@onready var anim_tree = $Playerbody/AnimationTree
@onready var sprint_slider = $UI/sprint_slider
@onready var pick_up = $Pick_up
@export var coins : Control
@export var hartje1 : TextureRect
@export var hartje2 : TextureRect
@export var health_ui : Control
@export var player : CharacterBody3D

@export var blend_speed = 15

var owner_id = 1
var run_val = 0

var Poster: int:
	set(new_value):
		Poster = new_value
		emit_signal("posterUpdated",Poster)

signal posterUpdated(newValue)

func _enter_tree():
	owner_id = name.to_int()
	set_multiplayer_authority(owner_id)
	





func _ready():
	if owner_id != multiplayer.get_unique_id():
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	playerbody.hide()
	coins.show()
	health_ui.show()
	
	#sprint_slider = get_node("/root/" + get_tree().current_scene.name + "/UI/sprint_slider")
	
	camera.current = true
	SignalManager.coin_collected.connect(AddPoster)


func _unhandled_input(event):
	if multiplayer.multiplayer_peer == null:
		return
	if owner_id != multiplayer.get_unique_id():
		return
	if event is InputEventMouseMotion:
		nek.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta):
	if multiplayer.multiplayer_peer == null:
		return
	if owner_id != multiplayer.get_unique_id():
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	#handle_animations(delta)
	#curanim = RUN

	# Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
		
		
		#handle sprint
	if Input.is_action_pressed("sprint"):
		sprint_slider.visible = true
		speed = SPRINT_SPEED
	else :
		speed = WALK_SPEED
	

func _process(delta):
	if speed == SPRINT_SPEED:
		sprint_slider.value = sprint_slider.value - sprint_drain_amount * delta
		if sprint_slider.value == sprint_slider.min_value:
			speed = WALK_SPEED
	if speed != SPRINT_SPEED:
		if sprint_slider.value < sprint_slider.max_value:
			sprint_slider.value = sprint_slider.value + sprint_refresh_amount * delta
		if sprint_slider.value == sprint_slider.max_value:
			sprint_slider.visible = false






	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (nek.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	#head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	move_and_slide()



func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos 

func _input(event: InputEvent) -> void: 
	if multiplayer.multiplayer_peer == null:
		return
	if owner_id != multiplayer.get_unique_id():
		return
	if health <= 0:
		return
	if event.is_action_pressed("ui_cancel"):
		pause_menu.pause()


#func handle_animations(delta):
	#match curanim:
		#IDLE:
			#run_val = lerpf(run_val,0,blend_speed*delta)
		#RUN:
			#run_val = lerpf(run_val,1,blend_speed*delta)

#func update_tree():
	#anim_tree["parameters/run/blend_amount"] = run_val


func healthdepleted():
	health -= 1
	if health == 1:
		hartje2.hide()
	if health <= 0:
		death()

func death():
	hartje1.hide()
	player.hide()
	print("test voor player dead rpc")
	player_died.rpc_id(1)
	
	if multiplayer.get_unique_id() == owner_id:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		SignalManager.spectator.emit(owner_id)


@rpc ("call_local","any_peer", "reliable")
func player_died():
	print("Player dead signal")
	SignalManager.player_dead.emit()

@rpc ("call_local","any_peer", "reliable")
func remove_player():
	queue_free()

func _on_area_3d_body_part_hit(dam):
	print("signal werkt")
	healthdepleted()


func AddPoster(value:int):
	Poster += value
	print(Poster)
	pick_up.play()
