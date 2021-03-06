
extends Node2D

export var once = false
var activated = false
export var is_on = false
export var target_nodes = []
export var related_switches = []
export var enabled = true
export var invert = false
var targets = []
var target_containers = []
var switches = []
var tilemap
var onscreen = false

func _ready():
	tilemap = get_parent().get_parent()
	if (target_containers.empty()):
		for target in target_nodes:
			var target_obj = tilemap.get_node(target)
			targets.append(target_obj)
			target_containers.append(target_obj.get_parent())

	if (switches.empty()):
		for i in related_switches:
			var switch_obj = tilemap.get_node(i)
			switches.append(switch_obj)
	if (enabled):
		set_fixed_process(true)

func activate():
	if ((!is_on && !invert) || (is_on && invert)):
		var size = target_containers.size()
		for index in range(0, size):
			if (target_containers[index].has_node(targets[index].get_name())):
				target_containers[index].remove_child(targets[index])
			activated = true
	elif ((is_on && !invert) || (!is_on && invert)):
		var size = target_containers.size()
		for index in range(0, size):
			if (!target_containers[index].has_node(targets[index].get_name())):
				target_containers[index].add_child(targets[index])
				activated = true

func enable(value):
	enabled = value
	if (enabled && onscreen):
		set_fixed_process(true)
	else:
		set_fixed_process(false)

func _fixed_process(delta):
	if ((once && !activated) || !once):
		var update = check_activation()
		if (update):
			activate()

func check_activation():
	return false