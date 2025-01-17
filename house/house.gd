extends Area3D
class_name House

@export var package_arrived_var: bool = false
@export var speed: float

signal package_arrived

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = randf_range(0.05, 0.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body is Package:
		var visualization = body.pop_visualization()
		add_child(visualization)
		visualization.global_transform = body.global_transform
		body.queue_free()
		package_arrived.emit()
		package_arrived_var = true
