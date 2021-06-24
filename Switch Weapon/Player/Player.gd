extends KinematicBody

var speed = 10
var h_acceleration = 6
var air_acceleration = 1
var normal_acceleration = 6
var gravity = 20
var jump = 10
var full_contact = false


var mouse_sensitivity = 0.03

var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()

onready var head = $Head
onready var ground_check = $GroundCheck

onready var akgun = $Head/Hand/AK47
onready var smggun = $Head/Hand/smg
onready var pistolgun = $Head/Hand/pistol

var gunnumber = 1
var currentgun = pistolgun

enum action {walk,gundown}
var canscroll = true
func _ready():
	pass
	

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP and canscroll:
			getgunwithnumber(gunnumber)
			play_animtion(currentgun , action.gundown , -1)
			canscroll = false
			yield(get_tree().create_timer(1),"timeout")
			canscroll = true
		if event.button_index == BUTTON_WHEEL_DOWN and canscroll :
			getgunwithnumber(gunnumber)
			play_animtion(currentgun , action.gundown , +1)
			canscroll = false
			yield(get_tree().create_timer(1),"timeout")
			canscroll = true
			
func _physics_process(delta):
	
	direction = Vector3()
	if Input.is_action_just_pressed("jump"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	full_contact = ground_check.is_colliding()
	
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
		h_acceleration = air_acceleration
	elif is_on_floor() and full_contact:
		gravity_vec = -get_floor_normal() * gravity
		h_acceleration = normal_acceleration
	else:
		gravity_vec = -get_floor_normal()
		h_acceleration = normal_acceleration
		
	if Input.is_action_just_pressed("jump") and (is_on_floor() or ground_check.is_colliding()):
		gravity_vec = Vector3.UP * jump
	
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
		getgunwithnumber(gunnumber)
		play_animtion(currentgun, action.walk , 0)
	
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z

	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x
		
	direction = direction.normalized()
	h_velocity = h_velocity.linear_interpolate(direction * speed, h_acceleration * delta)
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
		
	move_and_slide(movement, Vector3.UP)

func play_animtion(gun , performingaction , modvalue):
	var gunap = gun.get_node("AnimationPlayer")
	match performingaction:
		action.gundown:
			gunap.play_backwards("gunup")
			yield(get_tree().create_timer(gunap.get_animation("gunup").length) ,"timeout")
			gun.visible = false
			gunnumber += modvalue
			getgunwithnumber(gunnumber)
			currentgun.visible = true
			currentgun.get_node("AnimationPlayer").play("gunup")
			yield(get_tree().create_timer(currentgun.get_node("AnimationPlayer").get_animation("gunup").length),"timeout")
		action.walk:
			gunap.play("walk")

func getgunwithnumber(number):
	match number:
		0:
			currentgun = akgun
			gunnumber = 3
		1:
			currentgun = pistolgun
		2:
			currentgun = smggun
		3:
			currentgun = akgun
		4:
			currentgun = pistolgun
			gunnumber = 1
	return currentgun
	
	
func _process(delta):
	changegunwithnumber()

func changegunwithnumber():
	if Input.is_action_just_pressed("1"):
		if currentgun != pistolgun:
			getgunwithnumber(gunnumber)
			play_animtion(currentgun , action.gundown , 0)
			gunnumber = 1
	if Input.is_action_just_pressed("2"):
		if currentgun != smggun:
			getgunwithnumber(gunnumber)
			play_animtion(currentgun,action.gundown,0)
			gunnumber = 2
	if Input.is_action_just_pressed("3"):
		if currentgun != akgun:
			getgunwithnumber(gunnumber)
			play_animtion(currentgun,action.gundown,0)
			gunnumber = 3
			
