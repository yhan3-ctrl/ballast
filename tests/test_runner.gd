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
	hostile_glimmer._physics_process(0.01)
	check(world.player.dying, "hostile Glimmer contact starts the drowning state")
	check(world.player.death_reason == "Glimmer contact", "Glimmer death records a clear cause")
	check(hostile_glimmer.speed > 235.0, "Glimmer chase speed exceeds player top speed")
	check(ResourceLoader.exists("res://assets/audio/music.wav"), "original music asset is present")
	check(ResourceLoader.exists("res://assets/audio/pearl.wav"), "pearl event sound is present")
	print("RESULT: %d checks, %d failures" % [checks, failures])
	world.free()
	quit(1 if failures else 0)
