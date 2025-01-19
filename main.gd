extends Node3D

var xr_interface: XRInterface
@export var number_of_houses = 10
@export var generation_interval = 30
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
		
	for i in range(number_of_houses):
		$IslandManager.generate_house()
		var t = create_tween()
		t.tween_interval(generation_interval)
		await t.finished
