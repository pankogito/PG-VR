extends Node

var counter = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print ("Start simulation")
	$Camera3D.current = true
	$IslandManager.generate_house()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	counter += 1
	if counter % 1000:
		counter = 0
		print($PointCounter.get_points())

func _on_island_manager_house_finished_track(house: House) -> void:
	print("House finished track on path: %s" % house.name)
	var timer = Timer.new()
	add_child(timer)
	# Set the timer to a random wait time between 1 and 5 seconds
	timer.wait_time = randf_range(1.0, 5.0)
	timer.one_shot = true
	timer.start()
	# Wait for the timer to timeout
	await timer.timeout
	timer.queue_free()
	$IslandManager.generate_house()
