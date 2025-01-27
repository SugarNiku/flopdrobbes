extends CharacterBody2D

enum {
	IDLE,
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	SLIDE,
	DAMAGE,
	CAST,
	DEATH,
	COMBO1,
	COMBO2
	}

const SPEED = 250.0
const JUMP_VELOCITY = -400

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimationPlayer
@onready var animPlayer = $AnimatedSprite2D

var healts = 125
var coin = 0
var state = MOVE
var run_speed = 1
var combo = false
var attack_cooldown = false
var player_pos
var damage_basic = 10
var damage_multiplier = 1
var damage_current 

func _ready():
	Signals.connect("enemy_attack", Callable (self, "_on_damage_received"))

func _physics_process(delta):
	damage_basic = damage_basic * damage_multiplier
	match  state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		ATTACK2:
			attack2_state()
		ATTACK3:
			attack3_state()
		BLOCK:
			block_state()
		SLIDE:
			slide_state()
		DAMAGE: 
			damage_state()
		DEATH:
			death_state()
		COMBO1:
			combo1_state()
		COMBO2:
			combo2_state()
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()
	
	player_pos = self.position
	Signals.emit_signal("player_position_update", player_pos)
	
func move_state ():
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED * run_speed
		if velocity.y == 0:
			if run_speed == 1:
				animPlayer.play("walk")
			else:
				animPlayer.play ("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animPlayer.play("idle")
	if direction == -1:
		animPlayer.flip_h = true 
	
	elif direction == 1: 
		animPlayer.flip_h = false
	if Input.is_action_pressed("run"):
		run_speed = 2
	else:
		run_speed = 1
		
	if Input.is_action_pressed("block"):
		if velocity.x == 0:
			state = BLOCK
		else:
			state = SLIDE
			
	if Input.is_action_just_pressed("attack") and attack_cooldown == false:
		state = ATTACK

func block_state ():
	velocity.x = 0
	animPlayer.play("block")
	if Input.is_action_just_released("block"):
		state = MOVE
		
func slide_state():
	anim.play("slide")
	await anim.animation_finished 
	state = MOVE
	
func attack_state():
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK2
	velocity.x = 0
	anim.play("attack")
	await anim.animation_finished
	attack_freeze()
	state = MOVE
	
func attack2_state():
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK3
	anim.play("attack2")
	await anim.animation_finished
	state = MOVE

func attack3_state():
	damage_multiplier = 1
	anim.play("attack3")
	await anim.animation_finished
	state = MOVE

func combo1():
	combo = true
	await animPlayer.animation_finished
	combo = false	

func combo1_state ():
	damage_multiplier = 1.25
	if Input.is_action_just_pressed("attack") and combo == true:
		state = COMBO2
		anim.play("attack2")
		await anim.animation_finished
		state = MOVE

func combo2 ():
	combo = true
	await anim.animation_finished
	combo = false

func combo2_state ():
	damage_multiplier = 2
	if $AnimatedSprite2D.flip_h == true:
		velocity.x = -30
	else:
		velocity.x = 30
	anim.play("attack3")
	await anim.play.animation_finished

func attack_freeze ():
	attack_cooldown = true
	await get_tree().create_timer(0.65).timeout
	attack_cooldown = false

func death_state ():
	velocity.x = 0
	anim.play("death")
	await anim.animation_finished
	queue_free()
	get_tree().change_scene_to_file.bind("res://menu.tscn").call_deferred()

func damage_state ():
	velocity.x = 0
	animPlayer.play("damage")
	await  animPlayer.animation_finished
	state = MOVE

func _on_damage_received (enemy_damage):
	if state == BLOCK:
		enemy_damage /= 2
	elif state == SLIDE:
		enemy_damage = 0
	else:
		state = DAMAGE
	healts -= enemy_damage
	if healts <= 0:
		healts = 0
		state = DEATH 
	else:
		state = DAMAGE
	print(healts)

func _on_hit_box_area_entered(area: Area2D) -> void:
	Signals.emit_signal("player_attack", damage_current)
