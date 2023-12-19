extends Area3D

signal reset

var globals = get_node("/root/Globals")

func _on_area_entered(area):
  if area.name == globals.PLAYER_COLLIDER_NAME:
	  reset.emit()