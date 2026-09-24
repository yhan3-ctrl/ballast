extends Node2D

const Player = preload("res://scripts/player.gd")
const Flow = preload("res://scripts/current_area.gd")
const Vent = preload("res://scripts/vent.gd")
const Checkpoint = preload("res://scripts/checkpoint.gd")
const Glimmer = preload("res://scripts/glimmer.gd")
const Pearl = preload("res://scripts/pearl.gd")
const Hazard = preload("res://scripts/hazard.gd")
const ChapterMenu = preload("res://scripts/chapter_menu.gd")
const HUD = preload("res://scripts/hud.gd")
@export var test_room: bool = false
var player
var currents: Array = []
var vents: Array = []
var checkpoints: Array = []
var creatures: Array = []
var pearls: Array = []
var hazards: Array = []
var walls: Array[Rect2] = []
var signs: Array = []
var world_layer: Node2D
var camera: Camera2D
var hud: Node2D
var ambience: CanvasModulate
var active_checkpoint: int = 0
var spawn_point := Vector2(170, 510)
var running: bool = false
var menu: bool = true
var finished: bool = false
var paused: bool = false
var debug_visible: bool = false
var level_index: int = 0
var elapsed: float = 0.0
var segment_time: float = 0.0
var deaths: int = 0
var notice_text: String = ""
var notice_left: float = 0.0
var observation_complete: bool = false
var observation_gate: StaticBody2D
var width: float = 4800.0
var exit_point := Vector2.ZERO
var respawn_pending: bool = false
var last_reason: String = ""
var heartbeat_timer: float = 0.0
var visual_clock: float = 0.0
var level_times: Array[float] = []
var sound_streams: Dictionary = {}
var music_player: AudioStreamPlayer
var segment_records: Array[Dictionary] = []
var last_arrival: Dictionary = {}
var level_started_at: float = 0.0
var music_muted: bool = false
var current_music_path: String = "res://assets/audio/music.wav"
var effects_muted: bool = false
var event_players: Array[AudioStreamPlayer] = []
var sound_last_ms: Dictionary = {}
const EVENT_LEVELS = {"pearl": -14.0, "vent": -10.0, "checkpoint": -9.0, "complete": -8.0, "toggle": -18.0, "contact": -10.0, "drown": -11.0, "heartbeat": -15.0, "return": -13.0}
var exit_settled: bool = false
var chapter_menu
var intro_chapter: int = -1
var unlocked_chapter: int = 0
var best_times: Array = [0.0, 0.0, 0.0]
var save_warning: String = ""
var save_enabled: bool = true
var save_path_override: String = ""
var score: int = 0
var collected_pearls: int = 0
var total_pearls: int = 0
var pending_pearls: Array = []
var pending_score: int = 0
var pearl_tutorial_shown: bool = false
var pearl_tutorial_left: float = 0.0
var combo: int = 0
var best_combo: int = 0
var combo_left: float = 0.0
var last_points: int = 0
var fx_particles: Array = []
var tutorial_active: bool = true
var tutorial_origin := Vector2.ZERO
var title_names := ["THE REEF", "THE KELP DRIFT", "THE TRENCH"]
const AIR_BONUS_MULTIPLIER: int = 20

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	setup_input()
	for sound in ["vent", "checkpoint", "toggle", "drown", "contact", "complete", "heartbeat", "pearl", "return", "music"]:
		var path: String = "res://assets/audio/" + sound + ".wav"
		if ResourceLoader.exists(path):
			sound_streams[sound] = load(path)
	if DisplayServer.get_name() != "headless":
		music_player = AudioStreamPlayer.new()
		music_player.volume_db = -17.0
		add_child(music_player)
		if sound_streams.has("music"):
			var loop_stream = sound_streams["music"].duplicate()
			if loop_stream is AudioStreamWAV:
				loop_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
				loop_stream.loop_end = int(loop_stream.get_length() * loop_stream.mix_rate)
			music_player.stream = loop_stream
			music_player.play()
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	hud = HUD.new()
	hud.world = self
	layer.add_child(hud)
	save_enabled = DisplayServer.get_name() != "headless"
	load_progress()
	chapter_menu = ChapterMenu.new()
	chapter_menu.world = self
	layer.add_child(chapter_menu)
	chapter_menu.refresh()
	if test_room or "--test-room" in OS.get_cmdline_user_args():
		test_room = true
		start_game()

