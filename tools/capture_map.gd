extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	var world = load("res://scripts/world.gd").new()
	root.add_child(world)
	world.save_enabled = false
	world.unlocked_chapter = 0
	world.best_times = [0.0, 0.0, 0.0]
	world.chapter_menu.refresh()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/chapter-map.png")
	world.open_chapter(0)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/chapter-intro.png")
	quit()
