extends Node
class_name PlayerController

# Manages player creation and animation with vertex-based body coloring

const PLATFORM_HEIGHT: float = 3.0

var player: Node3D
var animation_player: AnimationPlayer
var skeleton: Skeleton3D
var walk_cycle: float = 0.0
var initial_player_position: Vector3 = Vector3.ZERO

func create_player(parent: Node) -> Node3D:
	"""Create player character from external asset"""
	var player_scene = load("res://assets/characters/runner.glb")
	
	if player_scene == null:
		push_error("Failed to load runner.glb - check file location")
		return null
	
	player = player_scene.instantiate()
	parent.add_child(player)
	
	player.scale = Vector3(2.5, 2.5, 2.5)
	player.rotation_degrees.y = 180
	initial_player_position = player.position
	
	animation_player = _find_animation_player(player)
	skeleton = _find_skeleton(player)
	
	# NEW: Apply shader that uses bone/vertex position to color body parts
	call_deferred("_apply_body_part_shader", player)
	call_deferred("_setup_animation")
	
	print("Player created successfully")
	if animation_player:
		print("Animation player found with animations: ", animation_player.get_animation_list())
	
	return player

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result = _find_animation_player(child)
		if result:
			return result
	return null

func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for child in node.get_children():
		var result = _find_skeleton(child)
		if result:
			return result
	return null

func _find_mesh_by_name(node: Node, mesh_name: String) -> MeshInstance3D:
	"""Find mesh by exact name"""
	if node is MeshInstance3D and node.name == mesh_name:
		return node
	
	for child in node.get_children():
		var result = _find_mesh_by_name(child, mesh_name)
		if result:
			return result
	return null

func _apply_body_part_shader(node: Node) -> void:
	"""Apply shader that colors body based on world position"""
	print("\n=== APPLYING BODY SHADER ===")
	
	# Find the specific mesh we saw in the import dialog
	var mesh_instance = _find_mesh_by_name(node, "runner_Mesh")
	
	if not mesh_instance:
		push_error("Could not find runner_Mesh!")
		# Fallback: find any mesh
		mesh_instance = _find_any_mesh(node)
		if mesh_instance:
			print("Found alternative mesh: ", mesh_instance.name)
	else:
		print("✓ Found runner_Mesh")
	
	if not mesh_instance:
		push_error("No mesh found at all!")
		return
	
	# Get skeleton for bone-based calculations
	var character_skeleton = skeleton
	
	# Create shader material
	var shader_material = ShaderMaterial.new()
	var shader = Shader.new()
	
	# Shader that uses vertex Y position in MODEL space (before transformations)
	shader.code = """
shader_type spatial;
render_mode cull_back;

// Body part colors
const vec3 SKIN_COLOR = vec3(0.92, 0.73, 0.62);
const vec3 HAIR_COLOR = vec3(0.15, 0.10, 0.08);
const vec3 SHIRT_COLOR = vec3(0.20, 0.40, 0.85);
const vec3 PANTS_COLOR = vec3(0.15, 0.17, 0.25);
const vec3 SHOES_COLOR = vec3(0.30, 0.20, 0.15);

void vertex() {
	// Keep vertex shader simple
}

void fragment() {
	// Get vertex position in MODEL space (local to the character)
	vec3 world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 model_vertex = VERTEX;
	
	// Use MODEL space Y coordinate (character's local up/down)
	float height = model_vertex.y;
	
	// Mixamo characters are roughly:
	// - Head top: ~1.0 to 0.8
	// - Neck/Face: 0.8 to 0.6
	// - Torso/Arms: 0.6 to 0.0
	// - Hips: 0.0 to -0.2
	// - Legs: -0.2 to -0.9
	// - Feet: -0.9 to -1.0
	
	vec3 color = SKIN_COLOR;
	
	// Hair region (top of head)
	if (height > 0.85) {
		color = HAIR_COLOR;
	}
	// Face/Head/Neck (skin exposed)
	else if (height > 0.6) {
		color = SKIN_COLOR;
	}
	// Torso region (shirt)
	else if (height > 0.0) {
		// Check if this is arms (X distance from center)
		float arm_distance = abs(model_vertex.x);
		
		if (arm_distance > 0.15) {
			// Arms and hands - skin tone
			color = SKIN_COLOR;
		} else {
			// Torso - shirt color
			color = SHIRT_COLOR;
		}
	}
	// Hip region
	else if (height > -0.15) {
		color = PANTS_COLOR;
	}
	// Legs region
	else if (height > -0.85) {
		color = PANTS_COLOR;
	}
	// Feet region
	else {
		color = SHOES_COLOR;
	}
	
	// Add basic lighting
	vec3 light_dir = normalize(vec3(0.5, 1.0, 0.5));
	float ndotl = max(dot(NORMAL, light_dir), 0.0);
	float lighting = mix(0.4, 1.0, ndotl); // Ambient + diffuse
	
	ALBEDO = color * lighting;
	ROUGHNESS = 0.7;
	METALLIC = 0.0;
	SPECULAR = 0.3;
}
"""
	
	shader_material.shader = shader
	
	# Apply material to ALL surfaces
	var mesh = mesh_instance.mesh
	if mesh:
		print("Mesh has ", mesh.get_surface_count(), " surface(s)")
		
		# Clear any existing materials first
		mesh_instance.material_override = null
		for i in range(mesh.get_surface_count()):
			mesh_instance.set_surface_override_material(i, null)
		
		# Apply our shader to each surface
		for i in range(mesh.get_surface_count()):
			mesh_instance.set_surface_override_material(i, shader_material.duplicate())
			print("  ✓ Applied shader to surface ", i)
	
	# Also set as override (highest priority)
	mesh_instance.material_override = shader_material
	
	print("=== SHADER APPLIED ===\n")