func setup_input() -> void:
	var actions := {"left": KEY_A, "right": KEY_D, "up": KEY_W, "down": KEY_S, "lantern": KEY_SPACE, "restart": KEY_R, "pause": KEY_ESCAPE, "debug": KEY_F1, "start": KEY_ENTER}
	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var key := InputEventKey.new()
			key.physical_keycode = actions[action]
			InputMap.action_add_event(action, key)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.is_action_pressed("debug"):
		debug_visible = not debug_visible
	if event is InputEventKey and event.physical_keycode == KEY_M:
		music_muted = not music_muted
		if is_instance_valid(music_player):
			music_player.volume_db = -80.0 if music_muted else -17.0
	if event is InputEventKey and event.physical_keycode == KEY_N:
		effects_muted = not effects_muted
		if effects_muted:
			stop_effects()
	if menu or finished:
		if event.is_action_pressed("pause"):
			to_menu()
		elif event.is_action_pressed("start"):
			if intro_chapter >= 0:
				start_chapter(intro_chapter)
			elif finished:
				to_menu()
			else:
				open_chapter(unlocked_chapter)
		elif event is InputEventKey and event.physical_keycode == KEY_T:
			test_room = true
			start_game()
		return
	if event.is_action_pressed("pause"):
		set_paused(not paused)
		return
	if paused:
		if event is InputEventKey and event.physical_keycode == KEY_Q:
			to_menu()
		return
	if event.is_action_pressed("lantern"):
		player.toggle_lantern()
	elif event.is_action_pressed("restart"):
		request_respawn("Manual restart")

func select_chapter_music() -> void:
	if not is_instance_valid(music_player):
		return
	var path := "res://assets/audio/music.wav" if menu else "res://assets/audio/music_%d.wav" % (level_index + 1)
	if current_music_path == path and music_player.playing:
		return
	if not ResourceLoader.exists(path):
		return
	var stream = load(path).duplicate()
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = int(stream.get_length() * stream.mix_rate)
	current_music_path = path
	music_player.stream = stream
	music_player.volume_db = -80.0
	music_player.play()

func progress_path() -> String:
	if not save_path_override.is_empty():
		return save_path_override
	return "res://saves/progress.cfg" if OS.has_feature("editor") else "user://progress.cfg"

func load_progress() -> void:
	if not save_enabled:
		return
	var config := ConfigFile.new()
	if config.load(progress_path()) != OK:
		return
	unlocked_chapter = clampi(int(config.get_value("progress", "unlocked", 0)), 0, 2)
	for i in range(3):
		var value = config.get_value("times", str(i), 0.0)
		if (value is float or value is int) and is_finite(float(value)) and float(value) > 0:
			best_times[i] = float(value)

func save_progress() -> void:
	if not save_enabled:
		return
	var path := progress_path()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var config := ConfigFile.new()
	config.set_value("progress", "unlocked", unlocked_chapter)
	for i in range(3):
		config.set_value("times", str(i), best_times[i])
	if config.save(path) != OK:
		save_warning = "Progress could not be saved; this session remains playable."

func open_chapter(index: int) -> bool:
	if index < 0 or index > unlocked_chapter or index > 2:
		return false
	to_menu()
	intro_chapter = index
	chapter_menu.refresh()
	return true

func start_chapter(index: int) -> bool:
	if index < 0 or index > unlocked_chapter or index > 2:
		return false
	test_room = false
	start_game(index)
	return true

