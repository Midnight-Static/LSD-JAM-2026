extends Node

# Remember whether the player has finished the dream
var dream_completed: bool = false

# Remember where the player was before entering the dream
var museum_position: Vector3 = Vector3.ZERO
var museum_rotation: Vector3 = Vector3.ZERO
var museum_head_rotation: Vector3 = Vector3.ZERO

# Whether the player should be returned to their previous position
var returning_from_dream: bool = false

# Save the player's position before entering a dream
func save_museum_position(player: CharacterBody3D) -> void:
	museum_position = player.global_position
	museum_rotation = player.rotation
	museum_head_rotation = player.get_node("Head").rotation

# Mark the dream as complete before returning to the museum
func complete_dream() -> void:
	dream_completed = true
	returning_from_dream = true
