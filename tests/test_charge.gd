extends SceneTree
var failures := 0
var checks := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS: " if ok else "FAIL: ", label)
func run() -> void:
	var world = preload("res://scripts/world.gd").new()
	root.add_child(world)
	world.unlocked_chapter = 2
	world.start_chapter(1)
	world.set_physics_process(false)
	for node in world.world_layer.get_children(): node.set_physics_process(false)
	await physics_frame
	await physics_frame
	var c = world.creatures[0]
	c.position = Vector2(720, 610)
	world.player.position = Vector2(850, 610)
	world.player.lantern_on = true
	c._physics_process(0.01)
	check(c.state == c.State.WINDUP, "light starts visible warning")
	var locked: Vector2 = c.charge_end
	var initial: Vector2 = c.position
	world.player.position = Vector2(850, 540)
	world.player.lantern_on = false
	c._physics_process(0.4)
	check(c.position == initial and c.charge_end == locked, "warning holds still and does not track dodging player")
	c._physics_process(0.81)
	check(c.state == c.State.DASH, "warning finishes before dash")
	c._physics_process(0.1)
	check(absf(c.position.y - initial.y) < 0.01 and c.charge_end == locked, "charge stays on locked line after target moves")
	for i in range(20): c._physics_process(0.05)
	check(c.state == c.State.RECOVER, "burst ends in recovery")
	initial = c.position
	world.player.position = c.position
	world.player.invulnerable_left = 0
	var air: float = world.player.air
	c._physics_process(0.2)
	check(c.position == initial and world.player.air == air, "recovery is stationary and harmless")
	c.reset_creature()
	check(c.state == c.State.DRIFT and c.action_left == 0, "retry cancels pending charge")
	c.position = Vector2(500, 380)
	c.begin_charge(Vector2(800, 380))
	check(c.charge_end.x < 540, "telegraphed charge ends before blocking rock")
	world.free()
	print("RESULT: ", checks, " charge checks, ", failures, " failures")
	quit(1 if failures else 0)