func start_game(chapter: int = 0) -> void:
	stop_effects()
	set_paused(false)
	menu = false
	finished = false
	elapsed = 0
	deaths = 0
	score = 0
	collected_pearls = 0
	total_pearls = 0
	pending_pearls.clear()
	pending_score = 0
	pearl_tutorial_shown = false
	pearl_tutorial_left = 0.0
	combo = 0
	best_combo = 0
	combo_left = 0.0
	level_index = chapter
	intro_chapter = -1
	respawn_pending = false
	fx_particles.clear()
	level_times.clear()
	segment_records.clear()
	last_arrival = {}
	level_started_at = 0.0
	build_level()
	running = true
	select_chapter_music()
	chapter_menu.refresh()

func set_paused(value: bool) -> void:
	paused = value
	get_tree().paused = value
	if value:
		stop_effects()

func to_menu() -> void:
	stop_effects()
	set_paused(false)
	running = false
	menu = true
	finished = false
	intro_chapter = -1
	if is_instance_valid(world_layer):
		remove_child(world_layer)
		world_layer.queue_free()
		world_layer = null
	player = null
	select_chapter_music()
	if chapter_menu:
		chapter_menu.refresh()

func build_level() -> void:
	exit_settled = false
	level_started_at = elapsed
	if is_instance_valid(world_layer):
		remove_child(world_layer)
		world_layer.queue_free()
	currents.clear()
	vents.clear()
	checkpoints.clear()
	creatures.clear()
	pearls.clear()
	hazards.clear()
	walls.clear()
	signs.clear()
	observation_gate = null
	observation_complete = false
	active_checkpoint = 0
	segment_time = 0
	world_layer = Node2D.new()
	world_layer.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world_layer)
	width = 3300.0 if test_room else 4800.0
	ambience = CanvasModulate.new()
	ambience.color = [Color(0.22, 0.36, 0.41), Color(0.08, 0.18, 0.12), Color(0.08, 0.075, 0.16)][0 if test_room else level_index]
	world_layer.add_child(ambience)
	add_wall(Rect2(-80, 80, width + 160, 70))
	add_wall(Rect2(-80, 720, width + 160, 110))
	add_wall(Rect2(-80, 150, 90, 570))
	add_wall(Rect2(width - 10, 150, 90, 570))
	add_checkpoint(Vector2(170, 510), 0)
	if test_room:
		build_test_room()
	else:
		build_campaign_layout()
	player = Player.new()
	player.world = self
	world_layer.add_child(player)
	spawn_point = checkpoints[0].position
	player.reset_at(spawn_point)
	tutorial_origin = spawn_point
	tutorial_active = test_room
	player.drowned.connect(func(): request_respawn(player.death_reason))
	player.lantern_changed.connect(func(_lit): play_sound("toggle"))
	checkpoints[0].activated = true
	camera = Camera2D.new()
	camera.position = Vector2(640, 400)
	camera.position_smoothing_enabled = false
	world_layer.add_child(camera)
	camera.make_current()
	exit_point = Vector2(width - 140, 270 if not test_room and level_index == 2 else 500)
	notify("TEST DIVE  /  CORE + LIGHT LAB" if test_room else "%02d  /  %s" % [level_index + 1, title_names[level_index]])
	queue_redraw()

