extends Node3D

@export var scales: Array[Scale]
@export var wanted_mass: float

@onready var finish_area: Area3D = $FinishArea

@onready var world_wall: StaticBody3D = $WorldWall
@onready var wall_left: StaticBody3D = $WallLeft
@onready var wall_right: StaticBody3D = $WallRight

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	for s in scales:
		s.submit_mass.connect(_on_submit_mass)
	
	finish_area.body_entered.connect(_finish)

func _on_submit_mass() -> void:
	for s in scales:
		if not s.submited_obj or s.submited_obj.mass != wanted_mass:
			return
	
	win()

func win() -> void:
	for s in scales:
		s.lock = true
	
	world_wall.get_node("CollisionShape3D").disabled = true
	
	wall_left.get_node("CollisionShape3D").disabled = false
	wall_right.get_node("CollisionShape3D").disabled = false
	finish_area.get_node("CollisionShape3D").disabled = false
	
	animation_player.play("door-opening")

func _finish(_body: Node3D) -> void:
	get_tree().reload_current_scene()
