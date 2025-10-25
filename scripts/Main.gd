extends Node3D

# Main game controller with proper exception handling and modular structure

# Game state variables
var on_top_platform: bool = false
var is_flipping: bool = false
var flip_progress: float = 0.0
var game_speed: float = 2.0
var camera_x: float = 0.0
var game_over: bool = false
var frame_counter: int = 0
var score: int = 0
var distance_traveled: float = 0.0
var game_started: bool = false

# Constants
const PLATFORM_HEIGHT: float = 3.0
const PLATFORM_WIDTH: float = 10.0
const MIN_GAP_SIZE: float = 8.0
const MAX_GAP_SIZE: float = 15.0
const MIN_PLATFORM_LENGTH: float = 20.0
const MAX_PLATFORM_LENGTH: float = 40.0
const WORLD_HEIGHT: float = 30.0
const PLAYER_SPEED_MULTIPLIER: float = 10.0

# Module references
var scene_manager: Node
var platform_manager: Node
var obstacle_manager: Node
var ui_manager: Node
var player_controller: Node
var background_manager: Node

# Node references
var camera: Camera3D
var player: Node3D

func _ready() -> void:
	_initialize_game()

func _initialize_game() -> void:
	"""Initialize game with proper error handling"""
	_setup_modules()
	_setup_scene()
	init_game()
	print("Game initialized successfully")

func _setup_modules() -> void:
	"""Initialize all game modules"""
	scene_manager = SceneManager.new()
	scene_manager.name = "SceneManager"
	add_child(scene_manager)
	
	platform_manager = PlatformManager.new()
	platform_manager.name = "PlatformManager"
	add_child(platform_manager)
	
	obstacle_manager = ObstacleManager.new()
	obstacle_manager.name = "ObstacleManager"
	add_child(obstacle_manager)
	
	ui_manager = UIManager.new()
	ui_manager.name = "UIManager"
	add_child(ui_manager)
	
	background_manager = BackgroundManager.new()
	background_manager.name = "BackgroundManager"
	add_child(background_manager)
	
	player_controller = PlayerController.new()
	player_controller.name = "PlayerController"
	add_child(player_controller)

func _setup_scene() -> void:
	"""Setup main scene components"""
	# Create camera
	camera = Camera3D.new()
	add_child(camera)
	camera.position = Vector3(8, 15, 35)
	camera.rotation_degrees = Vector3(-12, 0, 0)
	camera.fov = 65
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	
	# Initialize scene (lights, environment)
	scene_manager.initialize_scene(self)
	
	# Initialize background
	background_manager.initialize(self)
	
	# Initialize player
	player = player_controller.create_player(self)
	if player == null:
		push_error("Failed to create player")
		return
	
	# Initialize UI
	ui_manager.initialize(self)
	ui_manager.game_restart_requested.connect(_on_restart_requested)
	ui_manager.game_start_requested.connect(_on_game_start)

func init_game() -> void:
	"""Initialize or reset game state"""
	# Clear existing platforms and obstacles
	platform_manager.clear_all()
	obstacle_manager.clear_all()
	
	# Reset player
	if player:
		player.position = Vector3(10, PLATFORM_HEIGHT, 0)
		player.rotation_degrees = Vector3(0, 0, 0)
	
	# Reset game state
	on_top_platform = false
	is_flipping = false
	flip_progress = 0.0
	camera_x = 0.0
	game_speed = 2.0
	frame_counter = 0
	score = 0
	distance_traveled = 0.0
	game_over = false
	game_started = false
	
	# Reset UI
	ui_manager.reset_game()
	ui_manager.show_start_screen()
	
	# Generate initial platforms
	generate_fair_platforms()