func build_test_room() -> void:
	add_sign(Vector2(110, 235), "01 / FIND YOUR BALANCE", "W / S rise & sink   •   A / D swim\nAir is fuel. Release a key to drift.")
	add_wall(Rect2(580, 150, 85, 310))
	add_vent(Vector2(780, 560), 0)
	add_flow(Rect2(830, 515, 510, 140), Vector2.RIGHT, 330, "DRIFT")
	add_pearl_line(Vector2(900, 570), Vector2(92, -18), 4, 0)
	add_hazard(Rect2(1340, 662, 105, 58))
	add_sign(Vector2(1260, 585), "RED CORAL", "Touching it costs 25 air.\nSwim above it or accept the hit.")
	add_wall(Rect2(1230, 150, 80, 305))
	add_checkpoint(Vector2(1470, 520), 1)
	add_sign(Vector2(1440, 235), "02 / SPEND LIGHT WISELY", "SPACE toggles the lantern.\nLight attracts Glimmers. Dark lets them return.")
	add_wall(Rect2(1660, 150, 90, 250))
	add_wall(Rect2(1660, 605, 90, 115))
	add_glimmer(Rect2(1770, 190, 330, 205), 1, true)
	add_pearl_line(Vector2(1800, 545), Vector2(80, -28), 4, 1)
	add_sign(Vector2(1780, 445), "SAFE OBSERVATION", "Approach below the Glimmer.\nLight it, wait for approach, then go dark.")
	add_vent(Vector2(2120, 550), 1)
	add_wall(Rect2(2300, 440, 85, 280))
	add_flow(Rect2(2390, 210, 440, 135), Vector2.RIGHT, 700, "RIP")
	add_pearl_line(Vector2(2460, 270), Vector2(82, 0), 4, 1)
	add_glimmer(Rect2(2470, 175, 300, 300), 1)
	add_sign(Vector2(2410, 395), "RIP CURRENT", "Purple flow is one way.\nExit sideways; never fight it.")
	add_sign(Vector2(2450, 525), "DANGER IS REAL", "Red coral costs 25 air.\nA hostile Glimmer ends the attempt on contact.")
	add_checkpoint(Vector2(2950, 500), 2)
	add_sign(Vector2(2920, 235), "RETURN WITH WHAT YOU LEARNED", "Reach the eggs to finish this test dive.")

func build_campaign_layout() -> void:
	for seg in range(3):
		var offset: float = seg * 1600.0
		if seg > 0:
			add_checkpoint(Vector2(offset + 140, 500), seg)
		if level_index == 0:
			add_wall(Rect2(offset + 520, 150, 90, 320))
			add_wall(Rect2(offset + 1080, 425, 90, 295))
			add_vent(Vector2(offset + 760, 540), seg)
			add_flow(Rect2(offset + 680, 230, 360, 130), Vector2.RIGHT, 310 if seg < 2 else 700, "DRIFT" if seg < 2 else "RIP")
			add_pearl_line(Vector2(offset + 700, 290), Vector2(78, 0), 4, seg)
			add_hazard(Rect2(offset + 1180, 665, 150, 55))
			if seg == 0:
				add_sign(Vector2(115, 230), "01 / A BREATH IS A CHOICE", "W / S rise & sink. A / D swim.\nFind a vent before your air runs out.")
				add_sign(Vector2(740, 635), "ONE BREATH, ONCE", "Vents give +40 air. Spent vents reset on death.")
				add_sign(Vector2(1080, 575), "STINGING CORAL", "Red means danger: -25 air and knockback.\nAvoid it now; later currents push you toward it.")
			elif seg == 1:
				add_sign(Vector2(offset + 100, 230), "02 / BORROW THE CURRENT", "Blue arrows stay visible in darkness.\nFlow carries you while you save your breath.")
				add_flow(Rect2(offset + 1175, 170, 230, 185), Vector2.LEFT, 300, "PUSH")
			else:
				add_sign(Vector2(offset + 90, 235), "03 / LIGHT CHANGES THINGS", "SPACE: lantern on / off. Approach the enclosure.\nLight attracts the Glimmer; darkness releases it.")
				add_glimmer(Rect2(offset + 570, 170, 370, 200), seg, true)
				add_sign(Vector2(offset + 620, 470), "WATCH IT RESPOND", "Light on: wait for approach.\nLight off: watch it return. Then the gate opens.")
				observation_gate = add_wall(Rect2(offset + 1370, 150, 28, 570), true)
		elif level_index == 1:
			# Alternating islands make the optional upper route different in each room.
			var island_y: float = [340.0, 400.0, 315.0][seg]
			var island_width: float = [600.0, 460.0, 720.0][seg]
			add_wall(Rect2(offset + 540, island_y, island_width, 120))
			add_flow(Rect2(offset + 350, island_y + 145, 920, 110), Vector2.RIGHT, 320, "DRIFT")
			add_flow(Rect2(offset + 1140, 195, 230, 100), Vector2.LEFT, 280, "PUSH")
			add_vent(Vector2(offset + 760, 235), seg)
			add_vent(Vector2(offset + 1370, 565), seg)
			add_pearl_line(Vector2(offset + 650, 250), Vector2(115, 0), 6, seg)
			add_pearl_line(Vector2(offset + 470, island_y + 175), Vector2(175, 0), 3, seg)
			add_hazard(Rect2(offset + 1150, 665, 150, 55))
			add_glimmer(Rect2(offset + 650, island_y + 145, 420, 700 - island_y - 145), seg)
			add_sign(Vector2(offset + 210, 260), "PEARLS ABOVE / CURRENT BELOW", "")
		else:
			# First two chambers alternate low and high gates; finale climbs to the nest.
			var gap_y: float = [440.0, 300.0, 440.0][seg]
			add_wall(Rect2(offset + 860, 150, 100, gap_y - 150))
			add_wall(Rect2(offset + 860, gap_y + 115, 100, 720 - gap_y - 115))
			add_vent(Vector2(offset + 570, 540), seg)
			add_glimmer(Rect2(offset + 560, gap_y + 15, 280, 90), seg)
			add_flow(Rect2(offset + 970, gap_y + 10, 380, 95), Vector2.RIGHT, 420, "DRIFT")
			add_pearl_line(Vector2(offset + 1020, gap_y + 45), Vector2(90, 0), 4, seg)
			add_hazard(Rect2(offset + 1170, 665, 120, 55))
			if seg == 1:
				add_wall(Rect2(offset + 1230, 420, 100, 300))
				add_vent(Vector2(offset + 1420, 320), seg)
			if seg == 2:
				add_wall(Rect2(offset + 1230, 410, 290, 310))
				add_flow(Rect2(offset + 1060, 270, 150, 330), Vector2.UP, 280, "DRIFT")
				add_vent(Vector2(offset + 1140, 360), seg)
				add_pearl_line(Vector2(offset + 1270, 285), Vector2(85, 0), 3, seg)
			add_sign(Vector2(offset + 250, 235), ["MAKE ROOM", "CHANGE DEPTH", "HOMEWARD"][seg], "")

