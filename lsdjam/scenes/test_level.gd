extends Node3D

# Restore the player's previous position after completing a dream
func _ready() -> void:
	if GameState.returning_from_dream:
		var player: CharacterBody3D = $Player

		player.global_position = GameState.museum_position
		player.rotation = GameState.museum_rotation
		player.get_node("Head").rotation = GameState.museum_head_rotation
		player.velocity = Vector3.ZERO

		GameState.returning_from_dream = false
