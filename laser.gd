extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.scale.z = 100
	self.position.z = -50

	var start_point = get_parent().global_position
	var end_point = get_parent().global_transform * Vector3(0, 0, -100)

	var query = PhysicsRayQueryParameters3D.create(start_point, end_point)
	query.collide_with_areas = true

	var result = get_world_3d().direct_space_state.intersect_ray(query)

	if !result.is_empty():
		var collision_distance = result["position"].distance_to(start_point)
		self.scale.z = collision_distance
		self.position.z = -collision_distance / 2

		var menus = get_tree().get_nodes_in_group("spatial_menus")
		for menu in menus:
			if result["collider_id"] == menu.get_instance_id():
				var menu_shape = menu.find_child("CollisionShape3D") as CollisionShape3D
				var box = menu_shape.shape as BoxShape3D

				var local_collision = menu.global_transform.inverse() * result["position"]
				var normalized_coords = Vector2(local_collision.x / box.size.x + 0.5, local_collision.z / box.size.z + 0.5)
				
				var viewport = menu.find_child("SubViewport") as SubViewport
				var viewport_coords = Vector2(viewport.size.x * normalized_coords.x, viewport.size.y * normalized_coords.y)

				var event = InputEventMouseMotion.new()
				event.position = viewport_coords
				event.global_position = viewport_coords
				viewport.push_input(event)
	else:
		self.scale.z = 100
		self.position.z = -50

func _on_controller_button_pressed(button_name: String, button_state: bool):
	if button_name == "trigger_click":
		var start_point = get_parent().global_position
		var end_point = get_parent().global_transform * Vector3(0, 0, -100)

		var query = PhysicsRayQueryParameters3D.create(start_point, end_point)
		query.collide_with_areas = true

		var result = get_world_3d().direct_space_state.intersect_ray(query)

		if !result.is_empty():
			var menus = get_tree().get_nodes_in_group("spatial_menus")
			for menu in menus:
				if result["collider_id"] == menu.get_instance_id():
					
					var menu_shape = menu.find_child("CollisionShape3D") as CollisionShape3D
					var box = menu_shape.shape as BoxShape3D
					var local_collision = menu.global_transform.inverse() * result["position"]
					var normalized_coords = Vector2(local_collision.x / box.size.x + 0.5, local_collision.z / box.size.z + 0.5)

					var viewport = menu.find_child("SubViewport") as SubViewport
					var viewport_coords = Vector2(viewport.size.x * normalized_coords.x, viewport.size.y * normalized_coords.y)

					var event = InputEventMouseButton.new()
					event.position = viewport_coords
					event.global_position = viewport_coords
					event.button_index = MouseButton.MOUSE_BUTTON_LEFT
					event.set_pressed(button_state)
					viewport.push_input(event)