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
		# A local glow and gaze communicate intent without drawing the future path.
		var strength: float = 0.18 + 0.16 * (0.5 + 0.5 * sin(creature.clock * 18))
		draw_circle(Vector2.ZERO, 28, Color(1.0, 0.35, 0.22, strength))
		var gaze: Vector2 = creature.position.direction_to(creature.charge_end) * 3
		for side in [-1, 1]:
			var eye := Vector2(side * 8, -4)
			draw_circle(eye, 4, Color("ffe0ac"))
			draw_circle(eye + gaze, 2, Color("511c35"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, -58), Vector2(-9, -44), Vector2(9, -44)]), Color("ff6b78"))
	draw_line(Vector2(0, -54), Vector2(0, -50), Color("351b30"), 2)
	draw_circle(Vector2(0, -47), 1, Color("351b30"))
