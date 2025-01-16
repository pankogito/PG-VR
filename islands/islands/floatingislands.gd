extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var max_index = get_child_count() - 1
	var random_index = randi_range(0, max_index)
	
	var index = 0
	for child in get_children():
		child.visible = index == random_index
		index += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
