extends Node2D

const Player = preload("res://scripts/player.gd")
const Flow = preload("res://scripts/current_area.gd")
const Vent = preload("res://scripts/vent.gd")
const Checkpoint = preload("res://scripts/checkpoint.gd")
const Glimmer = preload("res://scripts/glimmer.gd")
const HUD = preload("res://scripts/hud.gd")
@export var test_room: bool = false
var player
var currents: Array = []
var vents: Array = []
var checkpoints: Array = []
var creatures: Array = []
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
var title_names := ["THE REEF", "THE KELP DRIFT", "THE TRENCH"]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	setup_input()
	for sound in ["vent", "checkpoint", "toggle", "drown", "contact", "complete", "heartbeat"]:
		var path: String = "res://assets/audio/" + sound + ".wav"
		if ResourceLoader.exists(path):
			sound_streams[sound] = load(path)
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	hud = HUD.new()
	hud.world = self
	layer.add_child(hud)
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
	if menu or finished:
		if event.is_action_pressed("start"):
			test_room = false
			start_game()
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

func start_game() -> void:
	set_paused(false)
	menu = false
	finished = false
	elapsed = 0
	deaths = 0
	level_index = 0
	level_times.clear()
	build_level()
	running = true

func set_paused(value: bool) -> void:
	paused = value
	get_tree().paused = value

func to_menu() -> void:
	set_paused(false)
	running = false
	menu = true
	if is_instance_valid(world_layer):
		world_layer.queue_free()
	player = null

func build_level() -> void:
	if is_instance_valid(world_layer):
		remove_child(world_layer)
		world_layer.queue_free()
	currents.clear()
	vents.clear()
	checkpoints.clear()
	creatures.clear()
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
	ambience.color = Color(0.22, 0.36, 0.41) if test_room or level_index == 0 else Color(0.055, 0.085, 0.13)
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
	player.drowned.connect(func(): request_respawn("Air exhausted"))
	player.lantern_changed.connect(func(_lit): play_sound("toggle"))
	checkpoints[0].activated = true
	camera = Camera2D.new()
	camera.position = Vector2(640, 400)
	camera.position_smoothing_enabled = false
	world_layer.add_child(camera)
	camera.make_current()
	exit_point = Vector2(width - 140, 500)
	notify("TEST DIVE  /  CORE + LIGHT LAB" if test_room else "%02d  /  %s" % [level_index + 1, title_names[level_index]])
	queue_redraw()

func build_test_room() -> void:
	add_sign(Vector2(110, 235), "01 / FIND YOUR BALANCE", "W / S rise & sink   •   A / D swim\nAir is fuel. Release a key to drift.")
	add_wall(Rect2(580, 150, 85, 310))
	add_vent(Vector2(780, 560), 0)
	add_flow(Rect2(830, 515, 510, 140), Vector2.RIGHT, 330, "DRIFT")
	add_wall(Rect2(1230, 150, 80, 305))
	add_checkpoint(Vector2(1470, 520), 1)
	add_sign(Vector2(1440, 235), "02 / SPEND LIGHT WISELY", "SPACE toggles the lantern.\nLight attracts Glimmers. Dark lets them return.")
	add_wall(Rect2(1660, 150, 90, 250))
	add_wall(Rect2(1660, 605, 90, 115))
	add_glimmer(Rect2(1770, 190, 330, 205), 1, true)
	add_sign(Vector2(1780, 445), "SAFE OBSERVATION", "Approach below the Glimmer.\nLight it, wait for approach, then go dark.")
	add_vent(Vector2(2120, 550), 1)
	add_wall(Rect2(2300, 440, 85, 280))
	add_flow(Rect2(2390, 210, 440, 135), Vector2.RIGHT, 700, "RIP")
	add_sign(Vector2(2410, 395), "RIP CURRENT", "Purple flow is one way.\nExit sideways; never fight it.")
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
			if seg == 0:
				add_sign(Vector2(115, 230), "01 / A BREATH IS A CHOICE", "W / S rise & sink. A / D swim.\nFind a vent before your air runs out.")
				add_sign(Vector2(740, 635), "ONE BREATH, ONCE", "Vents give +40 air. Spent vents reset on death.")
			elif seg == 1:
				add_sign(Vector2(offset + 100, 230), "02 / BORROW THE CURRENT", "Blue arrows stay visible in darkness.\nFlow carries you while you save your breath.")
				add_flow(Rect2(offset + 1175, 170, 230, 185), Vector2.LEFT, 300, "PUSH")
			else:
				add_sign(Vector2(offset + 90, 235), "03 / LIGHT CHANGES THINGS", "SPACE: lantern on / off. Approach the enclosure.\nLight attracts the Glimmer; darkness releases it.")
				add_glimmer(Rect2(offset + 570, 170, 370, 200), seg, true)
				add_sign(Vector2(offset + 620, 470), "WATCH IT RESPOND", "Light on: wait for approach.\nLight off: watch it return. Then the gate opens.")
				observation_gate = add_wall(Rect2(offset + 1370, 150, 28, 570), true)
		else:
			# Two routes: upper path demands ascent, lower path offers current assistance.
			add_wall(Rect2(offset + 540, 340, 600, 120))
			add_flow(Rect2(offset + 370, 500, 900, 125), Vector2.RIGHT, 320, "DRIFT")
			add_flow(Rect2(offset + 1150, 195, 240, 120), Vector2.LEFT, 280, "PUSH")
			add_vent(Vector2(offset + 720, 235), seg)
			add_vent(Vector2(offset + 1270, 550), seg)
			if level_index == 1:
				add_glimmer(Rect2(offset + 670, 480, 450, 210), seg)
				add_sign(Vector2(offset + 80, 230), "%02d / CHOOSE YOUR COST" % (seg + 1), "High route: spend air climbing.\nLow route: borrow the flow, travel dark near Glimmers.")
			else:
				add_glimmer(Rect2(offset + 970, 210, 480, 480), seg)
				add_wall(Rect2(offset + 1390, 150, 60, 270))
				add_wall(Rect2(offset + 1390, 550, 60, 170))
				add_sign(Vector2(offset + 80, 230), "%02d / MAKE AN OPENING" % (seg + 1), "Draw the Glimmer away from the passage.\nGo dark, descend, and borrow the current.")

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

