extends Node2D

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
	queue_redraw()

func _physics_process(delta: float) -> void:
	clock += delta
	if not is_instance_valid(world.player) or world.player.dying:
		return
	var p = world.player
	var detect: bool = p.lantern_on and position.distance_to(p.position) < detection_radius
	if detect:
		state = State.ATTRACTED
		saw_attraction = true
	elif state == State.ATTRACTED:
		state = State.RETURN
		saw_return = saw_attraction
	var target := home
	match state:
		State.DRIFT:
			phase += delta * 0.65
			target = home + Vector2(sin(phase) * bounds.size.x * 0.33, cos(phase) * bounds.size.y * 0.16)
		State.ATTRACTED:
			target = p.position
		State.RETURN:
			if position.distance_to(home) < 5:
				state = State.DRIFT
				phase = 0.0
	target = target.clamp(bounds.position + Vector2(20, 20), bounds.end - Vector2(20, 20))
	position = position.move_toward(target, speed * delta)
	if not harmless and p.invulnerable_left <= 0 and position.distance_to(p.position) < 34:
		p.begin_drowning("Glimmer contact")
	if harmless and saw_attraction and saw_return:
		world.complete_observation()
	queue_redraw()

func _draw() -> void:
	var c := Color("f3aa98") if state == State.ATTRACTED else Color("b7a7ec")
	var pulse: float = 1.0 + sin(clock * 3.5) * 0.06
	draw_circle(Vector2.ZERO, 22 * pulse, Color(c, 0.16))
	draw_colored_polygon(PackedVector2Array([Vector2(-19, 7), Vector2(-19, -5), Vector2(-10, -19), Vector2(10, -19), Vector2(19, -5), Vector2(19, 7)]), c)
	for i in range(5):
		var x: float = -14 + i * 7
		var line := PackedVector2Array([Vector2(x, 7), Vector2(x + sin(clock * 4 + i) * 5, 18), Vector2(x + sin(clock * 4 + i + 1) * 5, 30)])
		draw_polyline(line, Color(c, 0.85), 2, true)
	draw_circle(Vector2(-7, -3), 2.5, Color("283048"))
	draw_circle(Vector2(7, -3), 2.5, Color("283048"))
