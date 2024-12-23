extends Area3D
class_name House

signal package_arrived 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body is Package:
		body.get_parent().remove_child(body)
		body.disable_shoot()
		add_child(body)
		package_arrived.emit()
