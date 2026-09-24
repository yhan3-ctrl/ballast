extends SceneTree
const World = preload("res://scripts/world.gd")
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func clear_at(world, point: Vector2) -> bool:
	for wall in world.walls:
		if wall.grow(18).has_point(point):
			return false
	return true
func reachable(world, start: Vector2, target: Vector2) -> bool:
	var origin := Vector2i(roundi(start.x / 20), roundi(start.y / 20))
	var queue: Array[Vector2i] = [origin]
	var seen := {origin: true}
	var cursor := 0
	while cursor < queue.size():
		var cell := queue[cursor]
		cursor += 1
		if (Vector2(cell) * 20).distance_to(target) < 32:
			return true
		for direction in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
			var next: Vector2i = cell + direction
			if next.x < 1 or next.x > 239 or next.y < 8 or next.y > 35 or seen.has(next):
				continue
			if clear_at(world, Vector2(next) * 20):
				seen[next] = true
				queue.append(next)
	return false
func run() -> void:
	var world = World.new()
	root.add_child(world)
	world.unlocked_chapter = 2
	for chapter in range(3):
		world.start_chapter(chapter)
		world.set_physics_process(false)
		world.world_layer.process_mode = Node.PROCESS_MODE_DISABLED
		# The L1 observation gate is deliberately omitted by world.walls.
		# This verifies static clearance after that gate is opened, not puzzle completion.
		var points: Array = []
		for cp in world.checkpoints: points.append(cp.position)
		for vent in world.vents: points.append(vent.position)
		for baby in world.babies: points.append(baby.position)
		points.append(world.exit_point)
		var clear := true
		for point in points:
			if not clear_at(world, point) or not reachable(world, world.spawn_point, point):
				clear = false
				print("UNREACHABLE ", chapter + 1, " ", point)
		if not clear: failures += 1
		print("CHAPTER ", chapter + 1, " static anchor/vent/exit clearance: ", clear)
	world.free()
	quit(1 if failures else 0)
