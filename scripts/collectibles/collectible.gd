extends Node2D
class_name Collectible  

var is_collection = false
var floating = 1.55334
@onready var collab_partner = get_tree().get_first_node_in_group("collab_partner")
@onready var current_y_pos = global_position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	var distance = collab_partner.global_position.distance_to(global_position)
	if(distance < 2):
		fire_signal() 
		queue_free()
	elif(distance > 2 && distance < collab_partner.pickup_range):
		var dir = collab_partner.global_position - global_position
		dir = dir.normalized()
		
		global_position += 120*dir*delta
	else:
		floating += delta*5
		global_position = Vector2(global_position.x,current_y_pos + (sin(floating)*2))
	pass

## Override to use 
func fire_signal() -> void:
	pass 