func add_wall(rect: Rect2, gate: bool = false) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = rect.position
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	collision.position = rect.size / 2
	body.add_child(collision)
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2.ZERO, Vector2(rect.size.x, 0), rect.size, Vector2(0, rect.size.y)])
	poly.color = Color("316c70") if gate else Color("163743")
	body.add_child(poly)
	var edge := Line2D.new()
	edge.points = PackedVector2Array([Vector2.ZERO, Vector2(rect.size.x, 0), rect.size, Vector2(0, rect.size.y), Vector2.ZERO])
	edge.width = 2
	edge.default_color = Color("80c6bf") if gate else Color("376371")
	body.add_child(edge)
	var occluder := LightOccluder2D.new()
	var polygon := OccluderPolygon2D.new()
	polygon.polygon = poly.polygon
	occluder.occluder = polygon
	body.add_child(occluder)
	world_layer.add_child(body)
	if not gate:
		walls.append(rect)
	return body

func add_flow(rect: Rect2, direction: Vector2, strength: float, kind: String) -> void:
	var flow = Flow.new()
	flow.setup(rect, direction, strength, kind)
	world_layer.add_child(flow)
	currents.append(flow)

func add_vent(point: Vector2, segment: int) -> void:
	var vent = Vent.new()
	vent.position = point
	vent.segment = segment
	vent.world = self
	world_layer.add_child(vent)
	vents.append(vent)

func add_checkpoint(point: Vector2, id: int) -> void:
	var cp = Checkpoint.new()
	cp.position = point
	cp.checkpoint_id = id
	cp.world = self
	world_layer.add_child(cp)
	checkpoints.append(cp)

func add_glimmer(rect: Rect2, seg: int, harmless: bool = false) -> void:
	var creature = Glimmer.new()
	creature.setup(rect, self, seg, harmless)
	world_layer.add_child(creature)
	creatures.append(creature)

