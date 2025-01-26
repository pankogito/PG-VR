extends Area3D
class_name Cleaner

signal found_package

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Function to handle the body_entered signal
func _on_body_entered(body: Node3D) -> void:
	if body is Package:
		body.queue_free()
		found_package.emit()
	
