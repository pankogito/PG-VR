extends Node3D
class_name IslandManager

@export var number_of_paths:int = 5
@export var scene_path:String = "res://house/house_with_area.tscn"
@export var position_of_tracks0:Vector3 = Vector3(-50, 0, 0)
@export var position_of_tracks1:Vector3 = Vector3(50, 0, 0)

var packed_scene

# Inform about end of track of particul house
signal house_finished_track(house: House)

func add_points_to_curve(idx: int, curve: Curve3D) -> void:
	if idx % 2:
		curve.add_point(position_of_tracks0)
		curve.add_point(position_of_tracks1)
	else:
		curve.add_point(position_of_tracks1)
		curve.add_point(position_of_tracks0)

func add_house(path: Path3D) -> void:
	var path_follow = PathFollow3D.new()
	path_follow.loop = false
	path.add_child(path_follow)
	
	if packed_scene:
		var instance = packed_scene.instantiate()
		path_follow.add_child(instance)

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
		path.position = Vector3(0, 0, i * 10)
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
	for path in get_children():
		for path_follower in path.get_children():
			path_follower.progress_ratio += path_follower.get_child(0).speed * delta
			# Check if the house has reached the end of the path
			if path_follower.progress_ratio >= 1.0:
				path_follower.queue_free()
				house_finished_track.emit(path_follower.get_child(0))
