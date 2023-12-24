extends CharacterBody2D

const FLOOR_NORMAL = Vector2.UP
const SNAP_DIRECTION = Vector2.DOWN
const SNAP_LENGTH = 32.0
const SLOPE_THRESHOLD = deg_to_rad(60)


var loop = 0
var speed : int = 170
var air_speed : int = 120
var jump_speed : int = 400
var gravity : int = 950

var ducking = false

var snapVector = SNAP_DIRECTION * SNAP_LENGTH

var direction = 1 # 1 = right, -1 = left
var duckState = 0 # 0 = Not Ducking, 1 = Ducking, 2 = Ducked, 3 = Getting Up

@onready var ani = $Anim_Player

func get_input(delta):
	velocity.x = 0

	if (Input.is_action_pressed("Left") && (duckState != 1 && duckState != 3)):
		direction = -1
		if duckState == 0: moveGrounded()

	if (Input.is_action_pressed("Right") && (duckState != 1 && duckState != 3)):
		direction = 1
		if duckState == 0: moveGrounded()
	
	if Input.is_action_pressed("Down"):	
		if (is_on_floor() && duckState==0):
			ducking = true
			duckState = 1
	
	if Input.is_action_just_released("Down"):
		ducking = false
		if duckState == 2: duckState = 3

	if Input.is_action_just_pressed("ButtonA"):
		duckState = 0
		snapVector = Vector2()
		if (is_on_floor()):
			velocity.y = -jump_speed
	
	if Input.is_action_just_released("ButtonA"):
			if velocity.y < -200:
				velocity.y += jump_speed * 0.25
	
	#==================GRAVITY===================
	
	velocity.y += gravity * delta

	if snapVector != Vector2():
		move_and_slide()
		floor_snap_length = 4
	else:
		set_velocity(velocity)
		set_up_direction(FLOOR_NORMAL)
		move_and_slide()
		velocity.y = velocity.y

	if (is_on_floor()) and snapVector == Vector2():
		reset_snap()
		
	#========Active Global Player================
	if (duckState == 2 && !ducking):
		duckState = 3

func reset_snap():
	snapVector = SNAP_DIRECTION * SNAP_LENGTH

func moveGrounded():
	
	if (is_on_floor()):
		velocity.x += direction * speed
	else:
		velocity.x += direction * air_speed

func animate_player(type,dir,back=false):
	match type:
		0:
			if dir == 1:
				ani.play("00_Idle_R")
			else:
				ani.play("00_Idle_L")
		1:
			if dir == 1:
				ani.play("01_Walk_R")
			else:
				ani.play("01_Walk_L")
		4:
			if dir == 1:
				ani.play("04_Jump_R")
			else:
				ani.play("04_Jump_L")
		5:
			if dir == 1:
				ani.play("05_Fall_R")
			else:
				ani.play("05_Fall_L")
		7:
			if back:
				if dir == 1:
					ani.play_backwards("07_Ducking_R")
				else:
					ani.play_backwards("07_Ducking_L")
			else:
				if dir == 1:
					ani.play("07_Ducking_R")
				else:
					ani.play("07_Ducking_L")
		8:
			if dir == 1:
				ani.play("08_Duck_R")
			else:
				ani.play("08_Duck_L")
	
	if (type == 7):
		await ani.animation_finished;
		
		#Ducking States
		if duckState == 1: duckState = 2
		if duckState == 3: duckState = 0

func animate_check():
	if is_on_floor():
		if duckState == 0:
			if velocity.x == 0:
				animate_player(0,direction)
			else:
				animate_player(1,direction)
		else:
			match duckState:
				1:
					animate_player(7,direction)
				2:
					animate_player(8,direction)
				3:
					animate_player(7,direction,true)
	else:
		if velocity.y < 0:
			animate_player(4,direction)
		else:
			animate_player(5,direction)

func _physics_process(delta):
	get_input(delta)
	animate_check()
