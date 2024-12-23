extends Camera3D

@export var speed: float = 5.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		translate(Vector3(0, 0, -speed * delta))
	if Input.is_action_pressed("ui_down"):
		translate(Vector3(0, 0, speed * delta))
	if Input.is_action_pressed("ui_left"):
		translate(Vector3(-speed * delta, 0, 0))
	if Input.is_action_pressed("ui_right"):
		translate(Vector3(speed * delta, 0, 0))
