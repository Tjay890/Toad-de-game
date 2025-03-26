extends RigidBody3D

@export var force: float = 20
@export var speed: float = 1.0
@export var g : Vector3 = Vector3.DOWN * 9
@export var collision : CollisionShape3D
@export var cast : RayCast3D
@onready var t = 0

var velocity : Vector3
var init_xy : int = 0
var init_xz : int = 0

func _ready():
	rotate_x(init_xy)
	rotate_y(init_xz)
	velocity -= transform.basis.y * force

func _process(delta):
	#if t > 100:
		#queue_free()
	t += delta

func _physics_process(delta):
	if !cast.is_colliding():
		velocity += g * delta * speed
		look_at(transform.origin + velocity.normalized(), Vector3.UP)
		move_and_collide(velocity*delta*speed)
		
	else:
		collision.disabled = true
func drop():
	pass
