extends SceneTree
class Fish extends Node2D:
	var lantern_on := true
	var dying := false
	var air := 100.0
	func take_damage(amount: float, _force: Vector2, _reason: String) -> void: air -= amount
class Arena extends Node2D:
	var player: Fish
	var rescued_babies: Array = []
	func hurt_baby(_baby: Node2D, _source: String = "Hazard") -> void: pass
var failures := 0
var checks := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS: " if ok else "FAIL: ", label)
func run() -> void:
	var arena := Arena.new()
	root.add_child(arena)
	arena.player = Fish.new()
	arena.add_child(arena.player)
	var creature = preload("res://scripts/glimmer.gd").new()
	creature.setup(Rect2(0, 0, 600, 600), arena, 0)
	arena.add_child(creature)
	creature.set_physics_process(false)
	creature.position = Vector2(100, 200)
	arena.player.position = Vector2(230, 200)
	await physics_frame
	creature._physics_process(0.01)
	check(creature.state == creature.State.WINDUP, "light triggers windup")
	var endpoint: Vector2 = creature.charge_end
	arena.player.position = Vector2(230, 100)
	arena.player.lantern_on = false
	creature._physics_process(0.4)
	check(creature.position == Vector2(100, 200) and creature.charge_end == endpoint, "windup remains stationary and locks target")
	creature._physics_process(0.81)
	check(creature.state == creature.State.DASH, "dash only starts after warning")
	creature._physics_process(0.1)
	check(is_equal_approx(creature.position.y, 200) and creature.charge_end == endpoint, "dash does not turn after target moves")
	for i in range(20): creature._physics_process(0.05)
	check(creature.state == creature.State.RECOVER, "dash ends in recovery")
	arena.player.position = creature.position
	creature._physics_process(0.1)
	check(arena.player.air == 100, "recovery contact is harmless")
	creature.reset_creature()
	check(creature.state == creature.State.DRIFT and creature.action_left == 0, "reset cancels charge")
	var wall := StaticBody2D.new()
	wall.position = Vector2(180, 200)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(20, 180)
	shape.shape = rect
	wall.add_child(shape)
	arena.add_child(wall)
	await physics_frame
	await physics_frame
	creature.position = Vector2(100, 200)
	creature.begin_charge(Vector2(250, 200))
	check(creature.charge_end.x < 170, "wall clips telegraphed path")
	arena.free()
	print("RESULT: ", checks, " isolated charge checks, ", failures, " failures")
	quit(1 if failures else 0)
