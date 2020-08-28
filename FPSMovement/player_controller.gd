extends KinematicBody



onready var head = $Head
onready var camera = $Head/Camera


var GRAVITY = 9.8

var acceleration = 5
var max_speed = 10

var look_sensitivity = 0.1

var movement_direction = Vector3()
var velocity = Vector3()


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _input(event:InputEvent):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * look_sensitivity))
		head.rotate_x(deg2rad(event.relative.y * look_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))


func _process(delta):
	
	var movement_direction = Vector3()
	
	if Input.is_action_pressed("move_forward"):
		movement_direction += transform.basis.z
	
	if Input.is_action_pressed("move_backward"):
		movement_direction -= transform.basis.z
	
	if Input.is_action_pressed("move_left"):
		movement_direction += transform.basis.x
		
	if Input.is_action_pressed("move_right"):
		movement_direction -= transform.basis.x
	
	
	movement_direction = movement_direction.normalized()
	velocity = movement_direction * max_speed
	velocity.linear_interpolate(velocity, acceleration * delta)
	
	move_and_slide(velocity, Vector3.UP)
	
	
	
	

