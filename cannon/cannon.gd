extends Node3D
class_name Cannon

# limits of barrel movement in yaw 
@export var yaw_min:float
@export var yaw_max:float

# limits of barrel movement in pitch
@export var pitch_min:float
@export var pitch_max:float

@export var barrel:Node3D

var initial_velocity:float = 10

var adding_package = false
var shooting_package = false
var package = null
var tween:Tween = null
@onready var final_marker = %FinalMarker
@onready var start_marker = %StartMarker
@onready var load_marker = %LoadMarker
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func add_package(p):
	adding_package = true
	barrel.add_child(p)
	p.global_transform = load_marker.global_transform
	p.freeze = true
	
	var tween = create_tween()
	tween.tween_property(p,"position",start_marker.position,0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await  tween.finished
	package = p
	adding_package = false
	
# fire package. Requeires package != null
func fire():
	# create tween animation
	shooting_package = true
	var tween = create_tween()
	var t = 2*4/initial_velocity
	package.shot_particles(true)
	# request package movement to shot positon
	tween.tween_property(package,"global_position",final_marker.global_position,t).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	package.shot_particles(false)
	# remove package from cannon
	package.get_parent().remove_child(package)
	get_parent().add_child(package)
	package.global_transform = final_marker.global_transform
	
	# set physics
	var v:Vector3 = final_marker.global_position - start_marker.global_position
	package.linear_velocity = initial_velocity*v.normalized()
	package.freeze = false
	package = null
	shooting_package = false

# set yaw to given ratio between limits
func yaw(ratio):
	barrel.rotation_degrees.y = yaw_min + (yaw_max-yaw_min)*ratio

# set yaw to given ratio between limits
func pitch(ratio):
	barrel.rotation_degrees.z = pitch_min + (pitch_max-pitch_min)*ratio

# if loaded and progress above 90% fire
func _on_fire_progress_change(progress: Variant) -> void:
	if progress > 0.9 and package and not shooting_package:
		fire()

# if not loaded and progress above 90% create and load package
func _on_load_progress_change(progress: Variant) -> void:
	if progress > 0.9 and not (package or adding_package):
		var p = preload("res://package/package.tscn").instantiate()
		add_package(p)
