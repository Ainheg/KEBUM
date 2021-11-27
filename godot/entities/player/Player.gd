extends KinematicBody

var speed = 500
var sensitivity = 0.15
onready var gimbal = get_node("Gimbal")

func init(x, y, z):
	global_translate(Vector3(x, y, z))
	$Gimbal/Camera.make_current()

func _ready():
	print("Player ready")

func _input(event):
	if event is InputEventMouseMotion:
		var movement = event.relative
		gimbal.rotation.z += -deg2rad(movement.y * sensitivity)
		gimbal.rotation.z = clamp(gimbal.rotation.z, deg2rad(-90), deg2rad(90))
		rotation.y += -deg2rad(movement.x * sensitivity)

func _physics_process(delta):
	var velocity = Vector2.ZERO
	var direction = rotation.y
	print(direction)
	if Input.is_action_pressed("move_forward"):
		velocity.x += 1
	if Input.is_action_pressed("move_backward"):
		velocity.x -= 1
	if Input.is_action_pressed("move_left"):
		velocity.y -= 1
	if Input.is_action_pressed("move_right"):
		velocity.y += 1
	velocity = velocity.normalized().rotated(-rotation.y)
	velocity = Vector3(
		velocity.x * speed * delta,
		0,
		velocity.y * speed * delta
	)
	move_and_slide(velocity)
