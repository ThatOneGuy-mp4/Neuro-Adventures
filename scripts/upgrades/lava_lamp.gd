extends UpgradeScene

var lava_template = preload("res://scenes/projectiles/lava_lamp_lava.tscn")

#array of all current LampLava objects, so that when the colors change, they can be updated accordingly
var all_lava: Array[LampLava]

@export var LV1_DAMAGE = 1.0
@export var LV1_HEAL = 1.0
#i chose to do the size increase by just increasing the scale of the textures because it was easy
#you could just make a second, larger lava template as well though. depends on the final art i guess.
@export var LV1_SCALE = 1.0
@export var LV2_DAMAGE = 2.0
@export var LV3_HEAL = 2.0
@export var LV4_SCALE = 1.25

#duration and hit timer wait_times
@export var DURATION = 5
@export var WAIT_TIME = 1
#the max normalized distance the lava can spawn around neuro 
@export var RANGE = 200

@onready var ai = get_parent()
@onready var map = get_parent().get_parent()

#fire_timer places the lava, color_timer controls the shifting of the lava's color
@onready var fire_timer = $FireTimer
@onready var color_timer = $ColorTimer

var damage: float
var heal: float
var scale_mod: float

#the 'current' color of the lava and the color the lava is moving to
#the actual current color is a lerped or tweened value between them
var current_color: Color
var next_color: Color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#set the initial color and the first color to move to
	current_color = get_color()
	next_color = get_color()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#gets a random color through rgb values.
#you could change this method if you wanted to add some logic to which colors are picked
#but i couldn't think of anything that was both easy to do and didn't look like shit, so.
func get_color() -> Color:
	var r = randf()
	var g = randf()
	var b = randf() 
	return Color(r, g, b)

func sync_level() -> void:
	match upgrade.lvl:
		1:
			damage = LV1_DAMAGE
			heal = LV1_HEAL
			scale_mod = LV1_SCALE
		2:
			damage = LV2_DAMAGE
		3:
			heal = LV3_HEAL
		4:
			scale_mod = LV4_SCALE

#places down the lava
func _on_fire_timer_timeout() -> void:
	#instantiate the lava
	var lava = lava_template.instantiate()
	
	#get a random distance away from neuro within RANGE that the lava will spawn, then rotate it a random amount around her
	#could change the min on rand_range from 0 to something greater if you want to guarantee it doesn't spawn near her
	var radians = randf_range(0, TAU)
	var length = randi_range(0, RANGE)
	lava.global_position = Vector2(ai.global_position.x + length * cos(radians), ai.global_position.y + length * sin(radians))
	
	#get the color the lava lamp will spawn as
	#since the color will be between current_color and next_color, use lerp to get a value between them
	var color = current_color.lerp(next_color, 1 - (color_timer.time_left / color_timer.wait_time))
	
	#setup the lava
	lava.setup(damage, heal, scale_mod, DURATION, WAIT_TIME, color)
	map.add_child(lava)
	
	#start the tween for the lava
	lava.start_tween(next_color, color_timer.time_left)
	
	#add the lava to the array of all current lava objects 
	all_lava.append(lava)

#updates all lava to start tweening to a new color
func _on_color_timer_timeout() -> void:
	#set the current_color to be the previous next_color, then get a new color to tween to
	current_color = next_color
	next_color = get_color()
	
	#if no lava currently exists, exit method
	if all_lava.size() == 0:
		return
		
	#we don't want to tween a destroyed lava, and lava will always be destroyed in a first-in, first-out pattern
	#therefore, while the first index does not have a valid instance, remove it from the array
	while not is_instance_valid(all_lava[0]):
		all_lava.pop_front()
		
	#finally, loop through all lava and start tweening to next_color
	for lava: LampLava in all_lava:
		lava.start_tween(next_color, color_timer.wait_time)
