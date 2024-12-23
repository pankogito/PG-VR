extends XRController3D

@export var input_name = "trigger"
@export_range(0.5,1) var trigger_value = 0.5
@export var animation_name = "Scene"
@export_range(0,10) var animation_speed = 4.0

@onready var animation_player = $HandRig/AnimationPlayer

var open = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if tracker == "left_hand":
		$HandRig.scale.y = -1

func _on_input_float_changed(name: String, value: float) -> void:
	if name == input_name:
		if value > trigger_value:
			if open:
				animation_player.play(animation_name,-1,animation_speed)
				open = false
		elif value < 1- trigger_value:
			if not open:
				animation_player.play(animation_name,-1,-animation_speed,true)
				open = true
