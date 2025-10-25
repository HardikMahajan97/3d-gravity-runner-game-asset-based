extends Node
class_name ObstacleManager

# Manages obstacle generation and collision detection

const PLATFORM_HEIGHT: float = 3.0
const WORLD_HEIGHT: float = 30.0

var obstacles: Array = []
var obstacle_container: Node3D

class ObstacleData:
	var x: float
	var y: float
	var is_top: bool
	var mesh_instance: MeshInstance3D
	
	func _init(ox: float, oy: float, top: bool):
		x = ox
		y = oy
		is_top = top

func _ready() -> void:
	obstacle_container = Node3D.new()
	obstacle_container.name = "ObstacleContainer"
	add_child(obstacle_container)

func create_obstacle(x: float, is_top: bool) -> void:
	"""Create a new obstacle"""
	var obs_data = ObstacleData.new(x, 0, is_top)
	
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.75
	sphere_mesh.height = 1.5
	mesh_instance.mesh = sphere_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.2, 0.2)
	material.metallic = 0.4
	material.roughness = 0.3
	material.emission_enabled = true
	material.emission = Color(1.0, 0.0, 0.0)
	material.emission_energy = 2.0
	mesh_instance.material_override = material
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	
	var y_pos = PLATFORM_HEIGHT + 1.5 if not is_top else WORLD_HEIGHT - PLATFORM_HEIGHT - 1.5
	mesh_instance.position = Vector3(x, y_pos, 0)
	
	obstacle_container.add_child(mesh_instance)
	obs_data.mesh_instance = mesh_instance
	obs_data.y = y_pos
	obstacles.append(obs_data)

func check_collision(player_pos: Vector3, on_top_platform: bool) -> bool:
	"""Check if player collided with any obstacle"""
	for obs in obstacles:
		if obs.is_top == on_top_platform:
			var distance = player_pos.distance_to(obs.mesh_instance.position)
			if distance < 2.0:
				return true
	return false

func clear_all() -> void:
	"""Remove all obstacles"""
	for obs in obstacles:
		if obs.mesh_instance and is_instance_valid(obs.mesh_instance):
			obs.mesh_instance.queue_free()
	obstacles.clear()
