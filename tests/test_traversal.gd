# Automated steering with actual physics, air, enemies and follower damage.
# Only pearl collection is disabled. This is not a human usability test.
extends SceneTree
var world
var grid: AStarGrid2D
var failures := 0
func _initialize() -> void: call_deferred("run")
func cell_for(point: Vector2) -> Vector2i:
	var cell := Vector2i((point / 20).round())
	var best := cell
	var distance := INF
	for x in range(cell.x-3, cell.x+4):
		for y in range(cell.y-3, cell.y+4):
			var c := Vector2i(x,y)
			if grid.is_in_boundsv(c) and not grid.is_point_solid(c) and (Vector2(c)*20).distance_to(point) < distance:
				distance = (Vector2(c)*20).distance_to(point)
				best = c
	return best
func route(to: Vector2) -> PackedVector2Array:
	return grid.get_point_path(cell_for(world.player.position), cell_for(to))
func reached(target: Vector2) -> bool:
	for baby in world.babies:
		if baby.origin.distance_to(target) < 10 and baby.rescued: return true
	for cp in world.checkpoints:
		if cp.position == target and cp.activated: return true
	for vent in world.vents:
		if vent.position == target and (vent.used or world.player.position.distance_to(target) < 43): return true
	return world.player.position.distance_to(target) < 24
func run() -> void:
	world = preload("res://scripts/world.gd").new()
	root.add_child(world)
	world.unlocked_chapter = 2
	for chapter in range(3):
		world.start_chapter(chapter)
		world.player.use_test_input = true
		for pearl in world.pearls:
			pearl.collision_layer = 0
			pearl.collision_mask = 0
		grid = AStarGrid2D.new()
		grid.region = Rect2i(1, 8, 238, 28)
		grid.cell_size = Vector2(20, 20)
		grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
		grid.update()
		for x in range(1, 239):
			for y in range(8, 36):
				var p := Vector2(x, y) * 20
				var blocked := false
				for wall in world.walls:
					if wall.grow(32).has_point(p): blocked = true
				for h in world.hazards:
					if h.bounds.grow(28).has_point(p): blocked = true
				for pulse in get_nodes_in_group("pulse_anemones"):
					if pulse.position.distance_to(p) < 86: blocked = true
				grid.set_point_solid(Vector2i(x, y), blocked)
		var targets: Array = []
		for baby in world.babies: targets.append(baby.position)
		for vent in world.vents: targets.append(vent.position)
		for cp in world.checkpoints:
			if cp.checkpoint_id > 0: targets.append(cp.position)
		targets.sort_custom(func(a,b): return a.x < b.x)
		targets.append(world.exit_point)
		var failed := false
		for target in targets:
			var path := route(target)
			if path.is_empty():
				print("NO ROUTE ", chapter+1, " ", target)
				failed = true
				break
			# Remove collinear points, preserving corners and legal wall clearance.
			var simplified := PackedVector2Array()
			for j in range(path.size()):
				if j == 0 or j == path.size()-1 or (path[j]-path[j-1]).normalized() != (path[j+1]-path[j]).normalized(): simplified.append(path[j])
			path = simplified
			var index := 0
			var frames := 0
			while not reached(target) and not world.finished:
				frames += 1
				if world.player.dying or world.respawn_pending:
					await physics_frame
					continue
				world.player.lantern_on = false
				if frames > 12000 or world.deaths > 12:
					print("TRAVERSAL STOP ", chapter+1, " target=",target," pos=",world.player.position," air=",world.player.air," cause=",world.player.death_reason)
					failed = true
					break
				if frames % 45 == 0:
					path = route(target)
					index = 0
					if path.is_empty():
						failed = true
						break
				while index < path.size()-1 and world.player.position.distance_to(path[index]) < 12: index += 1
				var steering: Vector2 = path[index]
				for c in world.creatures:
					if not c.harmless and c.state == c.State.WINDUP and c.position.distance_to(world.player.position) < 300:
						var line: Vector2 = (c.charge_end - c.position).normalized()
						var normal := Vector2(-line.y, line.x)
						var best_score := -INF
						for side in [-1, 1]:
							var candidate: Vector2 = Vector2(cell_for(world.player.position + normal * side * 90)) * 20
							var separation := absf((candidate - c.position).cross(line))
							if separation > best_score:
								best_score = separation
								steering = candidate
				var desired: Vector2 = ((steering - world.player.position) * 3.5).limit_length(150)
				var correction: Vector2 = desired - world.player.velocity
				world.player.test_input = Vector2(signf(correction.x) if absf(correction.x) > 22 else 0, signf(correction.y) if absf(correction.y) > 22 else 0)
				await physics_frame
			if failed: break
			print("ARRIVAL chapter=",chapter+1," target=",target," air=",snappedf(world.player.air,0.1))
		for i in range(4): await physics_frame
		var ok: bool = not failed and world.finished and world.collected_pearls == 0
		if not ok: failures += 1
		print("TRAVERSAL chapter=",chapter+1," success=",ok," seconds=",world.elapsed," retries=",world.deaths," pearls=",world.collected_pearls)
	world.free()
	quit(1 if failures else 0)
