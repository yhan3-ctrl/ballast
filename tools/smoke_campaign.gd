extends SceneTree
func _initialize() -> void:
	call_deferred("run_check")
func run_check() -> void:
	root.size = Vector2i(1280, 800)
	var source = load("res://scripts/world.gd")
	if source == null:
		quit(1)
		return
	var world = source.new()
	root.add_child(world)
	world.save_enabled = false
	for level in range(3):
		world.start_game(level)
		for frame in range(120):
			await physics_frame
		if world.player == null or world.babies.size() != 3:
			quit(2)
			return
		print("CAMPAIGN_SMOKE_PASS level=", level + 1)
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			var picture = root.get_texture().get_image()
			var target = OS.get_environment("BALLAST_SMOKE_OUTPUT").path_join("level-%d.png" % (level + 1))
			if picture == null or picture.save_png(target) != OK:
				quit(3)
				return
	quit(0)
