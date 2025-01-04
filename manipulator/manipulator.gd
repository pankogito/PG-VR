extends Path3D
class_name Manipulator

@export var hand:XRController3D

@export_subgroup("vibration borders")
@export var vibration_start = 0.01
@export var vibration_max = 0.05
@export_subgroup("vibration ratios")
@export var streach_ratio = 0.1
@export var jump_ratio = 0.1
@export_subgroup("reset")
@export var reset_speed = 0.0
@export var reset_progress = 0.0

@onready var handle:Node3D = $Handle
@onready var handle_visualization:Node3D = $Handle/MeshInstance3D
@onready var handle_visualization_position = $Handle/MeshInstance3D.position


var vibration

signal progress_change(progress)

func _ready() -> void:
	_on_curve_changed()
	handle.owner = self
	handle.progress_ratio = reset_progress
	progress_change.emit.call_deferred(reset_progress)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not hand:
		if reset_speed <= 0:
			return
		
		var direction = sign(reset_progress-handle.progress_ratio)
		if direction == 0:
			return
		handle.progress_ratio += direction*reset_speed*delta
		if direction != sign(reset_progress - handle.progress_ratio):
			handle.progress_ratio = reset_progress
		return
	var prevoius_positon = handle.global_position
	
	var offset = curve.get_closest_offset(to_local(hand.global_position))
	handle.progress_ratio = offset / curve.get_baked_length()
	progress_change.emit(handle.progress_ratio)
	vibration = streach_ratio*(handle.global_position - hand.global_position).length()
	
	vibration += jump_ratio*(handle.global_position - prevoius_positon).length()
	
	
	vibration = vibration-vibration_start
	
	vibration = clamp(vibration,0,vibration_max)
	
	handle_visualization.position = handle_visualization_position + vibration*Vector3(randf_range(-1,1),0,randf_range(-1,1))

	hand.trigger_haptic_pulse("haptic",100,min(1,vibration),delta,0)

func set_hand(h:Node3D):
	hand = h
	if not hand:
		handle_visualization.position = Vector3()

func _on_curve_changed() -> void:
	var count:float = 0
	var markers = get_child_count()-1
	for marker in get_children():
		if marker == handle:
			continue
		marker.progress_ratio = count/(markers-1)
		
		count += 1
