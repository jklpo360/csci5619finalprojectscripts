extends Node3D

@export var max_speed:= 2.5
@export var dead_zone := 0.2

@export var smooth_turn_speed:= 45.0
@export var smooth_turn_dead_zone := 0.2

@export var snap_turn_amount := 45.0
@export var snap_turn_dead_zone := 0.9
@export var snap_turn_cooldown := 0.3

@export var swap_cooldown := .3

signal win
signal reset

var input_vector:= Vector2.ZERO
var steering:= "head" # Head (head) versus Left Hand (left) versus Right Hand (right) directed steering
var snap_turning:= false # Smooth versus Snap turning
var snap_turn_counter:= 0.0 # Counter to track the cooldown of swapping turning modes
var head:= false # Flag for swapping with head
var left:= false # Flag for swapping with left controller
var right:= false # Flag for swapping with right controller
var swap_counter:= 0.0 # Counter to track the cooldown of swapping controls

var left_bound:= -4.8
var right_bound:= 4.8
var back_bound:= 9.8
var front_bound:= -39.8

var winning_counter:= 0



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if winning_counter == 4:
		win.emit()
	
	# Snap turn cooldown update
	if self.snap_turn_counter != 0.0:
		self.snap_turn_counter -= delta
		if self.snap_turn_counter < 0.0:
			self.snap_turn_counter = 0.0
	
	# Swap controls update
	if self.swap_counter != 0.0:
		self.swap_counter -= delta
		if self.swap_counter < 0.0:
			self.swap_counter = 0.0
	
	# Handle swap if any
	else:
		# Detect swap bewteen two controllers
		if (head or left or right) and not (head and left and right):
			# If the head is involved
			if head:
				# If the steering method is currently view-directed steering
				if steering == "head":
					# If the left hand is involved in the swap
					if left:
						# If the left hand is currently controlling the hand-directed steering
						if steering == "left":
							steering = "left"
					# If the right hand is involved in the swap
					else:
						# If the right hand is currently controlling the hand-directed steering
						if steering == "right":
							steering = "right"
				# If the steering method is currently hand-directed steering
				else:
					# If the left hand is involved in the swap
					if left:
						# If the left hand is currently controlling the hand-directed steering
						if steering == "left":
							steering = "head"
					# If the right hand is involved in the swap
					else:
						# If the right hand is currently controlling the hand-directed steering
						if steering == "right":
							steering = "head"
			# Swapping controls between hands
			else:
				# If the left hand is currently steering,
				if steering == "left":
					# then swap it to the right hand
					steering = "right"
				# Otherwise,
				else:
					# swap controls to the left hand
					steering = "left"
			swap_counter = swap_cooldown
		head = false
		left = false
		right = false
	
	
	# Forward translation
	# View Directed Steering
	if steering == "head":
		if self.input_vector.y > self.dead_zone or self.input_vector.y < -self.dead_zone:
			var movement_vector = Vector3(0, 0, max_speed * -self.input_vector.y * delta)
			self.position += movement_vector.rotated(Vector3.UP, $XRCamera3D.global_rotation.y)

	# Hand Directed Steering (left)
	elif steering == "left":
		if self.input_vector.y > self.dead_zone or self.input_vector.y < -self.dead_zone:
			# get movement direction
			var movement_direction = Vector3(cos($LeftController.global_rotation.y + (PI/2)), 0, -sin($LeftController.global_rotation.y + (PI/2))) #I realize now that I could've just changed $XRCamera3D to $LeftController, but oh well
			
			# apply magnitude to the direction
			var movement_vector = movement_direction.normalized() * self.input_vector.y * max_speed * delta
			
			# apply to position
			self.position += movement_vector

	# Hand Directed Steering (right)
	else:
		if self.input_vector.y > self.dead_zone or self.input_vector.y < -self.dead_zone:
			# get movement direction
			var movement_direction = Vector3(cos($RightController.global_rotation.y + (PI/2)), 0, -sin($RightController.global_rotation.y + (PI/2)))
			
			# apply magnitude to the direction
			var movement_vector = movement_direction.normalized() * self.input_vector.y * max_speed * delta
			
			# apply to position
			self.position += movement_vector


	# Snap turn
	if snap_turning:
		if (self.input_vector.x > self.snap_turn_dead_zone or self.input_vector.x < -self.snap_turn_dead_zone) and snap_turn_counter == 0.0:
			# move to the position of the camera
			self.translate($XRCamera3D.position)

			# rotate about the camera's position
			self.rotate(Vector3.UP, deg_to_rad(snap_turn_amount * sign(-self.input_vector.x)))

			# reverse the translation to move back to the original position
			self.translate($XRCamera3D.position * -1)
			
			# start the cooldown before the next snap turn
			self.snap_turn_counter = self.snap_turn_cooldown
	# Smooth turn
	else:
		if self.input_vector.x > self.smooth_turn_dead_zone or self.input_vector.x < -self.smooth_turn_dead_zone:
			# move to the position of the camera
			self.translate($XRCamera3D.position)

			# rotate about the camera's position
			self.rotate(Vector3.UP, deg_to_rad(smooth_turn_speed) * -self.input_vector.x * delta)

			# reverse the translation to move back to the original position
			self.translate($XRCamera3D.position * -1)
	if winning_counter != 4:
		if self.position.x > right_bound:
			self.position.x = right_bound
		elif self.position.x < left_bound:
			self.position.x = left_bound
		
		if self.position.z > back_bound:
			self.position.z = back_bound
		elif self.position.z < front_bound:
			self.position.z = front_bound

func process_input(input_name: String, input_value: Vector2):
	if input_name == "primary":
		input_vector = input_value


func _label_swap(from_area: Area3D, to_area: Area3D) -> void:
	print("Area: " + from_area.name + " collided with Area: " + to_area.name)

	# Exit if swap is on cooldown
	if swap_counter != 0.0:
		return
	
	if from_area.name == "HeadArea3D":
		head = true
	if to_area.name == "HeadArea3D":
		head = true
	if from_area.name == "LeftArea3D":
		left = true
	if to_area.name == "LeftArea3D":
		left = true
	if from_area.name == "RightArea3D":
		right = true
	if to_area.name == "RightArea3D":
		right = true


func reset_position():
	self.position.x = 0.0
	self.position.z = 0.0
	self.rotation.y = 0
	self.winning_counter = 0


func _on_head_area_3d_area_entered(area):
	if area.name == "LeftArea3D" or area.name == "RightArea3D":
		_label_swap(%XRCamera3D/HeadArea3D, area)


func _on_left_controller_area_3d_area_entered(area):
	if area.name == "HeadArea3D" or area.name == "RightArea3D":
		_label_swap(%LeftController/LeftArea3D, area)


func _on_right_controller_area_3d_area_entered(area):
	if area.name == "LeftArea3D" or area.name == "HeadArea3D":
		_label_swap(%RightController/RightArea3D, area)


func _on_area_3d_objective_hit():
	winning_counter += 1


func _on_first_reset():
	self.reset_position()
	reset.emit()


func _on_area_3d_area_entered(area):
	if area.name == "LeftArea3D" or area.name == "RightArea3D":
		snap_turning = not snap_turning
