
extends "res://scenes/common/target.gd"

# control Fire Dragon main functions

# This boss has several phases:
# circle - head moves in circles
# open - stop circling and mouth opens
# fire - after open, fire fireballs
# close - after fire, mouth closes
# die - show death animation after boss is defeated
var cycle = "circle"
var currentx = 0
var offset
var COOLDOWN = 600
var delay = 0 # delay between fire cycles so long as player is within sight
var fireclass = preload("res://players/magic/fire/fire.tscn")
var expclass = preload("res://scenes/items/exporb/exporb.tscn")
var potionplusplusclass = preload("res://scenes/items/potion/potionplus.tscn")
var rubykeyclass = preload("res://scenes/items/special/rubykey.tscn")
var ROUND = 5 # number of fireballs to throw during each fire cycle
var fireround = 0
var FIRE_COOLDOWN = 60 # delay between fireballs
var fire_delay = 0
var maxhp = 100 #10000
var hp = 100
var ep = 100000
var HURT_COLOR = Color(1, 98/255.0, 98/255.0, 1)
var DEFAULT_COLOR = Color(1, 1, 1, 1)

func _ready():
	offset = get_global_pos()
	elemental_weaknesses = ["ice"]
	elemental_protection = ["fire"]
	collision_rect.set_name("damagable")

func _fixed_process(delta):
	if (cycle == "die"):
		if (!animation_player.is_playing()):
			# item drops after death animation
			var item = rubykeyclass.instance()
			if (Globals.get("inventory").inventory.has("ITEM_RUBYKEY")):
				item = potionplusplusclass.instance()
			var exporb = expclass.instance()
			exporb.set_value(ep)
			exporb.set_global_pos(Vector2(272, -272))
			item.set_global_pos(Vector2(272, -304))
			get_parent().get_parent().add_child(exporb)
			get_parent().get_parent().add_child(item)
			set_fixed_process(false)
			get_parent().queue_free()
	else:
		# adjust head color according to remaining HP
		var percent = hp/float(maxhp)
		var headcolor = HURT_COLOR.linear_interpolate(DEFAULT_COLOR, percent)
		get_node("head").set_modulate(headcolor)
		get_node("jaw").set_modulate(headcolor)
		var player_obj = player.get_node("player")
		# check that player is in sight and after delay before attacking
		if (delay == 0 && (cycle != "open" && cycle != "fire" && cycle != "close")):
			if (player_obj.get_global_pos().y > get_global_pos().y - 48 && player_obj.get_global_pos().y < get_global_pos().y + 48):
				cycle = "open"
				animation_player.play("open")
				fire_delay = 0
		else:
			delay += 1
		if (delay >= COOLDOWN):
			delay = 0
		if (cycle == "open"):
			if (!animation_player.is_playing()):
				cycle = "fire"
		if (cycle == "close"):
			if (!animation_player.is_playing()):
				cycle = "circle"
		if (cycle == "fire"):
			if (fire_delay == 0):
				var fire = fireclass.instance()
				fire.set_global_pos(Vector2(get_global_pos().x, get_global_pos().y + 80))
				get_parent().get_parent().add_child(fire)
				fire.change_direction(-1)
				fire.set("camera", player_obj.get_node("Camera2D"))
				fire.set("speed", 5)
				#fire.set("atk", 10)
				fire.get_node("Area2D").set_name("damagable")
				fire.release()
				fireround += 1
				if (fireround >= ROUND):
					delay += 1
					fireround = 0
					cycle = "close"
					animation_player.play("close")
			fire_delay += 1
			if (fire_delay >= FIRE_COOLDOWN):
				fire_delay = 0
		if (cycle == "circle"):
			currentx += PI/60
			var pos = calculate_circle()
			pos.x = offset.x + pos.x
			pos.y = offset.y + pos.y
			set_global_pos(pos)

func update_animation(new_animation):
	if (new_animation == "hurt"):
		new_animation = current_animation
		set_flash(true)
	else:
		set_flash(false)
	if (cycle != "die"):
		.update_animation(new_animation)

# flash when hit
func set_flash(value):
	get_node("jaw").set_use_parent_material(value)
	get_node("head").set_use_parent_material(value)
	get_parent().get_node("body").set_use_parent_material(value)
	get_parent().get_node("neck/segments").set_use_parent_material(value)

func check_hp(damage):
	hp -= damage
	if (hp <= 0):
		dying = true
		cycle = "die"
		collision_rect.queue_free()
		Globals.set("current_quest_complete", true)
		var level = Globals.get("levels")[Globals.get("current_level")]
		level.complete = true
		Globals.get("levels")[Globals.get("current_level")] = level
		var level_display = get_tree().get_root().get_node("world/gui/CanvasLayer/level")
		level_display.get_node("title").set_text("KEY_VICTORY")
		level_display.get_node("AnimationPlayer").play("quest")
		get_parent().get_node("damagable").queue_free()
		animation_player.play("die")

func calculate_circle():
	var x = cos(currentx)*64
	var r = pow(64, 2) - pow(x, 2)
	var s = 1
	if (fmod(currentx, 2*PI) > PI):
		s = -1
	var y = sqrt(abs(r))/2.0*s
	return Vector2(x, y)
	
func bleed():
	pass