extends Node
class_name BackgroundManager

# Manages background elements like clouds, mountains, ground

var clouds: Array = []
var background_objects: Node3D

func initialize(parent: Node) -> void:
	"""Initialize background elements"""
	background_objects = Node3D.new()
	background_objects.name = "BackgroundObjects"
	parent.add_child(background_objects)
	
	_create_clouds()
	_create_mountains()
	_create_ground()
	_create_birds()

func _create_clouds() -> void:
	"""Generate animated clouds"""
	for i in range(30):
		var cloud = _create_cloud()
		cloud.position = Vector3(
			randf_range(-100, 1500),
			randf_range(15, 28),
			randf_range(-50, -20)
		)
		background_objects.add_child(cloud)
		clouds.append(cloud)

func _create_cloud() -> Node3D:
	"""Create a single cloud cluster"""
	var cloud = Node3D.new()
	var num_puffs = randi() % 4 + 3
	
	for i in range(num_puffs):
		var puff = MeshInstance3D.new()
		var puff_mesh = SphereMesh.new()
		var size = randf_range(3, 6)
		puff_mesh.radius = size
		puff_mesh.height = size * 2
		puff.mesh = puff_mesh
		
		var cloud_material = StandardMaterial3D.new()
		cloud_material.albedo_color = Color(1.0, 1.0, 1.0, 0.85)
		cloud_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		cloud_material.roughness = 1.0
		puff.material_override = cloud_material
		
		puff.position = Vector3(
			randf_range(-5, 5),
			randf_range(-2, 2),
			randf_range(-2, 2)
		)
		cloud.add_child(puff)
	
	return cloud

func _create_mountains() -> void:
	"""Generate distant mountains"""
	for i in range(15):
		var mountain = MeshInstance3D.new()
		var mountain_mesh = BoxMesh.new()
		var width = randf_range(30, 80)
		var height = randf_range(15, 35)
		mountain_mesh.size = Vector3(width, height, 20)
		mountain.mesh = mountain_mesh
		
		var mountain_material = StandardMaterial3D.new()
		mountain_material.albedo_color = Color(0.3, 0.35, 0.45, 0.7)
		mountain_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mountain.material_override = mountain_material
		
		mountain.position = Vector3(
			randf_range(0, 1500),
			height / 2.0 - 5,
			randf_range(-80, -60)
		)
		background_objects.add_child(mountain)

func _create_ground() -> void:
	"""Create ground plane"""
	var ground = MeshInstance3D.new()
	var ground_mesh = PlaneMesh.new()
	ground_mesh.size = Vector2(2000, 100)
	ground.mesh = ground_mesh
	
	var ground_material = StandardMaterial3D.new()
	ground_material.albedo_color = Color(0.25, 0.4, 0.3)
	ground_material.roughness = 1.0
	ground.material_override = ground_material
	
	ground.position = Vector3(500, -15, 0)
	ground.rotation_degrees = Vector3(-90, 0, 0)
	background_objects.add_child(ground)

func _create_birds() -> void:
	"""Generate flying birds"""
	for i in range(20):
		var bird = MeshInstance3D.new()
		var bird_mesh = BoxMesh.new()
		bird_mesh.size = Vector3(0.8, 0.2, 0.2)
		bird.mesh = bird_mesh
		
		var bird_material = StandardMaterial3D.new()
		bird_material.albedo_color = Color(0.1, 0.1, 0.1)
		bird.material_override = bird_material
		
		bird.position = Vector3(
			randf_range(0, 1000),
			randf_range(18, 25),
			randf_range(-40, -25)
		)
		background_objects.add_child(bird)

func animate_background(delta: float, game_speed: float, camera_x: float) -> void:
	"""Animate background elements"""
	# Move and rotate clouds
	for cloud in clouds:
		if is_instance_valid(cloud):
			cloud.position.x -= delta * game_speed * 2.0
			if cloud.position.x < camera_x - 100:
				cloud.position.x = camera_x + 1500
			cloud.rotate_y(delta * 0.2)
