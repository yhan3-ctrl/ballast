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
	if world.menu or world.finished:
		return
	if not is_instance_valid(world.player):
		return
	var p = world.player
	draw_rect(Rect2(0, 0, 1280, 104), Color("071923"))
	draw_line(Vector2(34, 103), Vector2(1246, 103), Color("20444e"), 1)
	text(Vector2(35, 35), "YUUN / JADEFIN", 19)
	text(Vector2(35, 66), "TEST DIVE" if world.test_room else "%02d  /  %s" % [world.level_index + 1, world.title_names[world.level_index]], 13, GOLD)
	text(Vector2(330, 31), "BREATH", 12, MUTED)
	draw_rect(Rect2(330, 43, 280, 12), Color("1b3c46"))
	draw_rect(Rect2(330, 43, 280 * p.air / 100.0, 12), Color("ed9d82") if p.air < 25 else Color("91d7c0"))
	text(Vector2(625, 56), "%03d" % ceili(p.air), 22)
	text(Vector2(330, 80), "LOW AIR  /  SEEK A VENT" if p.air < 25 else "FUEL + LIFE  /  VENTS +40", 11, GOLD if p.air < 25 else MUTED)
	text(Vector2(780, 35), "LANTERN " + ("ON" if p.lantern_on else "OFF"), 14, GOLD if p.lantern_on else MUTED)
	text(Vector2(780, 63), "ANCHOR %02d" % (world.active_checkpoint + 1), 14)
	text(Vector2(1080, 64), "RETRIES %02d" % world.deaths, 12, MUTED)
	text(Vector2(780, 87), "BANKED %02d  AT RISK %02d  SCORE %05d (+%d)" % [world.collected_pearls, world.pending_pearls.size(), world.score, world.pending_score], 11, GOLD)
	draw_rect(Rect2(0, 758, 1280, 42), Color("071923"))
	text(Vector2(35, 784), "W/S  Rise / sink     A/D  Swim     SPACE  Light     R  Retry     ESC  Pause", 14, MUTED)
	text(Vector2(1090, 784), "F1  Diagnostics", 13, MUTED)
	if not world.test_room:
		var count: int = world.rescued_babies.size()
		text(Vector2(35, 135), "BABIES %d/3  /  %s" % [count, "BRING THEM HOME!" if count == 3 else "TOUCH A BABY TO RESCUE IT"], 19, GOLD)
		var direction: Vector2 = (world.objective_position() - p.position).normalized()
		var origin := Vector2(1180, 132)
		draw_line(origin - direction * 14, origin + direction * 14, GOLD, 3, true)
		draw_line(origin + direction * 14, origin + direction.rotated(2.5) * 10, GOLD, 3, true)
		draw_line(origin + direction * 14, origin + direction.rotated(-2.5) * 10, GOLD, 3, true)
		text(Vector2(1010, 140), "HOME" if count == 3 else "NEXT BABY", 14, GOLD)
	if p.flow_gliding:
		text(Vector2(380, 730), "FLOW GLIDE / SAVING AIR / %.1f AIR PER SECOND" % p.drain_rate, 17, Color("a5fff1"))
	if world.rescue_notice_left > 0:
		var reward := "+%d AIR" % roundi(world.rescue_air_gain) if world.rescue_air_gain > 0 else "A NEW FRIEND!"
		text(Vector2(340, 265), "BABY RESCUED!  %s  /  %d OF 3" % [reward, world.rescued_babies.size()], 24, GOLD)
	if world.combo > 1 and world.combo_left > 0:
		var scale := 1.0 + minf(world.combo_left, 0.25) * 0.8
		text(Vector2(1050, 145), "FLOW CHAIN  x%d" % world.combo, int(21 * scale), GOLD)
	if world.tutorial_active and not world.paused:
		draw_rect(Rect2(395, 555, 490, 128), Color(0.02, 0.075, 0.095, 0.94))
		text(Vector2(459, 591), "HOLD A KEY TO SWIM", 24, GOLD)
		text(Vector2(455, 625), "W  rise     S  sink     A  left     D  right", 17)
		text(Vector2(466, 655), "Release the keys to glide and save air.", 14, MUTED)
	if p.air < 25:
		for i in range(8):
			var opacity: float = (1.0 - p.air / 25.0) * (0.02 + i * 0.003)
			draw_rect(Rect2(i * 5, 105 + i * 5, 1280 - i * 10, 651 - i * 10), Color(0.64, 0.16, 0.13, opacity), false, 7)
	if world.notice_left > 0:
		var size: Vector2 = font.get_string_size(world.notice_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
		draw_rect(Rect2((1280 - size.x) / 2 - 22, 155, size.x + 44, 42), Color(0.025, 0.08, 0.11, 0.94))
		text(Vector2((1280 - size.x) / 2, 182), world.notice_text, 16, GOLD)
	if world.pearl_tutorial_left > 0:
		draw_rect(Rect2(369, 202, 542, 46), Color(0.025, 0.08, 0.11, 0.96))
		text(Vector2(406, 231), "AT RISK  —  PEARLS BANK AT THE NEXT ANCHOR", 16, GOLD)
	if p.dying:
		text(Vector2(487, 395), p.death_reason.to_upper(), 32, GOLD)
		text(Vector2(476, 432), "Returning to your last anchor...", 18)
	if world.debug_visible:
		draw_rect(Rect2(30, 550, 365, 188), Color(0.01, 0.025, 0.04, 0.95))
		text(Vector2(46, 576), "DIAGNOSTICS / F1 TO HIDE", 13, GOLD)
		text(Vector2(46, 607), "Air %.2f   /   drain %.2f per second" % [p.air, p.drain_rate], 14)
		text(Vector2(46, 635), "Velocity (%+.1f, %+.1f)" % [p.velocity.x, p.velocity.y], 14)
		text(Vector2(46, 663), "Segment %.1fs   /   position %.0f, %.0f" % [world.segment_time, p.position.x, p.position.y], 14)
		text(Vector2(46, 693), "Chapter %.1fs / observation %s" % [world.elapsed, world.observation_complete], 14)
		text(Vector2(46, 719), ("Last arrival: %.1f air / %.1fs" % [world.last_arrival.air, world.last_arrival.seconds]) if not world.last_arrival.is_empty() else "No arrival recorded yet.", 12, MUTED)
	if world.paused:
		draw_rect(Rect2(0, 104, 1280, 654), Color("071923"))
		text(Vector2(480, 348), "DIVE PAUSED", 42)
		text(Vector2(450, 409), "Time, air and the ocean are stopped.", 18, MUTED)
		text(Vector2(478, 477), "ESC  Resume     Q  Main menu", 18, GOLD)
		text(Vector2(400, 530), "WASD  Swim   SPACE  Lantern   R  Retry", 18)
		text(Vector2(400, 570), "M  Music: %s    N  Effects: %s" % ["OFF" if world.music_muted else "ON", "OFF" if world.effects_muted else "ON"], 18, GOLD)
