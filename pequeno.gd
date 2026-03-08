extends Node2D

var score = 0

@onready var score_label = $CanvasLayer/ScoreLabel
@onready var histogram = $CanvasLayer/HBoxContainer
@onready var score_buckets_folder = $"Score Buckets"
@onready var spawn_point = $SpawnPoint

@export var ball_scene: PackedScene
@export var bucket_yields: Array[int] = [0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2]

func _ready():
	print("--- GAME STARTED ---")
	
	if not score_label: print("ERROR: Cannot find ScoreLabel!")
	if not histogram: print("ERROR: Cannot find Histogram!")
	if not score_buckets_folder: 
		print("ERROR: Cannot find 'Score Buckets' folder!")
		return 
		
	score_label.text = "Score: 0"
	
	var bucket_index = 0
	var connected_count = 0
	
	# Loop through the Score Buckets folder
	for bucket in score_buckets_folder.get_children():
		if bucket is Area2D:
			# 1. Connect the signal (Your original code)
			bucket.body_entered.connect(Callable(self, "_on_bucket_body_entered").bind(bucket_index))
			connected_count += 1
			
			# 2. Update the Label (The New Part)
			# This assumes each bucket has a child node named "Label"
			var label = bucket.get_node_or_null("Label") 
			if label and bucket_index < bucket_yields.size():
				var yield_val = bucket_yields[bucket_index]
				label.text = str(yield_val) + "x"
				
				# Optional: Style the text based on the value
				if yield_val == 0:
					label.modulate = Color.RED # "Sink" buckets
				elif yield_val > 1:
					label.modulate = Color.GREEN # "Win" buckets
		
		bucket_index += 1
		
	print("Successfully connected ", connected_count, " buckets and updated labels!")
	# This finds your button and manually 'plugs' it into your function
	var my_button = find_child("*Button*", true, false)
	if my_button:
		# If it was already connected to the wrong thing, we clear it first
		if my_button.pressed.is_connected(_on_gate_button_pressed):
			my_button.pressed.disconnect(_on_gate_button_pressed)
			
		my_button.pressed.connect(_on_gate_button_pressed)
		print("Manual button connection established!")

func add_score(amount):
	score += amount
	score_label.text = "Score: " + str(score)

func _on_bucket_body_entered(body, bucket_index):
	if body is RigidBody2D: 
		
		# --- NEW: COOLDOWN TIMER SYSTEM ---
		# Check if the ball is currently on cooldown
		if body.has_meta("cooldown") and body.get_meta("cooldown") == true:
			return 
			
		# Put the ball on cooldown immediately so it doesn't double-trigger
		body.set_meta("cooldown", true)
		
		var balls_to_spawn = 0
		if bucket_index < bucket_yields.size():
			balls_to_spawn = bucket_yields[bucket_index]
			
		if histogram and histogram.has_method("add_to_bucket"):
			histogram.add_to_bucket(bucket_index)
			
		if balls_to_spawn == 0:
			# Sink bucket! Delete the ball.
			body.queue_free()
		else:
			# Doubler bucket!
			var extra_balls = balls_to_spawn - 1
			if extra_balls > 0:
				if spawn_point:
					spawn_new_balls(spawn_point.global_position, extra_balls)
					
		# --- NEW: REMOVE THE COOLDOWN ---
		# Wait half a second, then allow the ball to score again
		await get_tree().create_timer(0.5).timeout
		
		# Check if the ball still exists (it might have fallen off screen or been deleted)
		if is_instance_valid(body):
			body.set_meta("cooldown", false)

func spawn_new_balls(spawn_position: Vector2, amount: int):
	for i in range(amount):
		if ball_scene:
			var new_ball = ball_scene.instantiate()
			add_child(new_ball) # Add to tree first so we can see it
			
			# 1. SET THE INITIAL "HIDDEN" STATE
			new_ball.global_position = spawn_point.global_position + Vector2(0, -30)
			new_ball.scale = Vector2(0.1, 0.1)
			new_ball.modulate.a = 0.0
			
			# 2. CHECK FOR PHYSICS (ONLY FREEZE IF IT'S A RIGIDBODY)
			if "freeze" in new_ball:
				new_ball.set("freeze", true)
			
			# 3. START THE TWEEN
			var tween = create_tween()
			tween.set_parallel(true)
			
			# Animation: Scale up, Fade in, Move down
			tween.tween_property(new_ball, "scale", Vector2(1, 1), 0.5)\
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(new_ball, "modulate:a", 1.0, 0.3)
			tween.tween_property(new_ball, "global_position", spawn_point.global_position, 0.5)
			
			# 4. TURN PHYSICS BACK ON AT THE END
			tween.finished.connect(func(): 
				if is_instance_valid(new_ball) and "freeze" in new_ball:
					new_ball.set("freeze", false)
			)
			
			await get_tree().create_timer(0.6).timeout
		else:
			print("CRITICAL ERROR: Ball Scene is missing!")
			

func _on_gate_button_pressed():
	print("--- BUTTON CLICKED ---") # If this doesn't show up, the signal is broken.
	var gate = find_child("ToggleGate", true, false)
	# ... rest of your code
	# 1. Search the whole game for the node named "ToggleGate"
	
	
	if gate:
		var collision = gate.get_node_or_null("CollisionShape2D")
		var sprite = gate.get_node_or_null("Sprite2D")
		
		if collision and sprite:
			# 2. Toggle the state
			var is_now_disabled = !collision.disabled
			collision.set_deferred("disabled", is_now_disabled)
			
			# 3. Visual feedback
			if is_now_disabled:
				sprite.modulate.a = 0.3 # Make it faint (Open)
				print("GATE OPEN")
			else:
				sprite.modulate.a = 1.0 # Make it solid (Closed)
				print("GATE CLOSED")
		else:
			print("ERROR: ToggleGate is missing a CollisionShape or Sprite!")
	else:
		print("ERROR: Could not find a node named ToggleGate in the scene!")
