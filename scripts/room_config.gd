class_name RoomConfig
extends Node

@export var next_scene: PackedScene
@export var colormap: CompressedTexture2D

@onready var repaints: Node = $Repaint

const COLORMAP = preload("res://textures/colormap.png")

func _ready() -> void:
	var mat = StandardMaterial3D.new()
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	if colormap == null:
		mat.albedo_texture = COLORMAP
	else:
		mat.albedo_texture = colormap
		
	for f in repaints.find_children("*", "MeshInstance3D", true):
		if f is MeshInstance3D and f.name != "(_ignore)":
			f.material_override = mat
