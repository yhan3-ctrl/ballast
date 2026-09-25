extends Control
var world
const TITLES = ["THE REEF", "THE KELP DRIFT", "THE TRENCH"]
const GOALS = ["TOUCH 3 BABY FISH. They follow you. Bring them to the golden house to win.", "Rescue 3 babies along the upper and lower routes. Bring them to the golden house.", "Find 3 babies in the trench. Ride the rising current and bring them home."]
const TIPS = [
	"Touch babies: +25 air. Escort them home. Each has 2 health dots.\nSPACE lights the way and lures Glimmer. It does not block damage. Red pulses hurt: wait until dim.",
	"Glimmer marks a charge line. Move aside, then pass while it rests.\nUse light to draw attacks away from your followers. A baby losing both dots sends everyone to the anchor.",
	"Weave through high and low gates. Wait for anemones to stop flashing.\nLure Glimmer away from babies, then dodge its fixed charge. Coral costs you 25 air."
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
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("123740") if state == "normal" else Color("255764")
		if state == "disabled": style.bg_color = Color("172831")
		style.border_color = Color("77cbb6") if state != "disabled" else Color("34464c")
		style.set_border_width_all(2 if state in ["hover", "focus"] else 1)
		style.set_corner_radius_all(14)
		button.add_theme_stylebox_override(state, style)
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
		label_at("DIVE COMPLETE" if world.test_room else "ALL 3 BABIES ARE HOME!", Vector2(200, 170), Vector2(880, 70), 40)
		label_at("TIME  %02d:%02d    RETRIES  %d\n\nPEARLS  %d / %d    SCORE  %d" % [int(world.elapsed) / 60, int(world.elapsed) % 60, world.deaths, world.collected_pearls, world.total_pearls, world.score], Vector2(200, 285), Vector2(880, 180), 26)
		label_at("Practice complete. Try the chapter map." if world.test_room else (["Three little fish are safe. The kelp route is now open.", "Three more fish are safe. The trench route is now open.", "Home at last. Yuun and the little lights are safe."][world.level_index]), Vector2(200, 455), Vector2(880, 60))
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
		label_at(GOALS[chapter], Vector2(190, 300), Vector2(880, 80), 24)
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
	if world.finished or world.intro_chapter >= 0:
		draw_style_box(panel_style(), Rect2(150, 130, 980, 595))
	else:
		for i in range(3):
			var center := Vector2(260 + i * 360, 335 + i * 85)
			draw_circle(center, 105, [Color("123e4c"), Color("153b32"), Color("252940")][i])
			for j in range(5):
				var base := center + Vector2(-80 + j * 40, 38)
				draw_polyline(PackedVector2Array([base, base + Vector2(-8, -65 - j * 5), base + Vector2(6, -100 - j * 3)]), Color(0.2, 0.55, 0.5, 0.25), 5, true)
	if world.finished and not world.test_room:
		for i in range(3):
			var point := Vector2(300 + i * 85, 252)
			var color: Color = [Color("ffd28a"), Color("ffaaa5"), Color("bcaeff")][i]
			draw_circle(point, 16, color)
			draw_colored_polygon(PackedVector2Array([point + Vector2(-12, 0), point + Vector2(-30, -12), point + Vector2(-30, 12)]), color)
			draw_circle(point + Vector2(7, -4), 4, Color("102c39"))
	for i in range(12):
		draw_arc(Vector2(1050, 200), 150 + i * 45, 0, TAU, 100, Color(0.1, 0.35, 0.4, 0.2), 2)
	if world.menu and world.intro_chapter < 0:
		draw_polyline(PackedVector2Array([Vector2(260, 330), Vector2(620, 415), Vector2(980, 500)]), Color("497e83"), 5, true)

func panel_style() -> StyleBoxFlat:
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("102d39")
	panel.border_color = Color("416b71")
	panel.set_border_width_all(2)
	panel.set_corner_radius_all(24)
	return panel
