extends CharacterBody2D

var fall_speed = 200
var puff_fall_speed = 700
var gravity = 2000

var direction = 0
var last_direction = 1
var speed = 100
var acceleration = 200
var friction = 175
var turn_acceleration = 400

var crouching = false
var puffed = false

var jump_power_initial = 300
var jump_power = 600
var jump_distance = 1800
var jump_time_max = 0.2
var jump_timer = 0

var coyote_time = 0.1
var coyote_timer = 0

enum Act{IDLE, WALK, JUMPING, CROUCH}
var current_act: Act = Act.IDLE

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("B"):
		if puffed:
			puffed = false

func _physics_process(delta: float) -> void:
	update_movement(delta)
	grav_down(delta)
	jump(delta)
	coyote_timing(delta)
	update_animation()
	flip_sprite()
	move_and_slide()
	print(puffed)

func grav_down(delta: float) -> void:
	if puffed:
		velocity.y = move_toward(velocity.y, puff_fall_speed, gravity * delta)
	else:
		velocity.y = move_toward(velocity.y, fall_speed, gravity * delta)
	if !is_on_floor():
		crouching = false

func update_movement(delta: float) -> void:
	direction = Input.get_axis("Left", "Right")
	
	if Input.is_action_pressed("Down"):
		crouching = true
	else:
		crouching = false
	
	if direction:
		last_direction = direction
		
		if direction * velocity.x < 0: #turning around
			velocity.x = move_toward(velocity.x, direction * speed, turn_acceleration * delta)
		elif puffed:
			pass
		else: #walking
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else: #stopping
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func jump(delta: float) -> void:
	if Input.is_action_just_pressed("A"):
		if is_on_floor() or coyote_timer > 0:
			velocity.y = -jump_power_initial
			jump_timer = jump_time_max
	elif Input.is_action_pressed("A") and jump_timer < 0:
		jump_timer -= delta
		velocity.y = move_toward(velocity.y, -jump_distance, jump_power * delta)
	else:
		jump_timer = -1

func coyote_timing(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

func update_animation() -> void:
	pass

func flip_sprite() -> void:
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