func add_sign(point: Vector2, title: String, body: String) -> void:
	signs.append({"point": point, "title": title, "body": body})
	var label := Label.new()
	label.position = point
	label.text = title + "\n\n" + body
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color("a4c2c4"))
	var mat := CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	label.material = mat
	world_layer.add_child(label)

func activate_checkpoint(cp: Node) -> bool:
	if player.dying or respawn_pending or cp.activated or cp.checkpoint_id <= active_checkpoint:
		return false
	cp.activated = true
	cp.queue_redraw()
	active_checkpoint = cp.checkpoint_id
	spawn_point = cp.position
	player.air = player.MAX_AIR
	segment_time = 0
	play_sound("checkpoint")
	notify("ANCHOR SET  /  AIR RESTORED")
	return true

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
	deaths += 1
	segment_time = 0
	for vent in vents:
		if vent.segment == active_checkpoint:
			vent.reset_vent()
	for creature in creatures:
		if creature.segment == active_checkpoint:
			creature.reset_creature()
	player.reset_at(spawn_point)
	respawn_pending = false
	play_sound("contact")
	notify("BACK AT ANCHOR  /  " + last_reason.to_upper())

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
	camera.position.x = clampf(player.position.x + 170, 640, width - 640)
	if player.air < 25 and not player.dying:
		heartbeat_timer -= delta
		if heartbeat_timer <= 0:
			play_sound("heartbeat")
			heartbeat_timer = 1.1
	if player.position.y > 900 or player.position.x < -150:
		request_respawn("Out of bounds")
	if not player.dying and not respawn_pending and player.position.distance_to(exit_point) < 65:
		if level_index == 0 and not test_room and not observation_complete:
			return
		play_sound("complete")
		if test_room or level_index >= 2:
			finished = true
			running = false
			player.controlled = false
			world_layer.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			level_times.append(elapsed)
			level_index += 1
			call_deferred("build_level")

func _process(delta: float) -> void:
	if not paused:
		visual_clock += delta
		notice_left = maxf(0, notice_left - delta)
	queue_redraw()
	if hud:
		hud.queue_redraw()

func notify(message: String) -> void:
	notice_text = message
	notice_left = 4.0

func play_sound(sound: String) -> void:
	if not sound_streams.has(sound) or DisplayServer.get_name() == "headless":
		return
	var audio := AudioStreamPlayer.new()
	audio.stream = sound_streams[sound]
	audio.volume_db = -12 if sound != "heartbeat" else -19
	add_child(audio)
	audio.finished.connect(audio.queue_free)
	audio.play()

func _draw() -> void:
	if menu or not is_instance_valid(player):
		return
	# Original procedural environment: fine suspended particles and kelp silhouettes.
	for i in range(210):
		var x: float = fmod(float(i * 139) + sin(visual_clock * 0.2 + i) * 14, width)
		var y: float = 155 + fmod(float(i * 97) - visual_clock * 7 + 10000, 550)
		draw_circle(Vector2(x, y), 1 if i % 4 else 2, Color(0.23, 0.47, 0.53, 0.25))
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
