extends Control
var world
const TITLES = ["THE REEF", "THE KELP DRIFT", "THE TRENCH"]
const GOALS = ["Reach the reef exit. Discover how light changes Glimmer's behaviour.", "Cross the kelp. Choose between a current-assisted route and pearl detours.", "Reach the deep-water exit. Combine light, currents and careful air use."]
const TIPS = [
	"Vents restore 40 air. Stinging coral costs 25 air.\nPearls are only saved at a new anchor or the exit; retries lose unbanked pearls.",
	"Glide with the current to save air; swimming against it costs more.\nLight attracts Glimmer. Darkness makes it return, but contact is still fatal.",
	"Use light to draw Glimmer away, then turn it off before passing.\nAir also drains while idle: plan at the pause screen if you need time."
]
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func label_at(value: String, pos: Vector2, size: Vector2, font_size: int = 22) -> void:
	var label := Label.new()
	label.text = value
	label.position = pos
	label.size = size
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)

func button_at(value: String, pos: Vector2, callback: Callable, locked: bool = false) -> void:
	var button := Button.new()
	button.text = value
	button.position = pos
	button.size = Vector2(260, 64)
	button.disabled = locked
	button.add_theme_font_size_override("font_size", 20)
	button.pressed.connect(callback)
	add_child(button)

func refresh() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	visible = world.menu or world.finished
	queue_redraw()
	if not visible:
		return
	if world.finished:
		label_at("DIVE COMPLETE" if world.test_room else "CHAPTER %d COMPLETE" % (world.level_index + 1), Vector2(200, 170), Vector2(880, 70), 40)
		label_at("TIME  %02d:%02d    RETRIES  %d\n\nPEARLS  %d / %d    SCORE  %d" % [int(world.elapsed) / 60, int(world.elapsed) % 60, world.deaths, world.collected_pearls, world.total_pearls, world.score], Vector2(200, 285), Vector2(880, 180), 26)
		label_at("The next chapter is unlocked." if not world.test_room and world.level_index < 2 else "Journey complete. Replay any unlocked chapter from the map.", Vector2(200, 455), Vector2(880, 60))
		button_at("MAP", Vector2(200, 560), world.to_menu)
		button_at("PLAY AGAIN", Vector2(510, 560), func():
			if world.test_room:
				world.start_game()
			else:
				world.open_chapter(world.level_index))
		if not world.test_room and world.level_index < 2:
			button_at("NEXT CHAPTER", Vector2(820, 560), func(): world.open_chapter(world.level_index + 1))
	elif world.intro_chapter >= 0:
		var chapter: int = world.intro_chapter
		label_at("%02d / %s" % [chapter + 1, TITLES[chapter]], Vector2(190, 175), Vector2(900, 65), 38)
		label_at(GOALS[chapter], Vector2(190, 275), Vector2(880, 80), 25)
		label_at("TIPS\n" + TIPS[chapter], Vector2(190, 385), Vector2(880, 145), 21)
		label_at("WASD  Swim     SPACE  Lantern     R  Retry     ESC  Pause", Vector2(190, 550), Vector2(900, 35), 18)
		button_at("BACK TO MAP", Vector2(190, 620), world.to_menu)
		button_at("START CHALLENGE", Vector2(820, 620), func(): world.start_chapter(chapter))
	else:
		label_at("BALLAST", Vector2(90, 75), Vector2(800, 90), 64)
		label_at("YUUN THE JADEFIN   /   CHOOSE YOUR DIVE", Vector2(95, 170), Vector2(950, 40), 21)
		for i in range(3):
			var index := i
			var pos := Vector2(130 + i * 360, 300 + i * 85)
			button_at(("LOCKED  " if i > world.unlocked_chapter else "DIVE  ") + str(i + 1), pos, func(): world.open_chapter(index), i > world.unlocked_chapter)
			label_at(TITLES[i], pos + Vector2(0, 80), Vector2(290, 40), 21)
			var best: float = world.best_times[i]
			if best > 0:
				label_at("BEST %02d:%02d" % [int(best) / 60, int(best) % 60], pos + Vector2(0, 118), Vector2(290, 35), 18)
		label_at("Click a dive. Complete it to unlock the next.\nM  Music on/off     N  Effects on/off", Vector2(100, 665), Vector2(1050, 80), 19)
		if world.save_warning:
			label_at(world.save_warning, Vector2(100, 750), Vector2(1100, 40), 15)

func _draw() -> void:
	if not visible:
		return
	draw_rect(Rect2(0, 0, 1280, 800), Color("071923"))
	for i in range(12):
		draw_arc(Vector2(1050, 200), 150 + i * 45, 0, TAU, 100, Color(0.1, 0.35, 0.4, 0.2), 2)
	if world.menu and world.intro_chapter < 0:
		draw_polyline(PackedVector2Array([Vector2(260, 330), Vector2(620, 415), Vector2(980, 500)]), Color("497e83"), 5, true)
