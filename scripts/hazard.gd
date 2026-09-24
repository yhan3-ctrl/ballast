extends Area2D

var world: Node2D
var bounds := Rect2()
var clock: float = 0.0

func setup(rect: Rect2, owner_world: Node2D) -> void:
	bounds = rect
	position = rect.position
	world = owner_world

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = bounds.size
	collision.position = bounds.size / 2.0
	collision.shape = shape
	add_child(collision)
	body_entered.connect(_touch)
	var mat := CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = mat

func _touch(body: Node) -> void:
	if body == world.player:
		var away: Vector2 = (body.global_position - (position + bounds.size / 2.0)).normalized()
		if away == Vector2.ZERO:
			away = Vector2.UP
		body.take_damage(25.0, away * 230.0, "Stinging coral")

func _process(delta: float) -> void:
	clock += delta
	queue_redraw()

func _draw() -> void:
	if bounds.position.y <= 150.0:
		draw_set_transform(Vector2(0, bounds.size.y), 0.0, Vector2(1, -1))
	draw_rect(Rect2(Vector2.ZERO, bounds.size), Color(0.5, 0.08, 0.13, 0.3))
	var count := maxi(1, int(bounds.size.x / 22.0))
	for i in range(count):
		var x := (i + 0.5) * bounds.size.x / count
		var sway := sin(clock * 2.5 + i * 1.7) * 3.0
		var height := bounds.size.y * (0.65 + (i % 3) * 0.12)
		var points := PackedVector2Array([
			Vector2(x - 9, bounds.size.y),
			Vector2(x + sway, bounds.size.y - height),
			Vector2(x + 9, bounds.size.y),
		])
		draw_colored_polygon(points, Color("d76576"))
		draw_line(Vector2(x, bounds.size.y - height + 5), Vector2(x + sway, bounds.size.y - height - 7), Color("ffd0b6"), 2.0, true)
	draw_rect(Rect2(Vector2.ZERO, bounds.size), Color(0.94, 0.24, 0.34, 0.65), false, 2.0)
