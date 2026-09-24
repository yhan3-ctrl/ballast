extends Node2D
func _ready() -> void:
	var mat := CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = mat
func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(0, -58), Vector2(-9, -44), Vector2(9, -44)]), Color("ff6b78"))
	draw_line(Vector2(0, -54), Vector2(0, -50), Color("351b30"), 2)
	draw_circle(Vector2(0, -47), 1, Color("351b30"))
