extends Node3D

@export var scales: Array[Scale]

@export var wanted_mass: float

func _ready() -> void:
	for s in scales:
		s.submit_mass.connect(_on_submit_mass)

func _on_submit_mass() -> void:
	for s in scales:
		if not s.submited_obj or s.submited_obj.mass != wanted_mass:
			return
	
	win()

func win() -> void:
	print("win")
	
	for s in scales:
		s.lock = true
