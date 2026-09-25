extends SceneTree
const World = preload("res://scripts/world.gd")
var checks := 0
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(value: bool, label: String) -> void:
	checks += 1
	if not value: failures += 1
	print("PASS: " if value else "FAIL: ", label)
func run() -> void:
	var world = World.new()
	root.add_child(world)
	world.start_chapter(0)
	world.set_physics_process(false)
	for actor in world.world_layer.get_children(): actor.set_physics_process(false)
	await physics_frame
	await physics_frame
	var baby = world.babies[0]
	world.player.position = baby.position
	world.try_rescue_baby(baby)
	check(baby.health == 2, "rescued baby has two health")
	check(world.hurt_baby(baby) and baby.health == 1, "unprotected baby loses one health")
	check(not world.hurt_baby(baby) and baby.health == 1, "repeated contact during grace does not stack")
	baby.hurt_cooldown = 0
	world.player.lantern_on = true
	check(world.hurt_baby(baby) and baby.health == 0, "light does not grant immunity")
	await process_frame
	baby.health = 1
	baby.hurt_cooldown = 0
	world.player.lantern_on = false
	world.set_paused(true)
	check(not world.hurt_baby(baby), "pause blocks baby damage")
	world.set_paused(false)
	world.player.dying = true
	check(not world.hurt_baby(baby), "dying player cannot trigger second loss")
	world.player.dying = false
	check(world.hurt_baby(baby) and world.respawn_pending, "second hit requests family recovery")
	await process_frame
	check(baby.health == 2 and baby.rescued and baby.position == world.spawn_point, "retry restores health and rescue at anchor")
	var pulse = get_nodes_in_group("pulse_anemones")[0]
	check(pulse.clock == 0 and not pulse.active(), "retry starts pulse in safe phase")
	pulse.clock = 3.0
	check(not pulse.active(), "warning phase does not damage")
	pulse.clock = 3.6
	check(pulse.active(), "pulse active after warning")
	pulse.clock = 5.1
	check(not pulse.active(), "pulse returns to safe interval")
	world.free()
	print("RESULT: ", checks, " escort checks, ", failures, " failures")
	quit(1 if failures else 0)
