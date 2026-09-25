extends SceneTree

const Player = preload("res://scripts/player.gd")
const Vent = preload("res://scripts/vent.gd")
const World = preload("res://scripts/world.gd")

var failures := 0
var checks := 0

func _init() -> void:
	call_deferred("run_all")

func check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", label)
	else:
		failures += 1
		push_error("FAIL: " + label)

func near(actual: float, expected: float, tolerance: float = 0.001) -> bool:
	return absf(actual - expected) <= tolerance

func run_all() -> void:
	var player = Player.new()
	root.add_child(player)
	check(near(player.calculate_drain(Vector2.ZERO, false, false, false), 0.5), "passive drain")
	check(near(player.calculate_drain(Vector2.ZERO, true, true, false), 7.5), "W+S has zero directional input but charges both vertical costs")
	check(near(player.calculate_drain(Vector2.RIGHT, false, false, true), 4.9), "opposing current doubles thrust cost only")

	var vent = Vent.new()
	root.add_child(vent)
	check(not vent.try_collect(player), "full-air contact does not consume vent")
	check(not vent.used, "vent remains available at full air")
	player.air = 70.0
	check(vent.try_collect(player), "partially empty player consumes vent")
	check(near(player.air, 100.0), "vent refill caps at maximum and discards overflow")
	check(not vent.try_collect(player), "spent vent cannot be used twice")
	vent.reset_vent()
	player.air = 0.0
	player.dying = true
	check(not vent.try_collect(player), "drowning player cannot collect air")
	check(not vent.used, "drowning contact does not consume vent")
	player.free()
	vent.free()

	var world = World.new()
	root.add_child(world)
	world.test_room = true
	world.start_game()
	var checkpoint = world.checkpoints[1]
	world.player.air = 41.0
	check(world.activate_checkpoint(checkpoint), "new forward checkpoint activates")
	check(world.score == 820, "checkpoint converts remaining air into score before refill")
	check(near(world.player.air, 100.0), "first activation restores full air")
	world.player.air = 52.0
	check(not world.activate_checkpoint(checkpoint), "re-entering active checkpoint does not reactivate")
	check(near(world.player.air, 52.0), "re-entering checkpoint does not refill air")

	var segment_vent = null
	for candidate in world.vents:
		if candidate.segment == world.active_checkpoint:
			segment_vent = candidate
			break
	check(segment_vent != null, "test room has a vent in active segment")
	if segment_vent:
		segment_vent.used = true
	world.player.air = 8.0
	world.respawn()
	check(near(world.player.air, 100.0), "respawn restores full air")
	check(world.player.position == world.spawn_point, "respawn returns to active anchor")
	if segment_vent:
		check(not segment_vent.used, "respawn resets vents in active segment")

	check(world.currents.size() >= 2, "test room contains drift and rip current exercises")
	check(world.creatures.size() >= 1, "test room contains a Glimmer exercise")
	check(world.pearls.size() >= 12, "test room contains a visible reward trail")
	world.score = 0
	world.combo = 0
	world.combo_left = 0.0
	var first_pearl = world.pearls.filter(func(p): return p.segment == world.active_checkpoint)[0]
	first_pearl._touch(world.player)
	check(world.collected_pearls == 0, "unbanked pearl does not increment permanent collection count")
	check(world.score == 0, "unbanked pearl does not change permanent score")
	check(world.pending_pearls.size() == 1 and world.pending_score == 100, "first pearl enters at-risk segment rewards")
	check(world.pearl_tutorial_shown and world.pearl_tutorial_left > 0.0, "first pearl displays the anchor-banking tutorial")
	first_pearl._touch(world.player)
	check(world.pending_pearls.size() == 1, "pending pearl cannot be scored twice")
	world.respawn()
	check(world.pending_pearls.is_empty() and world.pending_score == 0, "restart clears at-risk pearl rewards")
	check(not first_pearl.collected and first_pearl.visible, "restart returns at-risk pearl to the room")
	check(world.score == 0 and world.collected_pearls == 0, "restart cannot combine pearl and efficiency rewards")
	first_pearl._touch(world.player)
	world.bank_segment_rewards()
	check(world.score == 100 and world.collected_pearls == 1, "banking commits pending pearl and score")
	world.respawn()
	check(first_pearl.collected and not first_pearl.visible, "banked pearl persists through later death")
	check(world.score == 100 and world.collected_pearls == 1, "banked pearl score persists through later death")

	var glimmer = world.creatures[0]
	glimmer.position += Vector2(70, 30)
	glimmer.state = glimmer.State.ATTRACTED
	glimmer.saw_attraction = true
	world.respawn()
	check(glimmer.position == glimmer.home, "respawn resets current-segment Glimmer position")
	check(glimmer.state == glimmer.State.DRIFT, "respawn resets current-segment Glimmer state")

	var rip = null
	for flow in world.currents:
		if flow.kind == "RIP":
			rip = flow
			break
	check(rip != null, "test room includes a rip current")
	if rip:
		world.player.global_position = rip.rect.get_center()
		world.player.velocity = Vector2.ZERO
		world.player.use_test_input = true
		world.player.test_input = -rip.flow_direction
		world.player._physics_process(1.0 / 60.0)
		check(world.player.velocity.dot(rip.flow_direction) >= 44.9, "rip current cannot be overcome head-on")
		world.player.use_test_input = false

	var time_before_pause: float = world.elapsed
	world.set_paused(true)
	world._physics_process(2.0)
	check(world.get_tree().paused, "pause stops the scene tree")
	check(near(world.elapsed, time_before_pause), "pause freezes the run timer")
	world.set_paused(false)
	check(world.hazards.size() >= 1, "test room contains visible stinging coral")
	world.player.reset_at(world.spawn_point)
	world.player.invulnerable_left = 0.0
	world.hazards[0]._touch(world.player)
	check(near(world.player.air, 75.0), "coral contact removes 25 air")
	world.player.air = 20.0
	world.player.invulnerable_left = 0.0
	world.hazards[0]._touch(world.player)
	check(world.player.dying, "lethal coral damage starts the drowning state")
	check(world.player.death_reason == "Stinging coral", "hazard death records a clear cause")
	world.player.reset_at(world.spawn_point)
	var hostile_glimmer = world.creatures.filter(func(c): return not c.harmless)[0]
	world.player.invulnerable_left = 0.0
	hostile_glimmer.position = world.player.position
	hostile_glimmer.state = hostile_glimmer.State.DASH
	hostile_glimmer.charge_end = hostile_glimmer.position + Vector2(60, 0)
	hostile_glimmer._physics_process(0.01)
	check(not world.player.dying and world.player.air == 70, "charge deals 30 air rather than instant death")
	check(world.player.invulnerable_left > 0, "charge grants player hit grace")
	check(hostile_glimmer.speed > 235.0, "burst speed exceeds player speed only during a fixed charge")
	check(ResourceLoader.exists("res://assets/audio/music.wav"), "original music asset is present")
	check(ResourceLoader.exists("res://assets/audio/pearl.wav"), "pearl event sound is present")
	# Synchronize the physics server before testing actual walls and ray queries.
	world.set_physics_process(false)
	world.player.set_physics_process(false)
	for creature in world.creatures:
		creature.set_physics_process(false)
	world.player.reset_at(Vector2(700, 300))
	glimmer.position = Vector2(550, 300)
	await physics_frame
	await physics_frame
	check(not glimmer.has_sight_to(world.player.global_position), "real wall blocks Glimmer line of sight")
	world.player.lantern_on = true
	glimmer.state = glimmer.State.DRIFT
	glimmer._physics_process(0.1)
	check(glimmer.state != glimmer.State.ATTRACTED, "lantern behind wall cannot attract Glimmer")
	glimmer.position = Vector2(550, 300)
	glimmer.move_and_collide(Vector2(200, 0))
	check(glimmer.position.x <= 560.1, "Glimmer collision body cannot cross real wall")
	glimmer.reset_creature()
	world.observation_complete = false
	glimmer.position = glimmer.home + Vector2(50, 0)
	glimmer.state = glimmer.State.ATTRACTED
	glimmer.saw_attraction = true
	world.player.lantern_on = false
	glimmer._physics_process(0.01)
	check(not world.observation_complete, "observation is not complete when return merely begins")
	for frame in range(90):
		glimmer._physics_process(1.0 / 60.0)
	check(world.observation_complete, "observation completes after creature reaches home")
	world.player.reset_at(world.exit_point)
	world.player.air = 37.0
	world.segment_time = 23.5
	var score_before_exit: int = world.score
	world._physics_process(0.0)
	check(world.score == score_before_exit + 740, "exit awards the same air bonus as an anchor")
	check(near(world.last_arrival.air, 37.0) and near(world.last_arrival.seconds, 23.5), "arrival telemetry preserves pre-refill air and segment duration")
	world._physics_process(0.0)
	check(world.score == score_before_exit + 740, "exit cannot award the bonus twice")
	check(world.level_times.size() == 1, "final level duration is recorded")
	world.finished = false
	world.running = true
	world._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(world.paused, "losing application focus pauses an active dive")
	world.set_paused(false)
	world.test_room = false
	for level in range(3):
		world.level_index = level
		world.build_level()
		world.world_layer.process_mode = Node.PROCESS_MODE_DISABLED
		await physics_frame
		await physics_frame
		var clear_homes := true
		for creature in world.creatures:
			var query := PhysicsShapeQueryParameters2D.new()
			var circle := CircleShape2D.new()
			circle.radius = 20.0
			query.shape = circle
			query.transform = Transform2D(0, creature.global_position)
			query.collision_mask = 1
			if not creature.get_world_2d().direct_space_state.intersect_shape(query).is_empty():
				clear_homes = false
		check(clear_homes, "chapter %d Glimmer homes do not overlap walls" % (level + 1))
	world.to_menu()
	world.unlocked_chapter = 0
	check(not world.open_chapter(1), "locked chapter cannot open its introduction")
	check(not world.start_chapter(2), "locked chapter cannot launch through API")
	check(world.open_chapter(0), "unlocked chapter opens introduction")
	var intro_time: float = world.elapsed
	world._physics_process(10.0)
	check(near(world.elapsed, intro_time) and world.player == null, "introduction consumes no time or air")
	world.start_chapter(0)
	check(world.level_index == 0 and near(world.elapsed, 0.0), "challenge starts its own fresh timer")
	world.elapsed = 45.0
	world.respawn()
	check(near(world.elapsed, 45.0), "checkpoint retry retains chapter elapsed time")
	world.observation_complete = true
	for baby in world.babies:
		baby.rescued = true
		world.rescued_babies.append(baby)
	world.player.position = world.exit_point
	world._physics_process(0.0)
	check(world.finished and world.level_index == 0 and not world.running, "chapter exit waits at settlement instead of auto-advancing")
	check(world.unlocked_chapter == 1 and near(world.best_times[0], 45.0), "first completion unlocks next chapter and records time")
	world._physics_process(12.0)
	check(near(world.elapsed, 45.0), "settlement freezes chapter time")
	world.open_chapter(0)
	world.start_chapter(0)
	check(world.score == 0 and world.deaths == 0 and near(world.elapsed, 0.0), "whole-chapter replay resets attempt statistics")
	world.elapsed = 60.0
	world.observation_complete = true
	for baby in world.babies:
		baby.rescued = true
		world.rescued_babies.append(baby)
	world.player.position = world.exit_point
	world._physics_process(0.0)
	check(near(world.best_times[0], 45.0), "slower replay preserves personal best")
	world.open_chapter(1)
	world.start_chapter(1)
	world.elapsed = 52.0
	for baby in world.babies:
		baby.rescued = true
		world.rescued_babies.append(baby)
	world.player.position = world.exit_point
	world._physics_process(0.0)
	check(world.unlocked_chapter == 2 and near(world.best_times[1], 52.0), "chapter two completion unlocks chapter three")
	world.save_path_override = "res://logs/test-progress.cfg"
	world.save_enabled = true
	world.save_progress()
	world.unlocked_chapter = 0
	world.best_times = [0.0, 0.0, 0.0]
	world.load_progress()
	check(world.unlocked_chapter == 2 and near(world.best_times[0], 45.0), "progress survives save/load using isolated test file")
	world.save_enabled = false
	DirAccess.remove_absolute(ProjectSettings.globalize_path(world.save_path_override))
	print("RESULT: %d checks, %d failures" % [checks, failures])
	world.free()
	quit(1 if failures else 0)
