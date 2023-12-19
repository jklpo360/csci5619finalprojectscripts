extends Area3D

signal reset

func _on_area_entered(area):
  if area.name == "XRUser":
    reset.emit()