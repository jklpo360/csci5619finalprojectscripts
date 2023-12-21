extends SubViewport

var last_position = Vector2(0.0, 0.0)
var mouse_position = Vector2(0.0, 0.0)
var snap_radius = 50 # Radius where the pen snaps to the node and draws a line
var drawing = false # Variable tracking if the trigger on the controller is depressed
var current_node_index = null # Variable tracking the node that is currently being drawn fron. Is null or 0-11
var node_history = [] # Stack tracking the nodes previously visited. Drawing pushes a node to the front, and backtracking pops from the front

# format of line indices:
#     *  0  *
#   1   2  3  4
#  *  5  *  6  *
#   7   8  9  A
#     *  B  *
# Format of node indices
#     3     4
#            
#  1     0     2
#  
#     5     6
var current_pattern = 0b000000000000 # twelve bit bitstring

# all patterns assume right end of the bitstring is the 0th index
var line_mask_0 = 0b000000000001
var line_mask_1 = 0b000000000010
var line_mask_2 = 0b000000000100
var line_mask_3 = 0b000000001000
var line_mask_4 = 0b000000010000
var line_mask_5 = 0b000000100000
var line_mask_6 = 0b000001000000
var line_mask_7 = 0b000010000000
var line_mask_8 = 0b000100000000
var line_mask_9 = 0b001000000000
var line_mask_A = 0b010000000000
var line_mask_B = 0b100000000000
var mask_list = [line_mask_0, line_mask_1, line_mask_2, line_mask_3, line_mask_4, line_mask_5, line_mask_6, line_mask_7, line_mask_8, line_mask_9, line_mask_A, line_mask_B]

var line_list
var cursor_line # vertex 0 is the node it is attached to, and vertex 1 is the mouse_position

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

#     * --- *
#      \   /   
#  *     * --- *
#             /
#     *     *
var lightning_pattern = 0b010001001101

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
	line_list = [%line0, %line1, %line2, %line3, %line4, %line5, %line6, %line7, %line8, %line9, %lineA, %lineB]
	cursor_line = %cursor_line
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
		#TODO update the appearance of the cursor line
		cursor_line.set_point_position(1, mouse_position)
		cursor_line.queue_redraw()
	# For each node:
	for i in range(len(node_positions)):
		# Check for new node snap
		if (mouse_position.distance_to(node_positions[i]) < snap_radius) and (i != current_node_index):
			# If not started yet
			if current_node_index == null:
				current_node_index = i
				cursor_line.show()
				cursor_line.set_point_position(0, node_positions[i])
				cursor_line.set_point_position(1, mouse_position)
				cursor_line.queue_redraw()
			
			# Erase last line if backtracking
			elif len(node_history) != 0 and i == node_history[0]:
				var line = get_line_index(current_node_index, node_history[0])
				print(str("current pattern: ", current_pattern))
				print(str("mask: ", mask_list[line]))
				current_pattern = mask_list[line] ^ current_pattern
				print(str("result: ", current_pattern))
				current_node_index = node_history.pop_front()
				line_list[line].hide()
				cursor_line.set_point_position(0, node_positions[current_node_index])
				cursor_line.queue_redraw()
				break

			# Draw new line if valid
			elif check_line_available(get_line_index(i, current_node_index)):
				var line = get_line_index(i, current_node_index)
				line_list[line].show()
				current_pattern = current_pattern | mask_list[line]
				cursor_line.set_point_position(0, node_positions[i])
				cursor_line.queue_redraw()
				node_history.push_front(current_node_index)
				current_node_index = i
				break




func reset_grid():
	current_node_index = null
	node_history = []
	current_pattern = 0b000000000000
	drawing = false
	cursor_line.hide()
	for i in range(len(line_list)):
		line_list[i].hide()
  
func evaluate_drawing() -> String:
	if current_pattern == ice_pattern:
		return "ice"
	elif current_pattern == fire_pattern:
		return "fire"
	elif current_pattern == lightning_pattern:
		return "lightning"
#	elif current_pattern == water_pattern:
#		return "water"
#	elif current_pattern == wind_pattern:
#		return "wind"
		
#	elif current_pattern == size_up_pattern:
#		return "size_up"
#	elif current_pattern == size_down_pattern:
#		return "size_down"
#	elif current_pattern == frog_pattern:
#		return "frog"
	elif current_pattern == time_stop_pattern:
		return "time_stop"
	else:
		return "nothing"

func cast(spell_name):
	if spell_name == "nothing":
		return
	elif spell_name == "ice":
		ice.emit()
	elif spell_name == "fire":
		fire.emit()
	elif spell_name == "lightning":
		lightning.emit()
	elif spell_name == "water":
		water.emit()
	elif spell_name == "wind":
		wind.emit()
	elif spell_name == "size_up":
		size_up.emit()
	elif spell_name == "size_down":
		size_down.emit()
	elif spell_name == "frog":
		frog.emit()
	elif spell_name == "time_stop":
		time_stop.emit()