func _find_any_mesh(node: Node) -> MeshInstance3D:
	"""Find any MeshInstance3D in the tree"""
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var result = _find_any_mesh(child)
		if result:
			return result
	return null

func _setup_animation() -> void:
	if not animation_player:
		return
	
	var anim_list = animation_player.get_animation_list()
	
	if anim_list.size() == 0:
		push_warning("No animations found")
		return
	
	var run_anim_name = ""
	var possible_names = ["mixamo.com", "Running", "Run", "running", "run", 
						  "Walk", "walk", "Armature|mixamo.com", "Armature|mixamo_com|Layer0"]
	
	for possible_name in possible_names:
		if possible_name in anim_list:
			run_anim_name = possible_name
			break
	
	if run_anim_name == "":
		for anim_name in anim_list:
			var lower_name = anim_name.to_lower()
			if "run" in lower_name or "walk" in lower_name or "mixamo" in lower_name:
				run_anim_name = anim_name
				break
	
	if run_anim_name == "":
		run_anim_name = anim_list[0]
	
	print("Playing animation: ", run_anim_name)
	
	var animation = animation_player.get_animation(run_anim_name)
	if animation:
		animation.loop_mode = Animation.LOOP_LINEAR
		
		# Disable position tracks
		for track_idx in range(animation.get_track_count()):
			var track_path = animation.track_get_path(track_idx)
			var track_type = animation.track_get_type(track_idx)
			
			if track_type == Animation.TYPE_POSITION_3D:
				var path_string = str(track_path)
				if ("Armature" in path_string or "Root" in path_string or 
					"root" in path_string or "Hips" in path_string or 
					path_string.get_name_count() <= 2):
					animation.track_set_enabled(track_idx, false)
	
	animation_player.root_motion_track = NodePath()
	animation_player.play(run_anim_name)
	animation_player.speed_scale = 1.5

func animate_character(delta: float, game_speed: float, is_flipping: bool, on_top_platform: bool) -> void:
	if not player or not animation_player:
		return
	
	if is_flipping:
		animation_player.speed_scale = 0.5
	else:
		var anim_speed = 1.0 + (game_speed - 2.0) * 0.3
		animation_player.speed_scale = clamp(anim_speed, 1.0, 2.5)
	
	if on_top_platform:
		player.rotation_degrees.y = 180
	else:
		player.rotation_degrees.y = 0
	
	if player.get_child_count() > 0:
		for child in player.get_children():
			if child is Node3D and not child is AnimationPlayer:
				child.position.x = 0
				child.position.z = 0
	
	if not is_flipping:
		walk_cycle += delta * game_speed * 3.0
		var bounce = sin(walk_cycle * 1.5) * 0.01
		player.position.y += bounce 
