extends Node

var last_position = Vector2(0.0, 0.0)
var mouse_position = Vector2(0.0, 0.0)
var snap_radius = 10 # radius where the pen snaps to the node and draws a line
var drawing = false # variable tracking if the trigger on the controller is depressed
var last_node = null # variable tracking the node that is currently being drawn fron. Is null or 0-11
var second_to_last_node = null # variable tracking the node that can undo the last line segment. Is null or 0-11

# format of indices:
#     *  0  *
#   1   2  3  4
#  *  5  *  6  *
#   7   8  9  10
#     *  11 *
var current_pattern = 0b000000000000 # twelve bit bitstring

# all patterns assume right end of the bitstring is the 0th index

#     * --- *
#   /      /  \
#  * --- *     *
#   \         /
#     * --- *
var ice_pattern = 0b110010111011

#     *     *
#          /  \
#  * --- *     *
#   \   /     /
#     * --- *
var fire_pattern = 0b110110111000

#     *     *
#   /  \      \
#  *     * --- *
#   \          
#     *     *
var lightning_pattern = 0b000011010110

#     * --- *
#   /          
#  *     *     *
#   \   /  \   
#     * --- *
var water_pattern = 0b101110000011

#     * --- *
#   /      /  \
#  * --- *     *
#       /  \  /
#     *     *
var wind_pattern = 0b011100111011

#     *     *
#      \   /   
#  *     *     *
#   \         /
#     * --- *
var size_down_pattern = 0b110010001100

#     * --- *
#   /         \
#  *     *     *
#      /   \    
#     *     *
var size_up_pattern = 0b001100010011

#     *     *
#   /         \
#  *     *     *
#      /   \   
#     * --- *
var frog_pattern = 0b101100010010

#     * --- *
#      \   /   
#  * --- * --- *
#      /   \   
#     * --- *
var time_stop_pattern = 0b101101101101

signal ice
signal fire
signal lightning
signal water
signal wind
signal size_down
signal size_up
signal frog
signal time_stop

# 900 width 1200 height

# (x, y) pixel offset from top left corner as (0, 0)
# center, left, right, top left, top right, bottom left, bottom right
#    0  ,  1  ,   2  ,    3    ,     4    ,      5     ,      6
var node_positions = [Vector2(450, 600), Vector2(100, 600), Vector2(800, 600), Vector2(237, 297), Vector2(625, 297), Vector2(237, 903), Vector2(625, 903)]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Exit if not drawing
	if !drawing:
		return
	# Update mouse position
	mouse_position = get_mouse_position()
	# Exit if no movement
	if last_position == mouse_position:
		return
	else:
		last_position.x = mouse_position.x
		last_position.y = mouse_position.y
	# Check for new node snap
	for node in node_positions:
		if mouse_position.distance_to(node) < snap_radius:


  
func evaluate_drawing() -> string:
	if pattern == ice_pattern:
		return "ice"
	elif pattern == fire_pattern:
		return "fire"
	elif pattern == lightning_pattern:
		return "lightning"
	elif pattern == water_pattern:
		return "water"
	elif pattern == wind_pattern:
		return "wind"
	elif pattern == size_up_pattern:
		return "size_up"
	elif pattern == size_down_pattern:
		return "size_down"
	elif pattern == frog_pattern:
		return "frog"
	elif pattern == time_stop_pattern:
		return "time_stop"
	else:
		return "nothing"

func cast(spell_name):
	if spell_name == "nothing":
		return
	elif spell_name == "ice":
		emit(ice)
	elif spell_name == "fire":
		emit(fire)
	elif spell_name == "lightning":
		emit(lightning)
	elif spell_name == "water":
		emit(water)
	elif spell_name == "wind":
		emit(wind)
	elif spell_name == "size_up":
		emit(size_up)
	elif spell_name == "size_down":
		emit(size_down)
	elif spell_name == "frog":
		emit(frog)
	elif spell_name == "time_stop":
		emit(time_stop)
		
  
# placeholder function for starting to draw, needs more logic
func _on_trigger_pressed():
	last_position = get_mouse_position()

	for i in node_positions.length:
		if node_positions[i].distance_to(last_position) < snap_radius:
			last_node = i
			drawing = true

# placeholder function for ending drawing session, needs more logic
func _on_trigger_released():
	drawing = false
	cast(evaluate_drawing())
	reset_grid()

func _on_button_pressed():
	print("Button pressed")