extends StaticBody3D

# The scene that this button sends the player to
@export_file("*.tscn") var destination_scene: String

# Called when the player looks at this button and presses E
func interact() -> void:
	if destination_scene != "":
		get_tree().change_scene_to_file(destination_scene)
