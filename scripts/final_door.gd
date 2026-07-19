extends Node3D

@export var scales: Array[Scale]

@onready var finish_area: Area3D = $FinishArea

@onready var world_wall: StaticBody3D = $WorldWall
@onready var wall_left: StaticBody3D = $WallLeft
@onready var wall_right: StaticBody3D = $WallRight

@onready var animation_player: AnimationPlayer = $"wall-door-rotate2/AnimationPlayer"

func _ready() -> void:
	for s in scales:
		s.submit_mass.connect(_on_submit_mass)
	
	finish_area.body_entered.connect(_finish)

func _on_submit_mass(_mass: float) -> void:
	var mass: float = 0
	
	for s in scales:
		if not s.submited_obj:
			return
		
		if mass == 0:
			mass = s.submited_obj.mass
		elif mass != s.submited_obj.mass:
			return
	
	if mass == 0:
		return
	
	win()

func win() -> void:
	for s in scales:
		s.lock = true
	
	world_wall.get_node("CollisionShape3D").disabled = true
	
	wall_left.get_node("CollisionShape3D").disabled = false
	wall_right.get_node("CollisionShape3D").disabled = false
	finish_area.get_node("CollisionShape3D").disabled = false
	
	animation_player.play("open")

func _finish(_body: Node3D) -> void:
	var config: RoomConfig = owner
	
	get_tree().change_scene_to_packed(config.next_scene)
