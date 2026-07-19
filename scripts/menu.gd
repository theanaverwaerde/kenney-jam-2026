extends Control

@onready var credits_scene: Control = $"Credits Scene"
@onready var controls_scene: Control = $"Controls Scene"

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/room_1.tscn")

func on_credits_pressed() -> void:
	credits_scene.visible = true

func _on_controls_pressed() -> void:
	controls_scene.visible = true

func _on_back_button_pressed() -> void:
	credits_scene.visible = false
	controls_scene.visible = false
