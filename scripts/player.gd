extends CharacterBody2D

signal drowned
signal lantern_changed(lit: bool)
const MAX_AIR: float = 100.0
const UP_COST: float = 4.0
const DOWN_COST: float = 3.0
const SIDE_COST: float = 2.2
const LAMP_COST: float = 1.3
const PASSIVE_COST: float = 0.5
const THRUST: float = 470.0
const DRAG: float = 3.5
var air: float = MAX_AIR
var drain_rate: float = 0.0
var lantern_on: bool = false
var dying: bool = false
var death_left: float = 0.0
var world: Node2D
var clock: float = 0.0
var facing: float = 1.0
var light: PointLight2D
var aura: PointLight2D
var controlled: bool = true
var test_input: Vector2 = Vector2.ZERO
var use_test_input: bool = false
var invulnerable_left: float = 0.0
var trail_clock: float = 0.0
var swim_burst: float = 0.0
var in_current: bool = false
var flow_gliding: bool = false
var death_reason: String = "Air exhausted"

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16.0
	shape.shape = circle
	add_child(shape)
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 1))
	gradient.set_color(1, Color(1, 1, 1, 0))
	gradient.add_point(0.55, Color(1, 1, 1, 0.75))
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.width = 512
	tex.height = 512
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1, 0.5)
	light = PointLight2D.new()
	light.texture = tex
	light.texture_scale = 0.95
	light.color = Color("d8f9e7")
	light.energy = 1.5
	light.shadow_enabled = true
	light.enabled = false
	add_child(light)
	aura = PointLight2D.new()
	aura.texture = tex
	aura.texture_scale = 0.23
	aura.energy = 1.0
	aura.shadow_enabled = true
	add_child(aura)
	var mat := CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = mat

func input_vector() -> Vector2:
	if use_test_input:
		return test_input
	return Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))

func calculate_drain(direction: Vector2, up_held: bool, down_held: bool, opposing: bool) -> float:
	var thrust_cost: float = SIDE_COST if direction.x != 0.0 else 0.0
	if up_held:
		thrust_cost += UP_COST
	if down_held:
		thrust_cost += DOWN_COST
	if opposing:
		thrust_cost *= 2.0
	return PASSIVE_COST + thrust_cost + (LAMP_COST if lantern_on else 0.0)

func _physics_process(delta: float) -> void:
	clock += delta
	trail_clock += delta
	invulnerable_left = maxf(0.0, invulnerable_left - delta)
	if dying:
		death_left -= delta
		velocity = velocity.move_toward(Vector2.ZERO, 180.0 * delta)
		move_and_slide()
		queue_redraw()
		if death_left <= 0.0:
			drowned.emit()
		return
	if not controlled:
		return
	var direction := input_vector()
	var up_held: bool = direction.y < 0.0 if use_test_input else Input.is_action_pressed("up")
	var down_held: bool = direction.y > 0.0 if use_test_input else Input.is_action_pressed("down")
	var force := Vector2.ZERO
	var opposing := false
	var rip_dir := Vector2.ZERO
	in_current = false
	if is_instance_valid(world):
		for flow in world.currents:
			if flow.contains_point(global_position):
				in_current = true
				force += flow.flow_direction * flow.strength
				if flow.kind != "DRIFT" and direction.dot(flow.flow_direction) < -0.05:
					opposing = true
				if flow.kind == "RIP":
					rip_dir = flow.flow_direction
	flow_gliding = in_current and direction.is_zero_approx() and not up_held and not down_held and velocity.dot(force) > 100.0
	drain_rate = calculate_drain(direction, up_held, down_held, opposing)
	air = maxf(0.0, air - drain_rate * delta)
	if air <= 0.0:
		begin_drowning()
		return
	if direction.length() > 0.1:
		swim_burst = minf(1.0, swim_burst + delta * 4.0)
	else:
		swim_burst = maxf(0.0, swim_burst - delta * 2.2)
	var acceleration: Vector2 = direction * THRUST * (1.0 + swim_burst * 0.12) + force + Vector2(0, 32) - velocity * DRAG
	velocity += acceleration * delta
	velocity = velocity.limit_length(235.0)
	if rip_dir != Vector2.ZERO:
		var along: float = velocity.dot(rip_dir)
		if along < 45.0:
			velocity += rip_dir * (45.0 - along)
	move_and_slide()
	if is_instance_valid(world) and velocity.length() > 90.0 and trail_clock >= (0.035 if flow_gliding else 0.09):
		trail_clock = 0.0
		world.spawn_trail(global_position - velocity.normalized() * 20.0, -velocity.normalized() * 18.0)
	if absf(direction.x) > 0.01:
		facing = signf(direction.x)
	rotation = lerp_angle(rotation, clampf(velocity.y * 0.0015 * facing, -0.22, 0.22), delta * 5.0)
	queue_redraw()

