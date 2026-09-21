extends Node2D
var rect := Rect2()
var flow_direction := Vector2.RIGHT
var strength: float = 300.0
var kind: String = "DRIFT"
var clock: float = 0.0

func setup(bounds: Rect2, direction: Vector2, power: float, flow_kind: String) -> void:
	rect = bounds
	position = bounds.position
	flow_direction = direction.normalized()
	strength = power
	kind = flow_kind

func _ready() -> void:
	var mat := CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = mat
	z_index = 2

func contains_point(point: Vector2) -> bool:
	return rect.has_point(point)

func _process(delta: float) -> void:
	clock += delta
	queue_redraw()

func _draw() -> void:
	var tint := Color("55cbde") if kind != "RIP" else Color("ad98ee")
	draw_rect(Rect2(Vector2.ZERO, rect.size), Color(tint, 0.055))
	draw_rect(Rect2(Vector2.ZERO, rect.size), Color(tint, 0.22), false, 1.0)
	for row in range(int(rect.size.y / 42)):
		for col in range(int(rect.size.x / 80)):
			var base := Vector2(col * 80 + 20, row * 42 + 20)
			var p := base + flow_direction * fmod(clock * 28, 35)
			var tail: Vector2 = p - flow_direction * 13
			var normal := Vector2(-flow_direction.y, flow_direction.x)
			draw_line(tail, p, Color(tint, 0.42), 1.5, true)
			draw_line(p, p - flow_direction * 5 + normal * 4, Color(tint, 0.7), 1.5, true)
			draw_line(p, p - flow_direction * 5 - normal * 4, Color(tint, 0.7), 1.5, true)
	draw_string(ThemeDB.fallback_font, Vector2(12, 18), kind, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(tint, 0.7))
