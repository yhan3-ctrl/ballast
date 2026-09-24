extends Node2D
var health: int = 2
var hurt_cooldown: float = 0.0
var protected: bool = false
var rescued: bool = false
var clock: float = 0.0
var number: int = 1
var tint := Color("ffd28a")
var origin := Vector2.ZERO
var facing: float = 1.0

func _ready() -> void:
	origin = position
	var mat := CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = mat
	z_index = 8

func _process(delta: float) -> void:
	clock += delta
	if not rescued:
		position = origin + Vector2(0, sin(clock * 2.5) * 7)
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0, Vector2(facing, 1))
	var wag := sin(clock * 7) * 5
	draw_circle(Vector2.ZERO, 39 if not rescued else 22, Color(tint, 0.10))
	draw_colored_polygon(PackedVector2Array([Vector2(-13, 0), Vector2(-30, -13 + wag), Vector2(-30, 13 + wag)]), tint.darkened(0.15))
	draw_set_transform(Vector2.ZERO, 0, Vector2(1.25 * facing, 0.85))
	draw_circle(Vector2.ZERO, 17, tint)
	draw_set_transform(Vector2.ZERO, 0, Vector2(facing, 1))
	draw_circle(Vector2(10, -5), 6, Color("102c39"))
	draw_circle(Vector2(12, -7), 2, Color.WHITE)
	draw_arc(Vector2(10, 3), 5, 0.1, 2.1, 10, Color("614b48"), 1.5, true)
	draw_set_transform(Vector2.ZERO)
	if rescued:
		for i in range(2):
			draw_circle(Vector2(-7 + i * 14, -30), 4, Color("ff8c9c") if i < health else Color("493340"))
		if protected:
			draw_arc(Vector2.ZERO, 29, 0, TAU, 32, Color("ffe6a3"), 2, true)
		elif hurt_cooldown > 0:
			draw_arc(Vector2.ZERO, 27, 0, TAU, 32, Color("ff6b78"), 2, true)
	if not rescued:
		draw_line(Vector2(0, -43), Vector2(0, -32), tint, 3, true)
		draw_circle(Vector2(0, -26), 2, tint)
		draw_string(ThemeDB.fallback_font, Vector2(-48, -57), "BABY %d / TOUCH" % number, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
