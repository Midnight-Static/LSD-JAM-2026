extends StaticBody3D

# The scene that this button sends the player to
@export_file("*.tscn") var destination_scene: String

# Text shown when the dream has already been completed
@export_multiline var completed_text: String = "Dream completed."

# Called when the player looks at this button and presses E
func interact() -> void:
	if GameState.dream_completed:
		var dialogue_ui = get_tree().current_scene.get_node("DialogueUI")
		dialogue_ui.start_dialogue(completed_text)
		return

	var player = get_tree().current_scene.get_node("Player")
	GameState.save_museum_position(player)

	if destination_scene != "":
		get_tree().change_scene_to_file.call_deferred(destination_scene)
