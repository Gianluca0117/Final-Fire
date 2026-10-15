class_name SolidBlock
extends StaticBody2D
## Bloque sólido y seguro (repisas, paredes). El tamaño crea su colisión.

@export var size := Vector2(160, 40)


func _ready() -> void:
	collision_layer = PhysicsLayers.WORLD
	collision_mask = 0
	var shape := RectangleShape2D.new()
	shape.size = size
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)


func top_y() -> float:
	return global_position.y - size.y * 0.5
