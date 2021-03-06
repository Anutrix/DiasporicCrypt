# Base class for projectile like spells

extends Node2D

var sprite
var is_released = false
var direction = 1
var speed = 10
var hp = 2 # projectile is only allowed a certain number of hits before disappearing
var camera
var sampleplayer
var soundid
var collision
var release_sfx
var charge_sfx
var atk = 10

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if (is_released):
		set_global_pos(Vector2(direction*speed + get_global_pos().x, get_global_pos().y))
		if ((camera.get_camera_screen_center().x - direction * camera.get_offset().x < get_global_pos().x && direction > 0)
			|| (camera.get_camera_screen_center().x - direction * camera.get_offset().x > get_global_pos().x && direction < 0)
			|| hp <= 0):
			if (has_node(collision.get_name())):
				remove_child(collision)
			if (!sampleplayer.is_active()):
				queue_free()
	elif (!sampleplayer.is_active()):
		soundid = sampleplayer.play(charge_sfx)

func change_scale(scale):
	sprite.set_param(Particles2D.PARAM_INITIAL_SIZE, scale)
	sprite.set_param(Particles2D.PARAM_FINAL_SIZE, scale*3/7.0)
	set_scale(Vector2(scale, scale))
	sampleplayer.set_volume_db(soundid, 5 * (scale - 1) - 10)

func change_direction(new_direction):
	direction = new_direction
	set_scale(Vector2(direction, 1))
	var angle = fposmod(-direction*90, 360)
	sprite.set_param(Particles2D.PARAM_GRAVITY_DIRECTION, angle)
	sprite.set_param(Particles2D.PARAM_INITIAL_ANGLE, angle)
	
func release():
	var scale = sprite.get_param(Particles2D.PARAM_INITIAL_SIZE)
	is_released = true
	var volume = sampleplayer.get_volume_db(soundid)
	soundid = sampleplayer.play(release_sfx)
	sampleplayer.set_volume_db(soundid, volume)
	hp = hp * ceil(scale)