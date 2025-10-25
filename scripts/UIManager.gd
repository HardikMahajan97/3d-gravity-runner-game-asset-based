extends Node
class_name UIManager

# Manages all UI elements with improved design

signal game_restart_requested
signal game_start_requested

var ui_canvas: CanvasLayer

# HUD Elements
var score_label: Label
var distance_label: Label
var speed_label: Label
var combo_label: Label
var hud_panel: Panel

# Start Screen
var start_screen: Panel

# Game Over Panel
var game_over_panel: Panel

func initialize(parent: Node) -> void:
	"""Initialize UI with enhanced design"""
	ui_canvas = CanvasLayer.new()
	ui_canvas.name = "UICanvas"
	parent.add_child(ui_canvas)
	
	_create_start_screen()
	_create_hud()
	_create_combo_label()
	_create_game_over_panel()

func _create_start_screen() -> void:
	"""Create start screen with instructions"""
	start_screen = Panel.new()
	ui_canvas.add_child(start_screen)
	start_screen.position = Vector2(200, 100)
	start_screen.size = Vector2(800, 500)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.1, 0.95)
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	style.border_width_left = 4
	style.border_width_right = 4
	style.border_width_top = 4
	style.border_width_bottom = 4
	style.border_color = Color(0.4, 0.7, 1.0, 0.9)
	style.shadow_size = 25
	style.shadow_color = Color(0, 0, 0, 0.7)
	start_screen.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	start_screen.add_child(vbox)
	vbox.position = Vector2(50, 40)
	vbox.size = Vector2(700, 420)
	vbox.add_theme_constant_override("separation", 30)
	
	# Title
	var title = Label.new()
	vbox.add_child(title)
	title.text = "GRAVITY RUNNER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	title.add_theme_constant_override("outline_size", 12)
	
	# Subtitle
	var subtitle = Label.new()
	vbox.add_child(subtitle)
	subtitle.text = "Flip Gravity to Survive!"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 32)
	subtitle.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	subtitle.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	subtitle.add_theme_constant_override("outline_size", 6)
	
	# Instructions
	var instructions = Label.new()
	vbox.add_child(instructions)
	instructions.text = "CONTROLS\n\n[SPACE] - Flip Gravity\n[R] - Restart\n[ESC] - Quit"
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instructions.add_theme_font_size_override("font_size", 28)
	instructions.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	instructions.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	instructions.add_theme_constant_override("outline_size", 5)
	
	# Start instruction
	var start_label = Label.new()
	vbox.add_child(start_label)
	start_label.text = "PRESS SPACE TO START"
	start_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_label.add_theme_font_size_override("font_size", 36)
	start_label.add_theme_color_override("font_color", Color(0.2, 0.6, 1.0))
	start_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	start_label.add_theme_constant_override("outline_size", 8)

func _create_hud() -> void:
	"""Create minimal HUD panel"""
	hud_panel = Panel.new()
	ui_canvas.add_child(hud_panel)
	hud_panel.position = Vector2(20, 20)
	hud_panel.size = Vector2(400, 120)
	hud_panel.visible = false
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.1, 0.85)
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.4, 0.7, 1.0, 0.7)
	hud_panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	hud_panel.add_child(vbox)
	vbox.position = Vector2(20, 15)
	vbox.add_theme_constant_override("separation", 10)
	
	# Score
	var score_hbox = HBoxContainer.new()
	vbox.add_child(score_hbox)
	
	var score_icon = Label.new()
	score_hbox.add_child(score_icon)
	score_icon.text = "⚡ FLIPS:"
	score_icon.add_theme_font_size_override("font_size", 28)
	score_icon.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	score_icon.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	score_icon.add_theme_constant_override("outline_size", 6)
	
	score_label = Label.new()
	score_hbox.add_child(score_label)
	score_label.text = "0"
	score_label.add_theme_font_size_override("font_size", 36)
	score_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	score_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	score_label.add_theme_constant_override("outline_size", 7)
	
	# Distance
	var dist_hbox = HBoxContainer.new()
	vbox.add_child(dist_hbox)
	
	var dist_icon = Label.new()
	dist_hbox.add_child(dist_icon)
	dist_icon.text = "📏 DISTANCE:"
	dist_icon.add_theme_font_size_override("font_size", 24)
	dist_icon.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
	dist_icon.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	dist_icon.add_theme_constant_override("outline_size", 5)
	
	distance_label = Label.new()
	dist_hbox.add_child(distance_label)
	distance_label.text = "0m"
	distance_label.add_theme_font_size_override("font_size", 28)
	distance_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	distance_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	distance_label.add_theme_constant_override("outline_size", 6)
	
	# Speed (bottom right corner)
	var speed_panel = Panel.new()
	ui_canvas.add_child(speed_panel)
	speed_panel.position = Vector2(1050, 20)
	speed_panel.size = Vector2(130, 60)
	speed_panel.visible = false
	speed_panel.add_theme_stylebox_override("panel", style)
	
	var speed_hbox = HBoxContainer.new()
	speed_panel.add_child(speed_hbox)
	speed_hbox.position = Vector2(15, 15)
	
	var speed_icon = Label.new()
	speed_hbox.add_child(speed_icon)
	speed_icon.text = "🚀"
	speed_icon.add_theme_font_size_override("font_size", 28)
	
	speed_label = Label.new()
	speed_hbox.add_child(speed_label)
	speed_label.text = "2.0x"
	speed_label.add_theme_font_size_override("font_size", 28)
	speed_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3))
	speed_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	speed_label.add_theme_constant_override("outline_size", 6)
	
	# Store speed panel reference
	speed_panel.name = "SpeedPanel"

