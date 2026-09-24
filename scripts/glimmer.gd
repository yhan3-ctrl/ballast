extends CharacterBody2D

enum State { DRIFT, ATTRACTED, RETURN }
var state: State = State.DRIFT
var bounds := Rect2()
var home := Vector2.ZERO
var segment: int = 0
var harmless: bool = false
var world: Node2D
var clock: float = 0.0
var phase: float = 0.0
var detection_radius: float = 220.0
var speed: float = 265.0
var saw_attraction: bool = false
var saw_return: bool = false

var attraction_time: float = 0.0
var alert_left: float = 0.0

func _ready() -> void:
	var warning := Node2D.new()
	warning.set_script(preload("res://scripts/danger_marker.gd"))
	warning.visible = not harmless
	add_child(warning)
	collision_layer = 0
	collision_mask = 1
	var collider := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 20.0
	collider.shape = circle
	add_child(collider)

func has_sight_to(point: Vector2) -> bool:
	var query := PhysicsRayQueryParameters2D.create(global_position, point, 1)
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func setup(area: Rect2, owner_world: Node2D, seg: int, safe: bool = false) -> void:
	bounds = area
	home = area.get_center()
	position = home
	world = owner_world
	segment = seg
	harmless = safe

func reset_creature() -> void:
	position = home
	state = State.DRIFT
	phase = 0.0
	saw_attraction = false
	saw_return = false
	attraction_time = 0.0
	alert_left = 0.0
	queue_redraw()

func _physics_process(delta: float) -> void:
	clock += delta
	if not is_instance_valid(world.player) or world.player.dying:
		return
	var p = world.player
	var detect: bool = p.lantern_on and position.distance_to(p.position) < detection_radius and has_sight_to(p.global_position)
	if detect:
		if state != State.ATTRACTED:
			alert_left = 0.35
		state = State.ATTRACTED
		attraction_time += delta
		saw_attraction = attraction_time >= 0.6 and position.distance_to(home) >= 30.0
	elif state == State.ATTRACTED:
		state = State.RETURN
		attraction_time = 0.0
	var target := home
	match state:
		State.DRIFT:
			phase += delta * 0.65
			target = home + Vector2(sin(phase) * bounds.size.x * 0.33, cos(phase) * bounds.size.y * 0.16)
		State.ATTRACTED:
			target = p.position
		State.RETURN:
			if position.distance_to(home) < 5:
				saw_return = saw_attraction
				state = State.DRIFT
				phase = 0.0
	target = target.clamp(bounds.position + Vector2(20, 20), bounds.end - Vector2(20, 20))
	alert_left = maxf(0.0, alert_left - delta)
	var step_speed := speed if state == State.ATTRACTED else 120.0
	if alert_left <= 0.0:
		move_and_collide(position.direction_to(target) * minf(step_speed * delta, position.distance_to(target)))
	if not harmless and p.invulnerable_left <= 0 and position.distance_to(p.position) < 34 and has_sight_to(p.global_position):
		p.begin_drowning("Glimmer contact")
	if harmless and saw_attraction and saw_return:
		world.complete_observation()
	queue_redraw()

func _draw() -> void:
	var c := Color("f3aa98") if state == State.ATTRACTED else (Color("91d7c0") if harmless else Color("d7658b"))
	if alert_left > 0.0:
		draw_arc(Vector2.ZERO, 33, 0, TAU, 32, Color("ffd191"), 3.0, true)
	var pulse: float = 1.0 + sin(clock * 3.5) * 0.06
	draw_circle(Vector2.ZERO, 22 * pulse, Color(c, 0.16))
	draw_colored_polygon(PackedVector2Array([Vector2(-19, 7), Vector2(-19, -5), Vector2(-10, -19), Vector2(10, -19), Vector2(19, -5), Vector2(19, 7)]), c)
	for i in range(5):
		var x: float = -14 + i * 7
		var line := PackedVector2Array([Vector2(x, 7), Vector2(x + sin(clock * 4 + i) * 5, 18), Vector2(x + sin(clock * 4 + i + 1) * 5, 30)])
		draw_polyline(line, Color(c, 0.85), 2, true)
	if harmless:
		draw_circle(Vector2(-7, -3), 2.5, Color("283048"))
		draw_circle(Vector2(7, -3), 2.5, Color("283048"))
	else:
		for side in [-1.0, 1.0]:
			draw_colored_polygon(PackedVector2Array([Vector2(side * 10, -16), Vector2(side * 23, -30), Vector2(side * 20, -3)]), Color("e7879d"))
			draw_line(Vector2(side * 4, -1), Vector2(side * 13, -7), Color("fff0b8"), 4, true)
			draw_colored_polygon(PackedVector2Array([Vector2(side * 3, 8), Vector2(side * 6, 16), Vector2(side * 9, 8)]), Color("fff0b8"))
		draw_arc(Vector2.ZERO, 35, 0, TAU, 40, Color(1, 0.3, 0.4, 0.35), 2, true)
		draw_string(ThemeDB.fallback_font, Vector2(-41, -39), "DANGER", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("ff9b96"))
