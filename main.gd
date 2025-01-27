extends Node3D

var xr_interface: XRInterface
@export var number_of_houses = 10
@export var generation_interval = 30

@onready var point_counter = $PointCounter
@onready var island_p = $IslandScreen.position
@onready var balance_p = point_counter.position
@onready var result_p = $Result.position

signal reset_game()
var reset = false

func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connected")
	
	_on_point_counter_update()
	game.call_deferred()


func game():
	for i in range(number_of_houses):
		$IslandManager.generate_house()
		$IslandScreen.label.text = "Islands: "+str(i+1)+"/"+str(number_of_houses)
		var loop_tween = create_tween()
		loop_tween.tween_interval(generation_interval)
		await loop_tween.finished or reset_game
		if reset:
			return
	
	await $IslandManager.house_finished_track or reset_game
	if reset:
		return
	

	var game_over_tween = create_tween()
	game_over_tween.set_parallel(true)
	game_over_tween.tween_property($IslandScreen,"position",island_p+Vector3(1,0.5,0),4).set_trans(Tween.TRANS_SINE)
	game_over_tween.tween_property($Balance,"position",balance_p+Vector3(0,0.5,1),4).set_trans(Tween.TRANS_SINE)
	game_over_tween.tween_property($Result,"position",Vector3(-0.6,1.6,-0.6),6).set_trans(Tween.TRANS_SINE)

func _on_manipulator_progress_change(progress: Variant) -> void:
	if progress > 0.9:
		reset = true
		reset_game.emit()
		$IslandManager.reset()
		$PointCounter.reset()
		reset = false
		
		var reset_tween = create_tween()
		reset_tween.set_parallel(true)
		reset_tween.tween_property($IslandScreen,"position",island_p,4).set_trans(Tween.TRANS_SINE)
		reset_tween.tween_property($Balance,"position",balance_p,4).set_trans(Tween.TRANS_SINE)
		reset_tween.tween_property($Result,"position",result_p,6).set_trans(Tween.TRANS_SINE)

		game()


func _on_point_counter_update() -> void:
	if not point_counter:
		return
	var balance_text = "Balance: $"+str(point_counter.nr_of_point)
	$Balance.label.text = balance_text
	
	$Result.label.text = "GAME OVER\n "+\
		balance_text+"\n"+ \
		"Packages lost:" +str(point_counter.nr_of_lost_packages)+"\n"+\
		"Customers lost: " +str(number_of_houses-point_counter.nr_of_parcel_deliveries)+"\n"+\
		"\nTo restart pull lever bellow"
