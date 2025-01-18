extends Node3D
class_name IslandManager

@export var number_of_paths:int = 5
@export var r1:int = 25
@export var r2:int = 80
@export var angle:float = PI / 2
@export var scene_path:String = "res://house/house_with_area.tscn"

var packed_scene

 # Dictionary to store tweens by instance
var tweens = {}

# Inform about end of track of particul house
signal house_finished_track(house: House)

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
	path.add_child(path_follow)
	
	if packed_scene:
		var instance = packed_scene.instantiate()
		path_follow.add_child(instance)
		# Connect the signal from the instance to a function in IslandManager
		instance.package_arrived.connect(_on_house_signal.bind(path_follow))
		
		var path_length = abs(r1 - r2)
		var duration = path_length / instance.speed
		
		
		# Create a Tween to animate the progress_ratio
		var tween = create_tween()
		tween.tween_property(path_follow, "progress_ratio", 1.0, duration)
		tween.tween_interval(10.0)
		tween.tween_property(path_follow, "progress_ratio", 0.0, duration)
		tween.tween_callback(path_follow.queue_free)
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
		tween.tween_callback(path_follow.queue_free)
		new_tween.tween_callback(house_finished_track.emit.bind(instance))

# Function to add a new house to the track with the least children
func generate_house() -> void:
	var min_children = null
	var tracks_with_min_children = []
	
	# Find the track(s) with the least children
	for i in range(number_of_paths):
		var path = get_node("Track_" + str(i))
		if path:
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
		
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	packed_scene = load(scene_path)
	create_tracks()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
