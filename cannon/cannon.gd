extends Node3D
class_name Cannon

# limits of barrel movement in yaw 
@export var yaw_min:float
@export var yaw_max:float

# limits of barrel movement in pitch
@export var pitch_min:float
@export var pitch_max:float

@onready var barrel = $Barrel

var initial_velocity:float = 10

@onready var package = $Barrel/Package

@onready var final_marker = $Barrel/FinalMarker
@onready var start_marker = $Barrel/StartMarker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func add_package(p):
	package = p
	barrel.add_child(package)
	package.global_transform = start_marker.global_transform
	package.freeze = true

# fire package. Requeires package != null
func fire():
	# create tween animation
	var tween = create_tween()
	var t = 2*4/initial_velocity
	
	# request package movement to shot positon
	tween.tween_property(package,"global_position",final_marker.global_position,t) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished
	
	# remove package from cannon
	var trans = package.global_transform
	package.get_parent().remove_child(package)
	get_parent().add_child(package)
	package.global_transform = trans
	
	# set physics
	var v:Vector3 = final_marker.global_position - start_marker.global_position
	package.linear_velocity = initial_velocity*v.normalized()
	package.freeze = false
	
	package = null

# set yaw to given ratio between limits
func yaw(ratio):
	barrel.rotation_degrees.y = yaw_min + (yaw_max-yaw_min)*ratio

# set yaw to given ratio between limits
func pitch(ratio):
	barrel.rotation_degrees.x = pitch_min + (pitch_max-pitch_min)*ratio

# if loaded and progress above 90% fire
func _on_fire_progress_change(progress: Variant) -> void:
	if progress > 0.9 and package:
		fire()

# if not loaded and progress above 90% create and load package
func _on_load_progress_change(progress: Variant) -> void:
	if progress > 0.9 and not package:
		var p = preload("res://package/package.tscn").instantiate()
		add_package(p)
