extends Node3D

@onready var label: Label3D = %Label

func _on_submit_mass(mass: float) -> void:
	if mass == 0:
		label.text = "- -"
		return
	
	var mass_str = str(int(mass))
	label.text = " ".join(mass_str.split())
