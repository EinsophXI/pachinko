extends Area2D

# Future-proofing: This exposes a field in the Godot Inspector.
# Set this to 2 for your doubling buckets, 0 for your removal buckets, 
# or 10 if you want a crazy jackpot bucket later!
@export var balls_to_spawn: int = 2

# Drag and drop your Ball.tscn into this slot in the Inspector
@export var ball_scene: PackedScene 

func _on_body_entered(body):
	# Check if the object entering is actually a ball
	if body.is_in_group("ball"): 
		
		# 1. Destroy the ball that just entered the bucket
		body.queue_free()
		
		# 2. Spawn the new balls (if balls_to_spawn is 0, this loop just won't run)
		spawn_new_balls(body.global_position)

func spawn_new_balls(spawn_position: Vector2):
	for i in range(balls_to_spawn):
		var new_ball = ball_scene.instantiate()
		
		# We use call_deferred to add the ball safely. 
		# Adding physics bodies directly during a collision signal causes errors.
		get_tree().current_scene.call_deferred("add_child", new_ball)
		
		# Add a slight random offset so multiple balls don't spawn 
		# at the exact same pixel and violently explode apart due to physics
		var random_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		
		# Set the new ball's position
		# Using call_deferred for the position as well ensures it applies after the node is in the tree
		new_ball.set_deferred("global_position", spawn_position + random_offset)