func add_pearl(point: Vector2, seg: int) -> void:
	var pearl = Pearl.new()
	pearl.position = point
	pearl.segment = seg
	pearl.world = self
	world_layer.add_child(pearl)
	pearls.append(pearl)
	total_pearls += 1

func add_pearl_line(start: Vector2, step: Vector2, count: int, seg: int) -> void:
	for i in range(count):
		add_pearl(start + step * i + Vector2(0, sin(i * 1.7) * 30), seg)

func add_hazard(rect: Rect2) -> void:
	var hazard = Hazard.new()
	hazard.setup(rect, self)
	world_layer.add_child(hazard)
	hazards.append(hazard)

func collect_pearl(pearl: Node) -> void:
	if not pearl in pearls or pearl in pending_pearls or player.dying:
		return
	combo = combo + 1 if combo_left > 0.0 else 1
	combo_left = 3.5
	best_combo = maxi(best_combo, combo)
	last_points = 100 * mini(combo, 5)
	pending_score += last_points
	pending_pearls.append(pearl)
	if not pearl_tutorial_shown:
		pearl_tutorial_shown = true
		pearl_tutorial_left = 6.0
	spawn_burst(pearl.global_position, Color("f5d69a"), 13)
	play_sound("pearl")
	notify("PEARL +%d AT RISK  /  FLOW CHAIN x%d" % [last_points, combo])

func bank_segment_rewards() -> Dictionary:
	var result := {"pearls": pending_pearls.size(), "score": pending_score}
	collected_pearls += pending_pearls.size()
	score += pending_score
	pending_pearls.clear()
	pending_score = 0
	combo = 0
	combo_left = 0.0
	return result

func discard_segment_rewards() -> int:
	var lost: int = pending_pearls.size()
	for pearl in pending_pearls:
		if is_instance_valid(pearl):
			pearl.reset_pearl()
	pending_pearls.clear()
	pending_score = 0
	combo = 0
	combo_left = 0.0
	return lost

func spawn_trail(point: Vector2, drift: Vector2) -> void:
	fx_particles.append({"position": point, "velocity": drift + Vector2(randf_range(-8, 8), randf_range(-14, 2)), "life": 0.7, "max_life": 0.7, "size": randf_range(2.0, 4.5), "color": Color("8de6df")})

func spawn_burst(point: Vector2, color: Color, count: int = 10) -> void:
	for i in range(count):
		var angle := TAU * i / float(count) + randf_range(-0.2, 0.2)
		fx_particles.append({"position": point, "velocity": Vector2.from_angle(angle) * randf_range(45, 130), "life": 0.8, "max_life": 0.8, "size": randf_range(2.5, 6.0), "color": color})

func add_sign(point: Vector2, title: String, body: String) -> void:
	signs.append({"point": point, "title": title, "body": body})
	var label := Label.new()
	label.position = point
	label.text = title + (("\n\n" + body) if test_room or title == "WATCH IT RESPOND" else "")
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color("a4c2c4"))
	var mat := CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	label.material = mat
	world_layer.add_child(label)

func activate_checkpoint(cp: Node) -> bool:
	if player.dying or respawn_pending or cp.activated or cp.checkpoint_id <= active_checkpoint:
		return false
	var banked := settle_segment("anchor")
	var air_bonus: int = banked.air_bonus
	cp.activated = true
	cp.queue_redraw()
	active_checkpoint = cp.checkpoint_id
	spawn_point = cp.position
	player.air = player.MAX_AIR
	segment_time = 0
	play_sound("checkpoint")
	spawn_burst(cp.global_position, Color("e8c38a"), 18)
	notify("ANCHOR  /  %d PEARLS BANKED  /  AIR BONUS +%d" % [banked.pearls, air_bonus])
	return true

func record_segment(event: String, air_bonus: int = 0) -> Dictionary:
	var entry := {"event": event, "level": level_index + 1, "segment": active_checkpoint + 1,
		"seconds": snappedf(segment_time, 0.01), "air": snappedf(player.air, 0.01),
		"pearls": pending_pearls.size(), "pearl_score": pending_score,
		"air_bonus": air_bonus, "reason": last_reason if event == "retry" else ""}
	segment_records.append(entry)
	print("BALLAST_TELEMETRY ", JSON.stringify(entry))
	return entry

