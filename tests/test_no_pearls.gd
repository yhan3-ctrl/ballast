# Rule-level victory regression. Teleporting does NOT validate traversal or air budgets.
extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var world = preload("res://scripts/world.gd").new()
	root.add_child(world)
	world.unlocked_chapter = 2
	for chapter in range(3):
		world.start_chapter(chapter)
		world.set_physics_process(false)
		for actor in world.world_layer.get_children(): actor.set_physics_process(false)
		await physics_frame
		await physics_frame
		for baby in world.babies:
			world.player.position = baby.position
			world.try_rescue_baby(baby)
		world.player.position = world.exit_point
		world._physics_process(0.0)
		var ok: bool = world.finished and world.collected_pearls == 0 and world.pending_pearls.is_empty()
		if not ok: failures += 1
		print("PASS: " if ok else "FAIL: ", "chapter ", chapter + 1, " zero-pearl victory condition")
	world.free()
	print("RESULT: 3 no-pearl rule checks, ", failures, " failures")
	quit(1 if failures else 0)
