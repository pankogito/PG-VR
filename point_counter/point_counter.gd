extends Node3D
class_name PointCounter

@export var nr_of_point: int = 0
@export var nr_of_parcel_deliveries: int = 0
@export var nr_of_lost_packages : int = 0 

@export var cost_of_lost_package: int = -1
@export var cost_of_runaway_house: int = -5
@export var profit_of_parcel_delivery: int = 5


func _package_was_delivered() -> void:
	nr_of_parcel_deliveries += 1
	nr_of_point += profit_of_parcel_delivery
	
func _house_finished_track(house: House) -> void:
	if not house.package_arrived_var:
		nr_of_point += cost_of_runaway_house

func _lost_package() -> void:
	nr_of_lost_packages += 1
	nr_of_point += cost_of_lost_package

func get_points() -> int:
	return nr_of_point

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
