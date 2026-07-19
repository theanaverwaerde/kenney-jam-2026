class_name Player
extends CharacterBody3D

@export var speed := 5.0
@export var rotation_speed := 12.0

@export var mass := 80
@export var mass_speed_multiplier := .5

@onready var raycast: RayCast3D = $RayCast3D
@onready var shapecast: ShapeCast3D = $ShapeCast3D

@onready var animation_tree: AnimationTree = $AnimationTree

var grabbed_obj: RigidBody3D
var distance_grabbed: float

signal release_obj

func _ready() -> void:
	safe_margin = 0.0001

func _physics_process(delta: float) -> void:
	move(delta)
	
	grab()
	
	anim_handle()

func move(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("left", "right", "up", "down")
	
	var direction := (Vector3.FORWARD * input_dir.y + Vector3.LEFT * input_dir.x).normalized()
	
	var current_speed: float
	if grabbed_obj:
		current_speed = speed * min(1, mass/grabbed_obj.mass*mass_speed_multiplier)
	else:
		current_speed = speed
	
	# print(current_speed)
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		var target_angle := Vector3.FORWARD.signed_angle_to(direction, Vector3.UP)
		
		global_rotation.y = lerp_angle(global_rotation.y, target_angle, rotation_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	_push_away_rigid_bodies()
	move_and_slide()
	
	if grabbed_obj != null:
		var target_grabbed_position = global_position + -basis.z * distance_grabbed
		target_grabbed_position.y = grabbed_obj.global_position.y
		
		grabbed_obj.global_position = target_grabbed_position

# https://gist.github.com/majikayogames/cf013c3091e9a313e322889332eca109
# CC0/public domain/use for whatever you want no need to credit
# Call this function directly before move_and_slide() on your CharacterBody3D script
func _push_away_rigid_bodies():
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			var push_dir = -c.get_normal()
			# How much velocity the object needs to increase to match player velocity in the push direction
			var velocity_diff_in_push_dir = self.velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
			# Only count velocity towards push dir, away from character
			velocity_diff_in_push_dir = max(0., velocity_diff_in_push_dir)
			# Objects with more mass than us should be harder to push. But doesn't really make sense to push faster than we are going
			var mass_ratio = min(1., mass / c.get_collider().mass)
			# Optional add: Don't push object at all if it's 4x heavier or more
			if mass_ratio < 0.25:
				continue
			# Don't push object from above/below
			push_dir.y = 0
			# 5.0 is a magic number, adjust to your needs
			var push_force = mass_ratio * 5.0
			c.get_collider().apply_force(push_dir * velocity_diff_in_push_dir * push_force, c.get_position() - c.get_collider().global_position)

func grab() -> void:
	if not Input.is_action_just_pressed("action"):
		return
		
	if grabbed_obj:
		# Release
		grabbed_obj.collision_layer = 1 << 2 # Object Layer
		grabbed_obj.angular_velocity = Vector3.ZERO
		grabbed_obj.linear_velocity = Vector3.ZERO
		release_obj.emit(grabbed_obj)
		grabbed_obj = null
		return
	
	if not shapecast.is_colliding():
		return
	
	var nodes: Array[RigidBody3D] = []
	for i in range(shapecast.get_collision_count()):
		var obj = shapecast.get_collider(i)
		if obj is Scale:
			# Grab from Scale if have an object
			obj = obj.take_obj()
			if not obj:
				continue
		nodes.append(obj)
	
	if len(nodes) == 0:
		return
	
	nodes.sort_custom(SortDistance)
	
	# Grab Object
	grabbed_obj = nodes[0]
	grabbed_obj.collision_layer = 1 << 3 # Grabbed Layer
	var posA = grabbed_obj.global_position
	var posB = global_position
	posA.y = 0
	posB.y = 0
	distance_grabbed = posA.distance_to(posB)
	
	animation_tree.set("parameters/InteractOS/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func SortDistance(a: RigidBody3D, b: RigidBody3D):
	var posA = a.global_position
	var posB = b.global_position
	var posGlobal = global_position
	posA.y = 0
	posB.y = 0
	posGlobal.y = 0
	return posGlobal.distance_to(posA) > posGlobal.distance_to(posB)

func anim_handle() -> void:
	var state: String
	if velocity:
		state = "walk"
		animation_tree.set("parameters/WalkSpeed/scale", velocity.length() / speed)
	else:
		state = "idle"
	
	var holding: float
	if grabbed_obj:
		holding = 1
	else:
		holding = 0
	
	animation_tree.set("parameters/Holding/blend_amount", holding)
	
	animation_tree.set("parameters/state/transition_request", state)
