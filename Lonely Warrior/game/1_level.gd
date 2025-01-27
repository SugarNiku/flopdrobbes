extends Node2D

@onready var light = $light/DirectionalLight2D
@onready var pointlight = $light/PointLight2D
@onready var day_text = $"CanvasLayer/Label day"
@onready var animPlayer = $CanvasLayer/AnimationPlayer


enum {
	MORNING,
	DAY,
	EVEING,
	NIGHT
}

var state = MORNING
var day_count: int

func _ready():
	light.enabled = true
	day_count = 1
	set_day_text()
	set_day_text()
	day_text_fade()

func morning_state():
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.085, 75)
	var tween1 = get_tree().create_tween()
	tween1.tween_property(pointlight, "energy", 0, 20)

func eveing_state():
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.95, 75)
	var tween1 = get_tree().create_tween()
	tween1.tween_property(pointlight, "energy", 1.5, 5)
	
func _on_day_night_timeout() -> void:
	match state:
		MORNING:
			morning_state()
		EVEING:
			eveing_state()
	if state < 3: 
		state += 1
	else:
		state = MORNING 
		day_count += 1
		set_day_text()
		day_text_fade()
		
func day_text_fade ():
	animPlayer.play("day_text_trade_in")
	await get_tree().create_timer(3).timeout
	animPlayer.play("day_text_trade_out")
		
func set_day_text ():
	day_text.text = "DAY: " + str(day_count)