func _create_combo_label() -> void:
	"""Create combo/notification label"""
	combo_label = Label.new()
	ui_canvas.add_child(combo_label)
	combo_label.text = ""
	combo_label.position = Vector2(450, 150)
	combo_label.add_theme_font_size_override("font_size", 64)
	combo_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
	combo_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	combo_label.add_theme_constant_override("outline_size", 12)
	combo_label.modulate = Color(1, 1, 1, 0)

func _create_game_over_panel() -> void:
	"""Create game over panel"""
	game_over_panel = Panel.new()
	ui_canvas.add_child(game_over_panel)
	game_over_panel.visible = false
	game_over_panel.position = Vector2(300, 150)
	game_over_panel.size = Vector2(600, 400)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.97)
	style.corner_radius_top_left = 25
	style.corner_radius_top_right = 25
	style.corner_radius_bottom_left = 25
	style.corner_radius_bottom_right = 25
	style.border_width_left = 5
	style.border_width_right = 5
	style.border_width_top = 5
	style.border_width_bottom = 5
	style.border_color = Color(1.0, 0.2, 0.2, 0.8)
	style.shadow_size = 20
	style.shadow_color = Color(0, 0, 0, 0.8)
	game_over_panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	game_over_panel.add_child(vbox)
	vbox.position = Vector2(50, 40)
	vbox.size = Vector2(500, 320)
	vbox.add_theme_constant_override("separation", 25)
	
	# Title
	var title = Label.new()
	vbox.add_child(title)
	title.text = "⚠ GAME OVER ⚠"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	title.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	title.add_theme_constant_override("outline_size", 12)
	
	# Score
	var score = Label.new()
	score.name = "FinalScore"
	vbox.add_child(score)
	score.text = "⚡ Flips: 0"
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score.add_theme_font_size_override("font_size", 40)
	score.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	score.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	score.add_theme_constant_override("outline_size", 8)
	
	# Distance
	var distance = Label.new()
	distance.name = "FinalDistance"
	vbox.add_child(distance)
	distance.text = "📏 Distance: 0m"
	distance.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	distance.add_theme_font_size_override("font_size", 36)
	distance.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
	distance.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	distance.add_theme_constant_override("outline_size", 6)
	
	# Separator
	var separator = Panel.new()
	vbox.add_child(separator)
	separator.custom_minimum_size = Vector2(400, 3)
	var sep_style = StyleBoxFlat.new()
	sep_style.bg_color = Color(0.5, 0.5, 0.6, 0.5)
	separator.add_theme_stylebox_override("panel", sep_style)
	
	# Restart instruction
	var restart = Label.new()
	vbox.add_child(restart)
	restart.text = "Press [R] to Restart"
	restart.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	restart.add_theme_font_size_override("font_size", 28)
	restart.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
	restart.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	restart.add_theme_constant_override("outline_size", 6)

func show_start_screen() -> void:
	"""Show start screen"""
	start_screen.visible = true
	hud_panel.visible = false
	if ui_canvas.has_node("SpeedPanel"):
		ui_canvas.get_node("SpeedPanel").visible = false

func hide_start_screen() -> void:
	"""Hide start screen and show HUD"""
	start_screen.visible = false
	hud_panel.visible = true
	if ui_canvas.has_node("SpeedPanel"):
		ui_canvas.get_node("SpeedPanel").visible = true

func show_game_over(final_score: int, final_distance: int) -> void:
	"""Display game over screen"""
	game_over_panel.visible = true
	var vbox = game_over_panel.get_child(0)
	var score_label_go = vbox.get_node("FinalScore")
	var distance_label_go = vbox.get_node("FinalDistance")
	score_label_go.text = "⚡ Flips: %d" % final_score
	distance_label_go.text = "📏 Distance: %dm" % final_distance

func update_hud(current_score: int, current_distance: int, current_speed: float) -> void:
	"""Update HUD elements"""
	score_label.text = "%d" % current_score
	distance_label.text = "%dm" % current_distance
	speed_label.text = "%.1fx" % current_speed
	
	# Fade combo label
	if combo_label.modulate.a > 0:
		combo_label.modulate.a -= 0.02

func show_combo_text(text: String) -> void:
	"""Show temporary combo text"""
	combo_label.text = text
	combo_label.modulate = Color(1, 1, 1, 1)
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(combo_label):
		combo_label.modulate = Color(1, 1, 1, 0)

func reset_game() -> void:
	"""Reset UI for new game"""
	game_over_panel.visible = false
	combo_label.modulate = Color(1, 1, 1, 0)

func _input(event: InputEvent) -> void:
	"""Handle space key for starting game"""
	if start_screen.visible and event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			emit_signal("game_start_requested")
