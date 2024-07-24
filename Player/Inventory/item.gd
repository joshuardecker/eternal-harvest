extends Node

## Objects that I want to be picked up by the player
## and added to their inventory must be this class.
class_name Item

## When creating an item, make sure to set these variables.
var texture: Sprite2D
var item_name: String

func get_texture() -> Sprite2D:
	# If a texture has not been set.
	if not texture:
		push_error("This item does not have a set texture!")
		
	return texture
	
func get_item_name() -> String:
	if not item_name:
		push_error("This item does not have a set name!")
		
	return item_name
