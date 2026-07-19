extends WorldEnvironment

@export var speed: float = 4

func _process(delta: float) -> void:
	environment.sky_rotation.y += speed * delta
