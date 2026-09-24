extends SceneTree
const World = preload("res://scripts/world.gd")
var failures := 0
var checks := 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ", label)
	if not ok: failures += 1
func run() -> void:
	var world = World.new()
	root.add_child(world)
	world.start_chapter(0)
	world.set_physics_process(false)
	for actor in world.world_layer.get_children():
		actor.set_physics_process(false)
	await physics_frame
	await physics_frame
	check(world.babies.size() == 3, "chapter starts with three recognizable babies")
	check(world.observation_gate == null, "old invisible observation prerequisite has no gate")
	world.player.position = world.exit_point
	world._physics_process(0.0)
	check(not world.finished, "reaching home without three babies does not win")
	check(world.home_hint_left > 0 and world.notice_text.contains("3"), "home explains how many babies are missing")
	check(world.objective_position() == world.babies[2].position, "objective points to nearest missing baby, including when backtracking")
	var baby = world.babies[0]
	world.player.position = baby.position
	world.player.air = 40.0
	check(world.try_rescue_baby(baby), "touching baby rescues it")
	check(world.player.air == 65.0 and world.rescue_air_gain == 25, "first rescue rewards 25 air")
	check(not world.try_rescue_baby(baby) and world.player.air == 65, "repeat touch cannot farm air")
	world.respawn()
	check(world.rescued_babies.size() == 1 and baby.rescued, "rescued baby survives checkpoint retry")
	check(baby.position == world.spawn_point, "rescued baby reunites at respawn")
	baby = world.babies[1]
	world.player.position = baby.position
	world.player.dying = true
	check(not world.try_rescue_baby(baby), "dying player cannot rescue")
	world.player.dying = false
	world.set_paused(true)
	check(not world.try_rescue_baby(baby), "paused game cannot rescue")
	world.set_paused(false)
	world.player.air = 95
	check(world.try_rescue_baby(baby) and world.player.air == 100 and world.rescue_air_gain == 5, "rescue caps air and reports actual gain")
	baby = world.babies[2]
	world.player.position = baby.position
	check(world.try_rescue_baby(baby), "full-air player can still rescue last baby")
	check(world.objective_position() == world.exit_point, "all rescued switches objective to home")
	world.player.position = world.exit_point
	world.observation_complete = false
	world._physics_process(0.0)
	check(world.finished, "bringing babies home wins without water-creature gate")
	var saved_score: int = world.score
	world._physics_process(1.0)
	check(world.score == saved_score, "home settlement cannot duplicate")
	world.start_chapter(0)
	world.set_physics_process(false)
	for actor in world.world_layer.get_children():
		actor.set_physics_process(false)
	await physics_frame
	await physics_frame
	check(world.rescued_babies.is_empty(), "whole-chapter replay starts a fresh rescue")
	world.add_wall(Rect2(460, 420, 10, 60))
	baby = world.babies[0]
	baby.set_process(false)
	baby.position = Vector2(480, 450)
	world.player.position = Vector2(445, 450)
	await physics_frame
	await physics_frame
	check(not world.try_rescue_baby(baby), "nearby baby cannot be rescued through a solid wall")
	world.player.position = world.currents[0].rect.get_center()
	world.player.velocity = world.currents[0].flow_direction * 140
	world.player.use_test_input = true
	world.player.test_input = Vector2.ZERO
	world.player._physics_process(1.0 / 60.0)
	check(world.player.flow_gliding and world.player.drain_rate == 0.5, "hands-off flow visibly signals baseline-only drain")
	world.player.test_input = Vector2.RIGHT
	world.player._physics_process(1.0 / 60.0)
	check(not world.player.flow_gliding, "active thrust stops free-glide feedback")
	print("RESULT: %d rescue checks, %d failures" % [checks, failures])
	world.free()
	quit(1 if failures else 0)
