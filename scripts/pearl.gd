extends Area2D

var world: Node2D
var segment: int = 0
var collected: bool = false
var clock: float = 0.0
var base_y: float = 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	base_y = position.y
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 23.0
	collision.shape = shape
	add_child(collision)
	body_entered.connect(_touch)
	var mat := CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = mat

func _touch(body: Node) -> void:
	if collected or not is_instance_valid(world) or body != world.player:
		return
	collected = true
	monitoring = false
	visible = false
	world.collect_pearl(self)

func _process(delta: float) -> void:
	clock += delta
	position.y = base_y + sin(clock * 2.2 + position.x * 0.01) * 7.0
	queue_redraw()

func _draw() -> void:
	var pulse := 1.0 + sin(clock * 4.0) * 0.08
	draw_circle(Vector2.ZERO, 26.0 * pulse, Color(0.52, 0.92, 0.86, 0.08))
	draw_circle(Vector2.ZERO, 14.0 * pulse, Color("e9d69d"))
	draw_circle(Vector2(-4, -5), 4.5, Color("fff8d7"))
	draw_arc(Vector2.ZERO, 18.0 * pulse, 0.0, TAU, 24, Color(0.72, 0.98, 0.91, 0.65), 2.0, true)

