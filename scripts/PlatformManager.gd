extends Node
class_name PlatformManager

# Manages platform generation and collision detection

const PLATFORM_HEIGHT: float = 3.0
const PLATFORM_WIDTH: float = 10.0
const WORLD_HEIGHT: float = 30.0

var platforms: Array = []
var platform_container: Node3D

class PlatformData:
	var start_x: float
	var end_x: float
	var is_top: bool
	var mesh_instance: MeshInstance3D
	
	func _init(sx: float, ex: float, top: bool):
		start_x = sx
		end_x = ex
		is_top = top

func _ready() -> void:
	platform_container = Node3D.new()
	platform_container.name = "PlatformContainer"
	add_child(platform_container)

func create_platform(start_x: float, end_x: float, is_top: bool) -> void:
	"""Create a new platform"""
	# Check for duplicate platforms
	for existing in platforms:
		if existing.is_top == is_top:
			if abs(existing.start_x - start_x) < 1.0 and abs(existing.end_x - end_x) < 1.0:
				return
	
	var plat_data = PlatformData.new(start_x, end_x, is_top)
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	var length = end_x - start_x
	box_mesh.size = Vector3(length, PLATFORM_HEIGHT, PLATFORM_WIDTH)
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	if is_top:
		material.albedo_color = Color(0.5, 0.35, 0.25)
		material.metallic = 0.2
		material.roughness = 0.8
	else:
		material.albedo_color = Color(0.35, 0.25, 0.15)
		material.metallic = 0.2
		material.roughness = 0.9
	
	mesh_instance.material_override = material
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	
	var center_x = (start_x + end_x) / 2.0
	var y_pos = PLATFORM_HEIGHT / 2.0 if not is_top else WORLD_HEIGHT - PLATFORM_HEIGHT / 2.0
	mesh_instance.position = Vector3(center_x, y_pos, 0)
	
	platform_container.add_child(mesh_instance)
	plat_data.mesh_instance = mesh_instance
	platforms.append(plat_data)

func has_platform_coverage(start_x: float, end_x: float, is_top: bool) -> bool:
	"""Check if area is covered by platforms"""
	for plat in platforms:
		if plat.is_top == is_top:
			if plat.start_x <= start_x and plat.end_x >= end_x:
				return true
			if (plat.start_x <= end_x and plat.end_x >= start_x):
				return true
	return false

func check_collision(player_x: float, on_top_platform: bool) -> bool:
	"""Check if player is on a valid platform"""
	for plat in platforms:
		if plat.is_top == on_top_platform:
			if player_x >= plat.start_x - 2 and player_x <= plat.end_x + 2:
				return true
	return false

func clear_all() -> void:
	"""Remove all platforms"""
	for plat in platforms:
		if plat.mesh_instance and is_instance_valid(plat.mesh_instance):
			plat.mesh_instance.queue_free()
	platforms.clear()
