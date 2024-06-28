extends Area2D

## The reason this class exists is so that the health component can search for it.
## If the health component looked for just an area2d, unexpected behavior
## may occur.
class_name Hitbox

## When this hitbox is entered, how much damage does it do?
@export var damage: float = 0
