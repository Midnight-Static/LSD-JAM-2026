extends CanvasLayer

# References to the dialogue box and its text
@onready var panel: PanelContainer = $PanelContainer
@onready var dialogue_text: Label = $PanelContainer/MarginContainer/Label

# Store the dialogue lines and which one we're currently displaying
var dialogue_lines: Array[String] = []
var current_line: int = 0
var dialogue_open: bool = false


# Hide the dialogue box when the scene starts
func _ready() -> void:
	# Read the dialogue written in the Label before hiding it
	var written_text: String = dialogue_text.text

	for line in written_text.split("\n"):
		if not line.strip_edges().is_empty():
			dialogue_lines.append(line.strip_edges())

	panel.hide()


# Start the dialogue when the player interacts
func show_dialogue() -> void:
	if dialogue_lines.is_empty():
		return

	current_line = 0
	dialogue_open = true
	dialogue_text.text = dialogue_lines[current_line]
	panel.show()


# Move to the next line, or close the dialogue when finished
func next_dialogue() -> void:
	if not dialogue_open:
		return

	current_line += 1

	if current_line >= dialogue_lines.size():
		dialogue_open = false
		panel.hide()
	else:
		dialogue_text.text = dialogue_lines[current_line]
