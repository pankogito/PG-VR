extends Manipulator




func _process(delta: float) -> void:
	super._process(delta)
	handle_visualization.rotation.y = -2 * PI * handle.progress_ratio
