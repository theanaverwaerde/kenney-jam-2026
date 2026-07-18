extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/test_with_asset_scene.tscn')


func on_credits_pressed() -> void:
	$"Credits Scene".visible = true


func _on_controls_pressed() -> void:
	$"Controls Scene".visible = true


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/menu.tscn')
