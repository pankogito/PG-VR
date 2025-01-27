extends Node3D
class_name IslandManager

@export var number_of_paths:int = 5
@export var r1:int = 25
@export var r2:int = 80
@export var minimal_progress_stop = 0.8
@export var angle:float = PI / 2
@export var scene_path:String = "res://house/house_with_area.tscn"

var packed_scene


 # Dictionary to store tweens by instance
var tweens = {}

# Inform about end of track of particul house
signal house_finished_track(house: House)
signal all_houses_left
# Inform if package was delivered to some house
signal delivered_package

func cal_vector(radius, local_angel):
	return Vector3(radius * cos(local_angel), 0, radius * sin(local_angel))

func add_points_to_curve(idx: int, curve: Curve3D) -> void:
	var offset = angle / (number_of_paths - 1)
	var local_angle = offset * idx
	
	curve.add_point(cal_vector(r2, local_angle))
	curve.add_point(cal_vector(r1, local_angle))
		
func add_house(path: Path3D) -> void:
	var path_follow = PathFollow3D.new()
	path_follow.loop = false
	
	
	if packed_scene:
		var instance = packed_scene.instantiate()
		path_follow.add_child(instance)
		# ensures that house will not spawn on players before moving in to position next frame
		# prevents dangeruos flickering related to that
		path.add_child(path_follow)
		path_follow.position = Vector3(0,-100,0)
		# Connect the signal from the instance to a function in IslandManager
		instance.package_arrived.connect(_on_house_signal.bind(path_follow))
		
		var path_length = path.curve.get_baked_length()
		var duration = path_length / instance.speed
		
		
		# Create a Tween to animate the progress_ratio
		var tween = create_tween()
		tween.tween_property(path_follow, "progress_ratio", randf_range(minimal_progress_stop,1.0), duration)
		tween.tween_interval(10.0)
		tween.tween_property(path_follow, "progress_ratio", 0.0, duration/2.0)
		tween.tween_callback(remove_house.bind(instance,path_follow))
		tween.tween_callback(house_finished_track.emit.bind(instance))
		# Store the tween in the dictionary
		tweens[instance] = tween

# Handle the signal from the house and stop the tween
func _on_house_signal(instance,path_follow):
	if instance in tweens:
		var tween = tweens[instance]
		tween.kill()
		tweens.erase(instance)
		
		var new_tween = create_tween()
		new_tween.tween_property(path_follow, "progress_ratio", 0.0,path_follow.progress_ratio * 5)
		new_tween.tween_callback(remove_house.bind(instance,path_follow))
		new_tween.tween_callback(house_finished_track.emit.bind(instance))
		delivered_package.emit()


# Function to add a new house to the track with the least children
func generate_house() -> void:
	var min_children = null
	var tracks_with_min_children = []
	
	# Find the track(s) with the least children
	for path in get_children():
			var child_count = path.get_child_count()
			if min_children == null or child_count < min_children:
				min_children = child_count
				tracks_with_min_children = [path]
			elif child_count == min_children:
				tracks_with_min_children.append(path)
				
	# Randomly select one of the tracks with the least children
	if tracks_with_min_children.size() > 0:
		var selected_track = tracks_with_min_children[randi() % tracks_with_min_children.size()]
		
		# Add a new house to the selected track
		add_house(selected_track)

# Create tracks
func create_tracks() -> void:
	for i in range(number_of_paths):
		var path = Path3D.new()
		path.name = "Track_" + str(i)
		add_child(path)
		
		var curve = Curve3D.new()
		path.curve = curve
		add_points_to_curve(i, path.curve)
		
func remove_house(house,path_follow):
	tweens.erase(house) # do nothing if house is not a key
	path_follow.queue_free()
	
	if tweens.is_empty():
		all_houses_left.emit()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	packed_scene = load(scene_path)
	create_tracks()

func reset():
	for instance in tweens:
		tweens[instance].kill()
		instance.queue_free()
	tweens = {}
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
