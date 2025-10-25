extends Node
class_name SceneManager

# Manages scene lighting and environment

func initialize_scene(parent: Node) -> void:
	"""Setup lights and environment"""
	_create_lighting(parent)
	_create_environment(parent)

func _create_lighting(parent: Node) -> void:
	"""Create directional lights"""
	# Main sun light
	var sun = DirectionalLight3D.new()
	parent.add_child(sun)
	sun.position = Vector3(10, 30, 10)
	sun.rotation_degrees = Vector3(-50, -30, 0)
	sun.light_energy = 1.2
	sun.light_color = Color(1.0, 0.95, 0.8)
	sun.shadow_enabled = true
	
	# Fill light
	var fill_light = DirectionalLight3D.new()
	parent.add_child(fill_light)
	fill_light.position = Vector3(-10, 20, -10)
	fill_light.rotation_degrees = Vector3(-30, 150, 0)
	fill_light.light_energy = 0.3
	fill_light.light_color = Color(0.7, 0.8, 1.0)

func _create_environment(parent: Node) -> void:
	"""Create world environment with sky"""
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	
	var sky = Sky.new()
	var sky_material = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.15, 0.25, 0.5)
	sky_material.sky_horizon_color = Color(0.95, 0.6, 0.4)
	sky_material.ground_bottom_color = Color(0.25, 0.35, 0.3)
	sky_material.ground_horizon_color = Color(0.7, 0.5, 0.4)
	sky_material.sun_angle_max = 35.0
	sky_material.sun_curve = 0.15
	sky.sky_material = sky_material
	
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.7
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.ssao_enabled = true
	env.glow_enabled = true
	env.glow_intensity = 0.4
	env.glow_bloom = 0.3
	
	var world_env = WorldEnvironment.new()
	world_env.environment = env
	parent.add_child(world_env)
