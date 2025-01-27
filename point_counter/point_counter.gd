extends Node3D
class_name PointCounter

@export var nr_of_point: int = 0
@export var nr_of_parcel_deliveries: int = 0
@export var nr_of_lost_packages : int = 0 

@export var cost_of_lost_package: int = -1
@export var cost_of_runaway_house: int = -5
@export var profit_of_parcel_delivery: int = 5

signal update

func _package_was_delivered() -> void:
	nr_of_parcel_deliveries += 1
	nr_of_point += profit_of_parcel_delivery
	update.emit()
	
func _house_finished_track(house: House) -> void:
	if not house.package_arrived_var:
		nr_of_point += cost_of_runaway_house
		update.emit()

func _lost_package() -> void:
	nr_of_lost_packages += 1
	nr_of_point += cost_of_lost_package
	update.emit()

func get_points() -> int:
	return nr_of_point

func reset():
	nr_of_point= 0
	nr_of_parcel_deliveries = 0
	nr_of_lost_packages = 0 
	update.emit()
