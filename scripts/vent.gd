extends Area2D
var used: bool = false
var segment: int = 0
var world: Node2D
var clock: float = 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var c := CollisionShape2D.new()
	var s := CircleShape2D.new()
	s.radius = 30
	c.shape = s
	add_child(c)
	body_entered.connect(_touch)

func try_collect(body: Node) -> bool:
	if used or not body.has_method("refill"):
		return false
	if body.refill(40.0):
		used = true
		if world:
			world.play_sound("vent")
			world.notify("AIR +40  /  VENT SPENT")
		queue_redraw()
		return true
	return false

func _touch(body: Node) -> void:
	try_collect(body)

func reset_vent() -> void:
	used = false
	queue_redraw()

func _process(delta: float) -> void:
	clock += delta
	queue_redraw()

func _draw() -> void:
	var c := Color("5acabd") if not used else Color("2c555c")
	draw_colored_polygon(PackedVector2Array([Vector2(-26, 23), Vector2(-16, -4), Vector2(1, -15), Vector2(19, -5), Vector2(27, 23)]), Color("214b50"))
	draw_arc(Vector2.ZERO, 24, 0, TAU, 32, c, 2, true)
	if not used:
		draw_line(Vector2(-7, 0), Vector2(7, 0), c, 2)
		draw_line(Vector2(0, -7), Vector2(0, 7), c, 2)
		for i in range(4):
			var y: float = -20 - fmod(clock * 25 + i * 17, 66)
			draw_circle(Vector2(sin(float(i) * 7 + clock) * 11, y), 2 + i % 2, Color(c, 0.7), false, 1.0, true)
	else:
		draw_line(Vector2(-7, 0), Vector2(7, 0), c, 2)
