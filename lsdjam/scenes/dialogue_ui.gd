extends CanvasLayer

# References to the dialogue box and its text
@onready var panel: PanelContainer = $PanelContainer
@onready var dialogue_text: Label = $PanelContainer/MarginContainer/Label

# Store the dialogue lines and which one we're currently displaying
var dialogue_lines: Array[String] = []
var default_dialogue: String = ""
var current_line: int = 0
var dialogue_open: bool = false

# Optional action to run after the dialogue finishes
var finished_action: Callable

# Hide the dialogue box when the scene starts
func _ready() -> void:
	default_dialogue = dialogue_text.text
	panel.hide()

# Start dialogue using the text written in the Label
func show_dialogue() -> void:
	start_dialogue(default_dialogue)


# Start dialogue using text provided by an interactable object
func start_dialogue(message: String, on_finished: Callable = Callable()) -> void:
	dialogue_lines.clear()

	for line in message.split("\n"):
		if not line.strip_edges().is_empty():
			dialogue_lines.append(line.strip_edges())

	if dialogue_lines.is_empty():
		return

	finished_action = on_finished
	current_line = 0
	dialogue_open = true

	dialogue_text.text = dialogue_lines[current_line]
	panel.show()

# Advance the dialogue, or close it after the final line
func next_dialogue() -> void:
	if not dialogue_open:
		return

	current_line += 1

	if current_line >= dialogue_lines.size():
		dialogue_open = false
		panel.hide()

		if finished_action.is_valid():
			var action: Callable = finished_action
			finished_action = Callable()
			action.call()
	else:
		dialogue_text.text = dialogue_lines[current_line]
