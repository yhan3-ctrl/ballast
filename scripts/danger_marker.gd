extends Node2D
func _ready() -> void:
	var mat := CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = mat
func _process(_delta: float) -> void:
	queue_redraw()
func _draw() -> void:
	var creature = get_parent()
	if creature.state == creature.State.WINDUP:
		var end: Vector2 = creature.charge_end - creature.position
		draw_line(Vector2.ZERO, end, Color("ffb36e"), 4, true)
		draw_circle(end, 12, Color("ffb36e"), false, 2, true)
		draw_string(ThemeDB.fallback_font, Vector2(-45, -70), "DODGE!", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("ffdc9e"))
	elif creature.state == creature.State.RECOVER:
		draw_string(ThemeDB.fallback_font, Vector2(-35, -70), "TIRED", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("91d7c0"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, -58), Vector2(-9, -44), Vector2(9, -44)]), Color("ff6b78"))
	draw_line(Vector2(0, -54), Vector2(0, -50), Color("351b30"), 2)
	draw_circle(Vector2(0, -47), 1, Color("351b30"))
