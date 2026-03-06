extends Area2D

var touch_start_y: float = 0.0
var is_dragging: bool = false 

@export var max_pull_distance: float = 300.0 
@export var power_multiplier: float = 8.0 

@onready var power_bar = $"../CanvasLayer/PowerBar"
@onready var ramp_gate_collision = $"../RampGate/CollisionShape2D"
@onready var success_zone = $"../SuccessZone"

func _ready():
	# NEW: Tell the launcher to listen for balls entering its pocket
	self.body_entered.connect(_on_launcher_body_entered)
	
	if success_zone:
		success_zone.body_entered.connect(_on_success_zone_entered)
	else:
		print("ERROR: Could not find the SuccessZone!")

# --- NEW: CLOSE THE GATE AUTOMATICALLY ---
func _on_launcher_body_entered(body):
	if body is RigidBody2D:
		if ramp_gate_collision:
			# disabled = false means the physical wall is TURNED ON (Gate Closed)
			ramp_gate_collision.set_deferred("disabled", false)

func get_ball_in_launcher() -> RigidBody2D:
	for body in get_overlapping_bodies():
		if body is RigidBody2D:
			return body
	return null

func _input(event):
	var ball = get_ball_in_launcher()
	
	if ball == null:
		return 
		
	if event is InputEventMouseButton:
		if event.pressed:
			touch_start_y = event.position.y
			is_dragging = true
		else:
			if is_dragging:
				var pull_distance = event.position.y - touch_start_y
				
				if pull_distance > 10:
					pull_distance = min(pull_distance, max_pull_distance)
					launch_ball(ball, pull_distance) 
				
				power_bar.value = 0
				is_dragging = false
				
	if event is InputEventMouseMotion and is_dragging:
		var pull_distance = event.position.y - touch_start_y
		pull_distance = clamp(pull_distance, 0, max_pull_distance)
		power_bar.value = pull_distance

func launch_ball(ball: RigidBody2D, power: float):
	# WAKE UP! 
	ball.sleeping = false
	
	# Apply the massive burst of energy
	var launch_force = Vector2(0, -power * power_multiplier)
	ball.apply_central_impulse(launch_force)

# --- OPEN THE GATE AUTOMATICALLY ---
func _on_success_zone_entered(body):
	if body is RigidBody2D:
		if ramp_gate_collision:
			# disabled = true means the physical wall is TURNED OFF (Gate Open)
			ramp_gate_collision.set_deferred("disabled", true)