# Returns the index of the line between two adjacent nodes, and null if they are not adjacent
func get_line_index(node1, node2):
	# Initial invalid check
	if node1 == node2 or node1 == null or node2 == null:
		return null 
		
	# From Center node
	if node1 == 0:
		# to Left node
		if node2 == 1:
			# Checks if line is undrawn and returns that
			return 5

		# to Right node
		elif node2 == 2:
			# Checks if line is undrawn and returns that
			return 6

		# to Top Left node
		elif node2 == 3:
			# Checks if line is undrawn and returns that
			return 2

		# to Top Right node
		elif node2 == 4:
			# Checks if line is undrawn and returns that
			return 3

		# to Bottom Left node
		elif node2 == 5:
			# Checks if line is undrawn and returns that
			return 8

		# to Bottom Right node
		elif node2 == 6:
			# Checks if line is undrawn and returns that
			return 9

		# Impossible due to check at start of function
		else:
			return null

	# From Left node
	elif node1 == 1:
		# to Center node
		if node2 == 0:
			# Checks if line is undrawn and returns that
			return 5

		# to Top Left node
		if node2 == 3:
			# Checks if line is undrawn and returns that
			return 1

		# to Bottom Left node
		elif node2 == 5:
			# Checks if line is undrawn and returns that
			return 7

		# to Non-adjacent node
		else:
			return null

	# From Right node
	elif node1 == 2:
		# to Center node
		if node2 == 0:
			# Checks if line is undrawn and returns that
			return 6

		# to Top Right node
		if node2 == 4:
			# Checks if line is undrawn and returns that
			return 4

		# to Bottom Right node
		elif node2 == 6:
			# Checks if line is undrawn and returns that
			return 10

		# to Non-adjacent node
		else:
			return null
	
	# From Top Left node
	elif node1 == 3:
		# to Center node
		if node2 == 0:
			# Checks if line is undrawn and returns that
			return 2

		# to Left node
		if node2 == 1:
			# Checks if line is undrawn and returns that
			return 1

		# to Top Right node
		elif node2 == 4:
			# Checks if line is undrawn and returns that
			return 0

		# to Non-adjacent node
		else: 
			return null
	
	# From Top Right node
	elif node1 == 4:
		# to Center node
		if node2 == 0:
			# Checks if line is undrawn and returns that
			return 3
		
		# to Right node
		if node2 == 2:
			# Checks if line is undrawn and returns that
			return 4

		# to Top Left node
		elif node2 == 3:
			# Checks if line is undrawn and returns that
			return 0

		# to Non-adjacent node
		else: 
			return null

	# From Bottom Left node
	elif node1 == 5:
		# to Center node
		if node2 == 0:
			# Checks if line is undrawn and returns that
			return 8

		# to Left node
		if node2 == 1:
			# Checks if line is undrawn and returns that
			return 7

		# to Bottom Right node
		elif node2 == 6:
			# Checks if line is undrawn and returns that
			return 11

		# to Non-adjacent node
		else:
			return null
	
	# From Bottom Right node
	elif node1 == 6:
		# to Center node
		if node2 == 0:
			# Checks if line is undrawn and returns that
			return 9
		
		# to Right node
		if node2 == 2:
			# Checks if line is undrawn and returns that
			return 10

		# to Bottom Left node
		elif node2 == 5:
			# Checks if line is undrawn and returns that
			return 11

		# to Non-adjacent node
		else:
			return null

	# Impossible
	else:
		return null

func check_line_available(line_index) -> bool:
	if line_index == null:
		return false
	return (mask_list[line_index] & current_pattern) == 0
  
# placeholder function for starting to draw, needs more logic
func _on_trigger_pressed(button):
	print(get_mouse_position())
	
#	if button == "grip_click":
#		var book_spell = $"../../../LeftSide/LeftPage/SpellListViewport/CanvasLayer".current_spell
#		if book_spell == 0:
#			fire.emit()
#		elif book_spell == 1:
#			ice.emit()
#		elif book_spell == 2:
#			lightning.emit()
#		elif book_spell == 3:
#			time_stop.emit()
	
	if button != "trigger_click":
		return
	last_position = get_mouse_position()
	drawing = true
	
	for i in range(len(node_positions)):
		if node_positions[i].distance_to(last_position) < snap_radius:
			print("found initial snap")
			current_node_index = i
			cursor_line.show()
			cursor_line.set_point_position(0, node_positions[i])
			cursor_line.set_point_position(1, mouse_position)
			cursor_line.queue_redraw()
			return

func _on_trigger_released(button):
	if button != "trigger_click":
		return
	cast(evaluate_drawing())
	reset_grid()

func _on_button_pressed():
	print("Button pressed")
