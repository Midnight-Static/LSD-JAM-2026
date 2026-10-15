extends StaticBody3D

# Reference to the dialogue UI in the current scene
@onready var dialogue_ui = get_tree().current_scene.get_node("DialogueUI")

# Called when the player presses E on this button
func interact() -> void:
	dialogue_ui.show_dialogue()
