extends Area3D

signal reset

func _on_area_entered(area):
  if area.name == globals.PLAYER_COLLIDER_NAME:
	  reset.emit()