func generate_fair_platforms() -> void:
	"""Generate platforms with fair difficulty progression"""
	var current_x: float = 0.0
	
	# Create starting platforms
	platform_manager.create_platform(current_x, current_x + 60, false)
	platform_manager.create_platform(current_x, current_x + 60, true)
	current_x += 60
	
	var current_player_side: bool = false
	
	# Generate procedural platforms
	for i in range(100):
		var gap_size: float = randf_range(MIN_GAP_SIZE, MAX_GAP_SIZE)
		var platform_length: float = randf_range(MIN_PLATFORM_LENGTH, MAX_PLATFORM_LENGTH)
		var gap_start: float = current_x
		var gap_end: float = current_x + gap_size
		var opposite_side: bool = !current_player_side
		
		# Create bridge platform and main platform
		platform_manager.create_platform(gap_start - 5, gap_end + 10, opposite_side)
		current_x = gap_end
		platform_manager.create_platform(current_x, current_x + platform_length, opposite_side)
		
		# Add obstacles on longer platforms
		if i > 5 and platform_length > 25 and randf() < 0.5:
			var obstacle_x: float = current_x + platform_length * 0.5
			obstacle_manager.create_obstacle(obstacle_x, opposite_side)
			
			# Ensure safety platform exists
			var safety_extension: float = obstacle_x + 15
			if not platform_manager.has_platform_coverage(obstacle_x - 10, safety_extension, current_player_side):
				platform_manager.create_platform(obstacle_x - 10, safety_extension, current_player_side)
		
		current_x += platform_length
		current_player_side = opposite_side
		
		# Loop generation
		if i == 90:
			i = 0

func _process(delta: float) -> void:
	"""Main game loop"""
	if not game_started:
		return
	
	if not game_over:
		update_game(delta)
		player_controller.animate_character(delta, game_speed, is_flipping, on_top_platform)
		background_manager.animate_background(delta, game_speed, camera_x)
	
	update_ui()

func update_game(delta: float) -> void:
	"""Update game state"""
	# Increase speed over time
	frame_counter += 1
	if frame_counter >= 600:
		game_speed += 0.5
		frame_counter = 0
		ui_manager.show_combo_text("SPEED UP!")
	
	# Handle flip animation
	if is_flipping:
		flip_progress += 0.15
		if flip_progress >= 1.0:
			flip_progress = 0.0
			is_flipping = false
			
			var target_y: float = WORLD_HEIGHT - PLATFORM_HEIGHT - 1.5 if on_top_platform else PLATFORM_HEIGHT + 1.5
			player.position.y = target_y
			
			player.rotation_degrees.z = 180 if on_top_platform else 0
	
	# Interpolate player position during flip
	if is_flipping:
		var start_y: float = PLATFORM_HEIGHT + 1.5 if not on_top_platform else WORLD_HEIGHT - PLATFORM_HEIGHT - 1.5
		var target_y: float = WORLD_HEIGHT - PLATFORM_HEIGHT - 1.5 if on_top_platform else PLATFORM_HEIGHT + 1.5
		player.position.y = lerp(start_y, target_y, flip_progress)
		
		var target_rotation: float = 180.0 if on_top_platform else 0.0
		var start_rotation: float = 0.0 if on_top_platform else 180.0
		player.rotation_degrees.z = lerp(start_rotation, target_rotation, flip_progress)
	
	# Move player and camera
	var movement: float = game_speed * delta * PLAYER_SPEED_MULTIPLIER
	player.position.x += movement
	distance_traveled += movement
	
	camera_x = player.position.x - 10
	camera.position.x = camera_x
	camera.position.y = 15
	
	# Check for game over conditions
	if check_collisions() or not check_platform_collision():
		trigger_game_over()

func check_collisions() -> bool:
	"""Check if player collided with any obstacles"""
	return obstacle_manager.check_collision(player.position, on_top_platform)

func check_platform_collision() -> bool:
	"""Check if player is on a platform"""
	return platform_manager.check_collision(player.position.x, on_top_platform)

func trigger_game_over() -> void:
	"""Handle game over state"""
	game_over = true
	ui_manager.show_game_over(score, int(distance_traveled))

func update_ui() -> void:
	"""Update UI elements"""
	if not game_over and game_started:
		ui_manager.update_hud(score, int(distance_traveled), game_speed)

func _input(event: InputEvent) -> void:
	"""Handle input events"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				if not game_started:
					return
				if not game_over and not is_flipping:
					on_top_platform = !on_top_platform
					is_flipping = true
					flip_progress = 0.0
					score += 1
					ui_manager.show_combo_text("FLIP!")
			
			KEY_R:
				if game_over:
					_on_restart_requested()
			
			KEY_ESCAPE:
				get_tree().quit()

func _on_restart_requested() -> void:
	"""Handle restart request"""
	game_over = false
	init_game()

func _on_game_start() -> void:
	"""Handle game start"""
	game_started = true
	ui_manager.hide_start_screen()
