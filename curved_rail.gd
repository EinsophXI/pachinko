extends StaticBody2D

# These names MUST match your Scene Tree exactly
@onready var path_node = get_node_or_null("Path2D")
@onready var line_node = get_node_or_null("Line2D")

func _ready():
	# This check prevents the "null instance" error
	if path_node == null or line_node == null:
		print("ERROR: Check your node names! Script expected 'Path2D' and 'Line2D'")
		return

	# This check prevents the error if you haven't drawn the curve yet
	if path_node.curve == null or path_node.curve.point_count < 2:
		print("ERROR: Please draw at least two points on your Path2D curve.")
		return

	var points = path_node.curve.tessellate()

	# Set up the visual line
	line_node.points = points
	line_node.width = 8.0
	line_node.default_color = Color.CYAN # Change to your favorite color
	line_node.antialiased = true

	# Set up the collision
	var collision_poly = CollisionPolygon2D.new()
	add_child(collision_poly)
	
	var thickness = 12.0
	var poly_points = PackedVector2Array()
	
	# Create a 'loop' to give the line actual physical thickness
	for p in points:
		poly_points.append(p)
	for i in range(points.size() - 1, -1, -1):
		poly_points.append(points[i] + Vector2(thickness, 0)) 
		
	collision_poly.polygon = poly_points
	print("Curve successfully generated!")
