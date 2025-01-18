extends XRController3D
class_name Hand
@export var input_name = "trigger"
@export_range(0.5,1) var trigger_value = 0.5
@export var animation_name = "Scene"
@export_range(0,10) var animation_speed = 4.0

@onready var animation_player = $HandRig/AnimationPlayer
@onready var grab_area = $HandRig/GrabArea
@onready var rotation_test:Node3D = $HandRig/GrabArea/RotationTest
@onready var handle_position:Node3D = $HandRig/GrabArea/HandlePosition

var open = true
var manipulator:Manipulator = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if tracker == "left_hand":
		$HandRig.scale.y = -1

func _on_input_float_changed(name: String, value: float) -> void:
	if name == input_name:
		if value > trigger_value:
			if open:
				animation_player.play(animation_name,-1,animation_speed)
				for colider in grab_area.get_overlapping_areas():
					if colider.owner is Manipulator and colider.owner.hand == null:
						manipulator = colider.owner
						manipulator.hand = self
				open = false
		elif value < 1- trigger_value:
			if not open:
				animation_player.play(animation_name,-1,-animation_speed,true)
				if manipulator:
					manipulator.set_hand(null)
					manipulator = null
				open = true

func _process(delta: float) -> void:
	#$Label3D.text = "%6.3f" % (1/delta) 
	pass
