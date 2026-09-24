extends Node2D
var world
var clock: float = 0.0
func _ready() -> void:
	var mat := CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = mat
	z_index = 6
func _process(delta: float) -> void:
	clock += delta
	queue_redraw()
func _draw() -> void:
	var ready: bool = world.test_room or world.rescued_babies.size() == 3
	var gold := Color("ffe2a0")
	draw_circle(Vector2.ZERO, 79 + sin(clock * 2) * 4, Color(gold, 0.15 if ready else 0.06))
	draw_rect(Rect2(-45, -20, 90, 70), Color("94663e"))
	draw_rect(Rect2(-45, -20, 90, 70), gold, false, 3)
	draw_colored_polygon(PackedVector2Array([Vector2(-65, -20), Vector2(0, -76), Vector2(65, -20)]), gold)
	draw_rect(Rect2(-19, 7, 38, 43), Color("193b43"))
	draw_circle(Vector2(-29, -1), 7, gold)
	draw_circle(Vector2(29, -1), 7, gold)
	var label := "HOME / COME IN!" if ready else "HOME / FIND 3 BABIES"
	draw_string(ThemeDB.fallback_font, Vector2(-88, 82), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, gold)