func settle_segment(event: String) -> Dictionary:
	var air_bonus := int(round(player.air)) * AIR_BONUS_MULTIPLIER
	last_arrival = record_segment(event, air_bonus)
	var banked := bank_segment_rewards()
	score += air_bonus
	banked["air_bonus"] = air_bonus
	return banked

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and running and not finished:
		set_paused(true)

func request_respawn(reason: String) -> void:
	if respawn_pending or not running:
		return
	respawn_pending = true
	last_reason = reason
	call_deferred("respawn")

func respawn() -> void:
	if not is_instance_valid(player):
		respawn_pending = false
		return
	record_segment("retry")
	deaths += 1
	var lost_pearls: int = discard_segment_rewards()
	segment_time = 0
	for vent in vents:
		if vent.segment == active_checkpoint:
			vent.reset_vent()
	for creature in creatures:
		if creature.segment == active_checkpoint:
			creature.reset_creature()
	player.reset_at(spawn_point)
	respawn_pending = false
	play_sound("return")
	notify("BACK AT ANCHOR  /  %s  /  %d PEARLS LOST" % [last_reason.to_upper(), lost_pearls])

func complete_observation() -> void:
	if observation_complete:
		return
	observation_complete = true
	if is_instance_valid(observation_gate):
		observation_gate.queue_free()
		observation_gate = null
	notify("LIGHT DRAWS THEM IN. DARKNESS LETS THEM GO.")
	play_sound("checkpoint")

func _physics_process(delta: float) -> void:
	if not running or paused or finished or not is_instance_valid(player):
		return
	elapsed += delta
	segment_time += delta
	if tutorial_active and player.position.distance_to(tutorial_origin) > 65.0:
		tutorial_active = false
		notify("NICE. RELEASE THE KEYS TO GLIDE.")
	camera.position.x = clampf(player.position.x + 170, 640, width - 640)
	if player.air < 25 and not player.dying:
		heartbeat_timer -= delta
		if heartbeat_timer <= 0:
			play_sound("heartbeat")
			heartbeat_timer = 1.1
	if player.position.y > 900 or player.position.x < -150:
		request_respawn("Out of bounds")
	if not exit_settled and not player.dying and not respawn_pending and player.position.distance_to(exit_point) < 65:
		if level_index == 0 and not test_room and not observation_complete:
			return
		exit_settled = true
		settle_segment("exit")
		level_times.append(elapsed - level_started_at)
		play_sound("complete")
		finished = true
		running = false
		player.controlled = false
		world_layer.process_mode = Node.PROCESS_MODE_DISABLED
		if not test_room:
			unlocked_chapter = maxi(unlocked_chapter, mini(level_index + 1, 2))
			if best_times[level_index] <= 0 or elapsed < best_times[level_index]:
				best_times[level_index] = elapsed
			save_progress()
		chapter_menu.refresh()

func _process(delta: float) -> void:
	if is_instance_valid(music_player):
		var target_db := -17.0
		if paused or (is_instance_valid(player) and running and player.air < 25):
			target_db = -25.0
		if music_muted:
			target_db = -80.0
		music_player.volume_db = move_toward(music_player.volume_db, target_db, delta * 24.0)
	if not paused:
		visual_clock += delta
		notice_left = maxf(0, notice_left - delta)
		pearl_tutorial_left = maxf(0.0, pearl_tutorial_left - delta)
		combo_left = maxf(0.0, combo_left - delta)
		if combo_left <= 0.0:
			combo = 0
		for particle in fx_particles:
			particle.position += particle.velocity * delta
			particle.velocity *= pow(0.16, delta)
			particle.velocity.y -= 13.0 * delta
			particle.life -= delta
		fx_particles = fx_particles.filter(func(p): return p.life > 0.0)
	queue_redraw()
	if hud:
		hud.queue_redraw()

