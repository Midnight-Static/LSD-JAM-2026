extends StaticBody3D

# Dialogue shown when the player finds the artifact
@export_multiline var artifact_dialogue: String = "You found the dream artifact.\nPlaceholder Text...\nAlso, you're still gay."

# Called when the player presses E on the artifact
func interact() -> void:
	var dialogue_ui = get_tree().current_scene.get_node("DialogueUI")
	dialogue_ui.start_dialogue(artifact_dialogue, finish_dream)


# Complete the dream and return to the museum
func finish_dream() -> void:
	GameState.complete_dream()
	get_tree().change_scene_to_file.call_deferred("res://scenes/test_level.tscn")
