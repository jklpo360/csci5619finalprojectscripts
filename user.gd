extends Node3D

var max_speed = 2.5
var dead_zone = 0.2

var smooth_turn_speed = 45.0
var smooth_turn_dead_zone = 0.2

var snap_turn_amount = 45.0
var snap_turn_dead_zone = 0.9
var snap_turn_cooldown = 0.3

var swap_cooldown = 0.3

var input_vector = Vector2.ZERO
var snap_turning = false # Smooth versus Snap turning
var snap_turn_counter = 0.0 # Counter to track the cooldown of swapping turning modes
var head = false # Flag for view-directed steering
var left = false # Flag for dominant controller: left is true, right is false
var swap_counter = 0.0 # Counter to track the cooldown of swapping controls

signal swap_hands


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
  # Reset X and Z rotation because godot physics are cool!
  self.rotation.x = 0.0
  self.rotation.z = 0.0

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
	
	
	
	# Forward translation
	# View Directed Steering
	if head:
		if self.input_vector.y > self.dead_zone or self.input_vector.y < -self.dead_zone:
			var movement_vector = Vector3(0, 0, max_speed * -self.input_vector.y * delta)
			self.position += movement_vector.rotated(Vector3.UP, $XRCamera3D.global_rotation.y)

	# Hand Directed Steering (left)
	elif (not head) and left:
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

func process_input(input_name: String, input_value: Vector2):
	if input_name == "primary":
		input_vector = input_value

func reset_position():
	self.position.x = 0.0
	self.position.y = 0.0
	self.position.z = 0.0
	self.rotation.y = PI

func swap_hands():
	left = not left

func swap_turning():
	snap_turning = not snap_turning

func swap_steering():
	head = not head

# Signals
func _on_user_reset():
	self.reset_position()

func _on_button_pressed(name):
	if name == "ax_button"
		swap_turning()
		
	if name == "by_button":
		swap_steering()

func _on_left_controller_area_3d_entered(area):
	if name == "":
		swap_turning()
