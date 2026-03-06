extends HBoxContainer

# How tall (in pixels) the bar with the most balls will be
@export var max_bar_height: float = 200.0 

var bucket_counts: Array[int] = []

func _ready():
	# Automatically sizes the array to 14 based on your children
	bucket_counts.resize(get_child_count())
	bucket_counts.fill(0)
	_update_bars()

# This is the function our main level script will call
func add_to_bucket(bucket_index: int):
	# Safety check to ensure the index is between 0 and 13
	if bucket_index >= 0 and bucket_index < bucket_counts.size():
		bucket_counts[bucket_index] += 1
		_update_bars()

func _update_bars():
	var highest_count = bucket_counts.max()
	
	for i in range(get_child_count()):
		var bar = get_child(i) as ColorRect
		if highest_count > 0:
			# Scale the bar based on the bucket with the highest count
			var height_ratio = float(bucket_counts[i]) / float(highest_count)
			bar.custom_minimum_size.y = height_ratio * max_bar_height
		else:
			bar.custom_minimum_size.y = 0
