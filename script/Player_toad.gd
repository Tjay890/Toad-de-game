extends CharacterBody3D

#@onready var visual : Node3D = $MeshInstance3D
var cd = 0.0
var speed
const WALK_SPEED = 3.0
const SPRINT_SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005

#bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.81
@export var pause_menu : ColorRect
@onready var nek = $Nek
@onready var camera = $Nek/Camera3D
@export var animation : AnimationPlayer
@export var hitbox : Area3D
@export var collisionshape: CollisionShape3D
@export var spawned_knife: PackedScene
@export var spawn_point: RayCast3D

var owner_id = 1

func _enter_tree():
	owner_id = name.to_int()
	print(owner_id)
	set_multiplayer_authority(owner_id)


func _ready():
	if owner_id != multiplayer.get_unique_id():
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true


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

	# Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	#handle sprint
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else :
		speed = WALK_SPEED
	



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
	if event.is_action_pressed("ui_cancel"):
		pause_menu.pause()



func _process(delta):
	if multiplayer.multiplayer_peer == null:
		return
	if owner_id != multiplayer.get_unique_id():
		return
	if Input.is_action_just_pressed("attack") and (Input.is_action_pressed("charge") and cd > 0):
		shoot()
		cd = 0
		animation.play("Idle")
	elif Input.is_action_just_pressed("attack"):
		hitbox.set_collision_layer_value(3, true)
		hitbox.set_collision_mask_value(2, true)
		animation.play("Attack")
		hitbox.monitoring = true
	if Input.is_action_pressed("charge") and cd > 0:
		animation.play("Throw_charge")
	if Input.is_action_just_released("charge"):
		animation.play("Idle")
	cd += delta
	

func _on_animation_player_animation_finished(anim_name):
	if multiplayer.multiplayer_peer == null:
		return
	if owner_id != multiplayer.get_unique_id():
		return
	if anim_name == "Attack":
		animation.play("Idle")
		hitbox.monitoring = false
		hitbox.set_collision_layer_value(3, false)
		hitbox.set_collision_mask_value(2, false)
		


func _on_hitbox_area_entered(area):
	if area.is_in_group("players"):
		hitbox.set_deferred("monitoring", false)
		print("hit")
		area.hit.rpc()
		

func shoot():
	var new_knife = spawned_knife.instantiate()
	new_knife.position = spawn_point.global_position
	new_knife.transform.basis = spawn_point.global_transform.basis
	get_parent().add_child(new_knife, true)
