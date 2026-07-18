class_name Scale
extends Area3D

var submited_obj: RigidBody3D

signal submit_mass

var lock: bool

func _ready() -> void:
	var player: Player = %Player
	player.release_obj.connect(_on_place)

func _on_place(obj: RigidBody3D) -> void:
	if submited_obj:
		return
	
	var objs = get_overlapping_bodies()
	if obj not in objs:
		return
	
	submited_obj = obj
	submited_obj.freeze = true
	submited_obj.collision_layer = 1 << 4
	
	submited_obj.global_position = global_position
	
	submit_mass.emit()

func take_obj() -> RigidBody3D:
	if not submited_obj or lock:
		return null
	
	var obj = submited_obj
	submited_obj.freeze = false
	submited_obj = null;
	return obj
