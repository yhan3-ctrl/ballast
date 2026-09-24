extends Node2D
var world: Node2D
var clock: float = 0.0
var hit_cooldown: float = 0.0
func _ready() -> void:
	add_to_group("pulse_anemones")
	var mat := CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = mat
func active() -> bool:
	return fmod(clock, 5.0) >= 3.5
func _physics_process(delta: float) -> void:
	if not world.running or world.paused or world.player.dying or world.respawn_pending:
		return
	clock += delta
	hit_cooldown = maxf(0, hit_cooldown - delta)
	if active():
		if position.distance_to(world.player.position) < 78 and world.sight_clear(position, world.player.position) and hit_cooldown <= 0:
			world.player.take_damage(20, position.direction_to(world.player.position) * 170, "Anemone pulse")
			hit_cooldown = 1.5
		for baby in world.rescued_babies:
			if position.distance_to(baby.position) < 72 and world.sight_clear(position, baby.position):
				world.hurt_baby(baby)
	queue_redraw()
func _draw() -> void:
	var phase := fmod(clock, 5.0)
	var color := Color("ff647f") if active() else Color("e7bb76") if phase >= 2.5 else Color("668e9a")
	draw_circle(Vector2.ZERO, 17, color)
	for i in range(10):
		var direction := Vector2.from_angle(i * TAU / 10)
		draw_line(direction * 18, direction * (30 + sin(clock * 4 + i) * 5), color, 3, true)
	draw_arc(Vector2.ZERO, 72, 0, TAU, 48, Color(color, 0.9 if active() else 0.25), 3 if active() else 1, true)
	if active(): draw_circle(Vector2.ZERO, 72, Color(color, 0.13))
	draw_string(ThemeDB.fallback_font, Vector2(-45, -85), "PULSE!" if active() else "WAIT..." if phase >= 2.5 else "PASS NOW", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, color)
