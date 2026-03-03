extends Area2D

# These remember the ball and where you first touch the screen
var ball_in_zone: RigidBody2D = null
var touch_start_y: float = 0.0

# These show up in the Inspector so you can easily change how the plunger feels
@export var max_pull_distance: float = 300.0 
@export var power_multiplier: float = 8.0 
@onready var power_bar = $"../CanvasLayer/PowerBar"

# Godot triggers this when the ball drops in
func _on_body_entered(body):
	# Double-check that the thing entering is actually a physics ball
	if body is RigidBody2D: 
		ball_in_zone = body

# Godot triggers this when the ball shoots out
func _on_body_exited(body):
	if body == ball_in_zone:
		ball_in_zone = null

# This built-in function listens for your mouse clicks / screen taps
func _input(event):
	# If there is no ball in the tube, ignore the click entirely
	if ball_in_zone == null:
		return 
		
	# Check if the player is clicking/tapping
	if event is InputEventMouseButton:
		if event.pressed:
			# The exact moment the screen is touched, remember the Y (vertical) position
			touch_start_y = event.position.y
		else:
			# The moment the finger is lifted, calculate how far down they dragged
			var pull_distance = event.position.y - touch_start_y
			
			# Only launch if they dragged downwards (not upwards)
			if pull_distance > 10:
				# Cap the power so they can't drag infinitely off the screen
				pull_distance = min(pull_distance, max_pull_distance)
				launch_ball(pull_distance)
			power_bar.value = 0
	if event is InputEventMouseMotion and ball_in_zone != null:
		var pull_distance = event.position.y - touch_start_y
		pull_distance = clamp(pull_distance, 0, max_pull_distance)
		power_bar.value = pull_distance


# Our custom function to actually hit the ball
func launch_ball(power):
	# Create a massive burst of energy pushing UP (negative Y is up in Godot)
	var launch_force = Vector2(0, -power * power_multiplier)
	
	# Apply that energy instantly to the ball
	ball_in_zone.apply_central_impulse(launch_force)
