extends CharacterBody3D

@export var max_speed := 80
@export var acceleration := 0.6
@export var ship_handling := 10
@export var view_model : Node3D

var rotate_value := Vector3.ZERO

var forward_speed := 0.0
var sideway_speed := 0.0
var is_in_touchzone := false


func _input(event:InputEvent):
	rotate_value = Vector3.ZERO
	
	#set panning (look around) touch area for touchscreen 
	if event is InputEventScreenTouch:
		is_in_touchzone = event.position.x >= (DisplayServer.screen_get_size().x / 2)
		
	#set pan input by either mouse motion or touchscreen
	if (event is InputEventMouseMotion and (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED)) or \
			((event is InputEventScreenDrag) and is_in_touchzone):
			rotate_value.x = deg_to_rad(event.relative.y * -1)
			rotate_value.z = deg_to_rad(event.relative.x * -1)
	
	if Input.is_action_just_pressed("toggle_mouse") and Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		



func _physics_process(delta: float) -> void:
	get_input(delta)
	ship_rotate(delta)
	velocity = (-transform.basis.z * forward_speed)+(-transform.basis.x *sideway_speed)
	move_and_collide(velocity * delta)



func get_input(delta):
	if Input.is_action_pressed("throttle_up"):
		forward_speed = lerpf(forward_speed, max_speed, acceleration * delta)
	elif Input.is_action_pressed("throttle_down"):
		forward_speed = lerpf(forward_speed, -max_speed, acceleration * delta)
	else:
		forward_speed = lerpf(forward_speed, 0, acceleration * delta)
		
		
	if Input.is_action_pressed("yaw_left"):
		sideway_speed = lerpf(sideway_speed, max_speed, acceleration * delta)
	elif Input.is_action_pressed("yaw_right"):
		sideway_speed = lerpf(sideway_speed, -max_speed, acceleration * delta)
	else:
		sideway_speed = lerpf(sideway_speed, 0, acceleration * delta)


func ship_rotate(delta):
	#rotate ship
	if rotate_value:
		transform.basis = transform.basis.rotated(transform.basis.z, rotate_value.z * ship_handling * .50 * delta) #roll
		transform.basis = transform.basis.rotated(transform.basis.x, rotate_value.x * ship_handling * delta) #pitch
		transform.basis = transform.basis.rotated(transform.basis.y, rotate_value.z * ship_handling * delta) #yaw
		transform.basis = transform.basis.orthonormalized()
		
	pass
	
#TODO add a function to rotate viewmodel
