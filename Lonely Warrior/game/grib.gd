extends CharacterBody2D

enum {
	IDLE,
	ATTACK,
	CHASE,
	DAMAGE,
	DEATH,
	RECOVER
}

var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			#DAMAGE:
				#damage_state()
			#DEATH:
				#death_state()
			#RECOVER:
				#recover_state()

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var direction
@onready var sprite = $AnimatedSprite2D
@onready var animplayer = $AnimationPlayer2
var damage = 25
var healts = 55

func _ready():
	Signals.connect("player_position_update", Callable (self, "_on_player_position_update"))
	Signals.connect("player_attack", Callable (self, "_on_damage_received"))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if state == CHASE:
		chase_state()

	move_and_slide()

func _on_player_position_update (player_pos):
	player = player_pos

func _on_attack_body_entered(body: Node2D) -> void:
	state = ATTACK

func idle_state():
	animplayer.play("idle")
	await get_tree().create_timer(0.35).timeout
	$"attack direction/attack/CollisionShape2D".disabled = false
	state = CHASE

func attack_state():
	animplayer.play("attack")
	await animplayer.animation_finished
	$"attack direction/attack/CollisionShape2D".disabled = true
	state = IDLE
	
func chase_state ():
	direction = (player - self.position).normalized()
	if direction.x < 0:
		sprite.flip_h = true
		$"attack direction".rotation_degrees = 180
	else:
		sprite.flip_h = false
		$"attack direction".rotation_degrees = 0

#func damage_state():
	#animPlayer.play("damage")
	
#func death_state():
	#animPlayer.play("death")

#func recover_state():
	#animPlayer.play("recover")

func _on_hit_box_area_entered(area: Area2D) -> void:
	Signals.emit_signal("enemy_attack", damage)

func _on_damage_received (player_damage):
	healts -= player_damage
	state = DAMAGE