func notify(message: String) -> void:
	notice_text = message
	notice_left = 4.0

func stop_effects() -> void:
	for audio in event_players:
		if is_instance_valid(audio):
			audio.stop()
			audio.queue_free()
	event_players.clear()

func play_sound(sound: String) -> void:
	if effects_muted or not sound_streams.has(sound) or DisplayServer.get_name() == "headless":
		return
	var now := Time.get_ticks_msec()
	var cooldown := 90 if sound == "pearl" else 140
	if now - int(sound_last_ms.get(sound, -10000)) < cooldown:
		return
	sound_last_ms[sound] = now
	event_players = event_players.filter(func(p): return is_instance_valid(p) and not p.is_queued_for_deletion())
	if sound in ["contact", "drown", "complete"]:
		stop_effects()
	elif event_players.size() >= 6:
		var oldest: AudioStreamPlayer = event_players.pop_front()
		oldest.stop()
		oldest.queue_free()
	var audio := AudioStreamPlayer.new()
	audio.stream = sound_streams[sound]
	audio.volume_db = EVENT_LEVELS.get(sound, -12.0)
	if sound == "pearl":
		audio.pitch_scale = pow(2.0, mini(maxi(combo - 1, 0), 4) / 12.0)
	audio.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(audio)
	event_players.append(audio)
	audio.finished.connect(audio.queue_free)
	audio.play()

func _draw() -> void:
	if menu or not is_instance_valid(player):
		return
	# Original procedural environment: fine suspended particles and kelp silhouettes.
	for i in range(7):
		var ray_x: float = fmod(i * 780.0 - visual_clock * (5.0 + i), width + 900.0) - 450.0
		draw_colored_polygon(PackedVector2Array([Vector2(ray_x, 150), Vector2(ray_x + 110, 150), Vector2(ray_x + 430, 720), Vector2(ray_x + 250, 720)]), Color(0.28, 0.72, 0.68, 0.018))
	for i in range(210):
		var x: float = fmod(float(i * 139) + sin(visual_clock * 0.2 + i) * 14, width)
		var y: float = 155 + fmod(float(i * 97) - visual_clock * 7 + 10000, 550)
		draw_circle(Vector2(x, y), 1 if i % 4 else 2, Color(0.23, 0.47, 0.53, 0.25))
	for i in range(14):
		var school_x: float = fmod(i * 347.0 + visual_clock * (18.0 + i % 4 * 5.0), width + 240.0) - 120.0
		var school_y: float = 205.0 + fmod(i * 91.0, 420.0) + sin(visual_clock * 0.8 + i) * 19.0
		var fish_color := Color(0.38, 0.72, 0.72, 0.12 + (i % 3) * 0.025)
		draw_circle(Vector2(school_x, school_y), 6.0 + i % 3, fish_color)
		draw_colored_polygon(PackedVector2Array([Vector2(school_x - 5, school_y), Vector2(school_x - 15, school_y - 6), Vector2(school_x - 15, school_y + 6)]), fish_color)
	for i in range(int(width / 95)):
		var x: float = i * 95 + 30
		var points := PackedVector2Array()
		for j in range(8):
			points.append(Vector2(x + sin(visual_clock * 0.7 + j * 0.5 + i) * j * 2, 720 - j * (8 + i % 6)))
		draw_polyline(points, Color("163d43"), 5, true)
	var pulse: float = sin(visual_clock * 2) * 3
	draw_arc(exit_point, 48 + pulse, 0, TAU, 50, Color("e7c486"), 2, true)
	for i in range(3):
		draw_circle(exit_point + Vector2((i - 1) * 23, -8 if i == 1 else 6), 13, Color("e9d6ae"))
		draw_circle(exit_point + Vector2((i - 1) * 23 + 3, -11 if i == 1 else 3), 4, Color("fff1ce"))
	for particle in fx_particles:
		var alpha: float = particle.life / particle.max_life
		draw_circle(particle.position, particle.size * (0.5 + alpha * 0.5), Color(particle.color, alpha * 0.8), false, 1.5, true)
