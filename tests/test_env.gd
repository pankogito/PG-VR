extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print ("Start simulation")
	$Camera3D.current = true
	$IslandManager.generate_house()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
	$IslandManager.generate_house()
