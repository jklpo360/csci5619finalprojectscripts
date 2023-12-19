extends Node

var last_position = Vector2(0.0, 0.0)
var mouse_position = Vector2(0.0, 0.0)

# 900 width 1200 height

# assuming x, y
# center, left, right
var node positions = [Vector2(450, 600), Vector2(100, 60), Vector2(), Vector2(), Vector2(), Vector2(), Vector2()]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  # Update mouse position and exit if no movement
  mouse_position = get_mouse_position()
  if last_position == mouse_position:
    return
	else
    last_position.x = mouse_position.x
    last_position.y = mouse_position.y

  

  
  


func _on_button_pressed():
	print("Button pressed")