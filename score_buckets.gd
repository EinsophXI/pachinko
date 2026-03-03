extends Area2D

@export var bucket_score = 10

func _on_body_entered(body):
	if body is RigidBody2D:
		get_tree().current_scene.add_score(bucket_score)
