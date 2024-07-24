extends Node

## The inventory of the player. Will except any 'item' class type.
class_name Inventory

var items: Array[Item]

func add_item(item: Item):
	items.append(item)

# If the item does not exist in the inventory, 
# nothing will happen.
func remove_item(item: Item):
	items.erase(item)
	
# Returns a copy of the inventory.
func get_inventory() -> Array[Item]:
	return items
