extends Area2D
var checkpoint_id: int = 0
var activated: bool = false
var world: Node2D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var c := CollisionShape2D.new()
	var s := RectangleShape2D.new()
	s.size = Vector2(72, 180)
	c.shape = s
	add_child(c)
	body_entered.connect(_touch)
	var mat := CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = mat

func _touch(body: Node) -> void:
	if body == world.player:
		world.activate_checkpoint(self)

func _draw() -> void:
	var c := Color("dfbc7e") if activated else Color("467f84")
	draw_arc(Vector2.ZERO, 48, PI * 0.85, PI * 2.15, 32, c, 5, true)
	draw_line(Vector2(-43, 21), Vector2(-43, 90), c, 5, true)
	draw_line(Vector2(43, 21), Vector2(43, 90), c, 5, true)
	draw_circle(Vector2(0, -50), 5, Color("ffe2a4") if activated else c)
	draw_string(ThemeDB.fallback_font, Vector2(-31, 112), "ANCHOR %02d" % (checkpoint_id + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, c)
