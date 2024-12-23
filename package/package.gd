extends RigidBody3D
class_name Package

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.linear_velocity = Vector3(5, 5, 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func disable_shoot():
	gravity_scale = 0.0
	linear_velocity = Vector3(0,0,0)