func toggle_lantern() -> void:
	if dying:
		return
	lantern_on = not lantern_on
	if light:
		light.enabled = lantern_on
	lantern_changed.emit(lantern_on)
	queue_redraw()

func refill(amount: float) -> bool:
	if dying or air >= MAX_AIR:
		return false
	air = minf(MAX_AIR, air + amount)
	return true

func take_damage(amount: float, knockback: Vector2, reason: String) -> bool:
	if dying or invulnerable_left > 0.0:
		return false
	air = maxf(0.0, air - amount)
	velocity += knockback
	invulnerable_left = 0.9
	if is_instance_valid(world):
		world.spawn_burst(global_position, Color("ed7180"), 16)
		world.play_sound("contact")
		world.notify("STING  -%d AIR  /  MOVE AWAY" % int(amount))
	if air <= 0.0:
		begin_drowning(reason)
	return true

func begin_drowning(reason: String = "Air exhausted") -> void:
	if dying:
		return
	death_reason = reason
	flow_gliding = false
	dying = true
	death_left = 1.5
	lantern_on = false
	if light:
		light.enabled = false
	if is_instance_valid(world):
		world.play_sound("drown")

func reset_at(point: Vector2) -> void:
	global_position = point
	velocity = Vector2.ZERO
	rotation = 0
	air = MAX_AIR
	drain_rate = 0.0
	flow_gliding = false
	dying = false
	lantern_on = false
	death_left = 0.0
	invulnerable_left = 0.7
	death_reason = "Air exhausted"
	if light:
		light.enabled = false
	queue_redraw()

func _draw() -> void:
	var wiggle: float = sin(clock * (12.0 if velocity.length() > 35 else 4.0))
	var body_color := Color("adebd5")
	if dying:
		body_color = Color("688592")
	var fade: float = 0.6 + 0.4 * sin(clock * 22.0) if invulnerable_left > 0 else 1.0
	body_color.a = fade
	draw_set_transform(Vector2.ZERO, 0, Vector2(facing, 1))
	draw_colored_polygon(PackedVector2Array([Vector2(-17, 0), Vector2(-35, -13 + wiggle * 3), Vector2(-31, 13 + wiggle * 3)]), Color("50b9b0"))
	draw_set_transform(Vector2.ZERO, 0, Vector2(facing * 1.25, 0.83 + sin(clock * 3) * 0.035))
	draw_circle(Vector2.ZERO, 19, body_color)
	draw_set_transform(Vector2.ZERO, 0, Vector2(facing, 1))
	draw_arc(Vector2(1, 2), 11, 0.5, 2.5, 16, Color("52aaa3"), 2, true)
	draw_line(Vector2(0, -12), Vector2(4, -33), Color("9de4d0"), 2, true)
	draw_line(Vector2(4, -33), Vector2(19, -32 + wiggle), Color("9de4d0"), 2, true)
	if lantern_on:
		draw_arc(Vector2.ZERO, 180, 0, TAU, 64, Color(1.0, 0.86, 0.5, 0.28), 2, true)
	draw_circle(Vector2(20, -30 + wiggle), 6 if lantern_on else 3, Color("ffe1a3") if lantern_on else Color("6b9299"))
	if flow_gliding:
		draw_arc(Vector2.ZERO, 30, 0.6, 5.7, 32, Color("a5fff1"), 2.5, true)
	if velocity.length() > 80.0:
		for i in range(3):
			draw_circle(Vector2(-35 - i * 11, 8 + sin(clock * 5 + i) * 8), 3.5 - i * 0.6, Color(0.55, 0.92, 0.9, 0.45), false, 1.4, true)
	draw_circle(Vector2(12, -5), 6, Color("071e2c"))
	draw_circle(Vector2(14, -7), 2.2, Color.WHITE)
	# A small H-shaped jade marking connects Yuun to creator Yu Han.
	draw_line(Vector2(-7, -7), Vector2(-7, 7), Color("398f83"), 2.0, true)
	draw_line(Vector2(1, -7), Vector2(1, 7), Color("398f83"), 2.0, true)
	draw_line(Vector2(-7, 0), Vector2(1, 0), Color("398f83"), 2.0, true)
	draw_line(Vector2(21, 6), Vector2(27, 4), Color("428d8c"), 1.5, true)
