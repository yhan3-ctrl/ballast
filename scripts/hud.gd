extends Node2D
var world: Node2D
const INK := Color("dceddf")
const MUTED := Color("72969f")
const GOLD := Color("e8c38a")
var font: Font

func _ready() -> void:
	font = ThemeDB.fallback_font

func text(at: Vector2, value: String, size: int = 18, color: Color = INK) -> void:
	draw_string(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _draw() -> void:
	if not font:
		return
	if world.menu:
		draw_rect(Rect2(0, 0, 1280, 800), Color("071923"))
		for i in range(16):
			var y: float = 180 + i * 36
			draw_line(Vector2(760, y), Vector2(1280, y - 140), Color(0.12, 0.25, 0.29, 0.35), 1, true)
		for i in range(5):
			draw_arc(Vector2(975, 390), 70 + i * 48, PI * 0.3, PI * 1.8, 80, Color(0.28, 0.6, 0.6, 0.17), 1.5, true)
		text(Vector2(88, 130), "A SMALL JOURNEY INTO THE DEEP", 14, GOLD)
		text(Vector2(82, 272), "BALLAST", 96)
		text(Vector2(90, 329), "Every breath moves you. Every light changes things.", 21, MUTED)
		text(Vector2(90, 440), "Recover the eggs. Read the currents. Spend your air wisely.", 18)
		text(Vector2(90, 482), "W / S   Rise & sink      A / D   Swim      SPACE   Lantern", 17, MUTED)
		draw_rect(Rect2(88, 541, 340, 61), Color("183e47"))
		text(Vector2(112, 580), "ENTER   BEGIN THE DESCENT", 19)
		text(Vector2(90, 651), "T   Test dive / controls & light lab", 17, GOLD)
		text(Vector2(90, 744), "DEVELOPMENT PROTOTYPE  /  3 CHAPTERS  /  HUMAN PLAYTEST PENDING", 12, MUTED)
		return
	if not is_instance_valid(world.player):
		return
	var p = world.player
	draw_rect(Rect2(0, 0, 1280, 104), Color("071923"))
	draw_line(Vector2(34, 103), Vector2(1246, 103), Color("20444e"), 1)
	text(Vector2(35, 35), "BALLAST", 22)
	text(Vector2(35, 66), "TEST DIVE" if world.test_room else "%02d  /  %s" % [world.level_index + 1, world.title_names[world.level_index]], 13, GOLD)
	text(Vector2(330, 31), "BREATH", 12, MUTED)
	draw_rect(Rect2(330, 43, 280, 12), Color("1b3c46"))
	draw_rect(Rect2(330, 43, 280 * p.air / 100.0, 12), Color("ed9d82") if p.air < 25 else Color("91d7c0"))
	text(Vector2(625, 56), "%03d" % ceili(p.air), 22)
	text(Vector2(330, 80), "LOW AIR  /  SEEK A VENT" if p.air < 25 else "FUEL + LIFE  /  VENTS +40", 11, GOLD if p.air < 25 else MUTED)
	text(Vector2(780, 35), "LANTERN " + ("ON" if p.lantern_on else "OFF"), 14, GOLD if p.lantern_on else MUTED)
	text(Vector2(780, 63), "ANCHOR %02d" % (world.active_checkpoint + 1), 14)
	text(Vector2(1080, 36), "%02d:%02d" % [int(world.elapsed) / 60, int(world.elapsed) % 60], 22)
	text(Vector2(1080, 64), "RETRIES %02d" % world.deaths, 12, MUTED)
	draw_rect(Rect2(0, 758, 1280, 42), Color("071923"))
	text(Vector2(35, 784), "W/S  Rise / sink     A/D  Swim     SPACE  Light     R  Retry     ESC  Pause", 14, MUTED)
	text(Vector2(1090, 784), "F1  Diagnostics", 13, MUTED)
	if p.air < 25:
		for i in range(8):
			var opacity: float = (1.0 - p.air / 25.0) * (0.02 + i * 0.003)
			draw_rect(Rect2(i * 5, 105 + i * 5, 1280 - i * 10, 651 - i * 10), Color(0.64, 0.16, 0.13, opacity), false, 7)
	if world.notice_left > 0:
		var size: Vector2 = font.get_string_size(world.notice_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
		draw_rect(Rect2((1280 - size.x) / 2 - 22, 116, size.x + 44, 42), Color(0.025, 0.08, 0.11, 0.94))
		text(Vector2((1280 - size.x) / 2, 143), world.notice_text, 16, GOLD)
	if p.dying:
		text(Vector2(487, 395), "OUT OF BREATH", 32, GOLD)
		text(Vector2(476, 432), "Returning to your last anchor...", 18)
	if world.debug_visible:
		draw_rect(Rect2(30, 550, 365, 188), Color(0.01, 0.025, 0.04, 0.95))
		text(Vector2(46, 576), "DIAGNOSTICS / F1 TO HIDE", 13, GOLD)
		text(Vector2(46, 607), "Air %.2f   /   drain %.2f per second" % [p.air, p.drain_rate], 14)
		text(Vector2(46, 635), "Velocity (%+.1f, %+.1f)" % [p.velocity.x, p.velocity.y], 14)
		text(Vector2(46, 663), "Segment %.1fs   /   position %.0f, %.0f" % [world.segment_time, p.position.x, p.position.y], 14)
		text(Vector2(46, 693), "State: %s   /   observation %s" % ["drowning" if p.dying else "swimming", world.observation_complete], 14)
		text(Vector2(46, 719), "Prototype values; not a human playtest.", 12, MUTED)
	if world.paused:
		draw_rect(Rect2(0, 104, 1280, 654), Color("071923"))
		text(Vector2(480, 348), "DIVE PAUSED", 42)
		text(Vector2(450, 409), "Time, air and the ocean are stopped.", 18, MUTED)
		text(Vector2(478, 477), "ESC  Resume     Q  Main menu", 18, GOLD)
	if world.finished:
		draw_rect(Rect2(0, 104, 1280, 654), Color("071923"))
		text(Vector2(120, 248), "TEST DIVE COMPLETE" if world.test_room else "A LITTLE LIGHT, RETURNED.", 45)
		text(Vector2(123, 310), "The eggs are safe. Your next dive can be wiser.", 22, MUTED)
		text(Vector2(123, 388), "TIME  %02d:%02d       RETRIES  %d" % [int(world.elapsed) / 60, int(world.elapsed) % 60, world.deaths], 24, GOLD)
		text(Vector2(123, 467), "First-time play length and clarity still need human testing.", 17, MUTED)
		text(Vector2(123, 550), "ENTER  New journey     T  Test dive", 20)
