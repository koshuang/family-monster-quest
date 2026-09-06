extends Control

const SAMPLE_TASK_ID := "read_20"

var is_parent_mode := true
var task_confirmed := false
var encounter_ready := false
var creature_captured := false

var content: Dictionary = {}
var sample_task: Dictionary = {}
var story_event: Dictionary = {}
var encountered_creature: Dictionary = {}
var collection := CollectionState.new()

var mode_label: Label
var status_label: Label
var mode_button: Button
var action_button: Button
var collection_label: Label

func _ready() -> void:
	_load_content()
	_build_ui()
	_refresh_ui()

func _load_content() -> void:
	content = ContentCatalog.load_content()
	sample_task = ContentCatalog.get_task(content, SAMPLE_TASK_ID)
	story_event = ContentCatalog.get_event_for_task(content, SAMPLE_TASK_ID)
	var creature_id: String = str(story_event.get("creature_id", ""))
	encountered_creature = ContentCatalog.get_creature(content, creature_id)

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.name = "PrototypeUI"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 48)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(root)

	var title := Label.new()
	title.name = "Title"
	title.text = "Family Monster Quest"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	root.add_child(title)

	var subtitle := Label.new()
	subtitle.name = "Subtitle"
	subtitle.text = "Real-world actions unlock adventures."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(subtitle)

	mode_label = Label.new()
	mode_label.name = "ModeLabel"
	mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(mode_label)

	mode_button = Button.new()
	mode_button.name = "ModeButton"
	mode_button.text = "Switch Parent / Child Mode"
	mode_button.pressed.connect(_toggle_mode)
	root.add_child(mode_button)

	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(status_label)

	action_button = Button.new()
	action_button.name = "ActionButton"
	action_button.pressed.connect(_advance_happy_path)
	root.add_child(action_button)

	collection_label = Label.new()
	collection_label.name = "CollectionLabel"
	collection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(collection_label)

func _toggle_mode() -> void:
	is_parent_mode = not is_parent_mode
	_refresh_ui()

func _advance_happy_path() -> void:
	if is_parent_mode and not task_confirmed:
		task_confirmed = true
		encounter_ready = true
		_refresh_ui()
		return

	if not is_parent_mode and encounter_ready and not creature_captured:
		var creature_id: String = str(story_event.get("creature_id", ""))
		creature_captured = collection.capture(creature_id)
		if creature_captured:
			encounter_ready = false
		_refresh_ui()

func _refresh_ui() -> void:
	mode_label.text = "Mode: Parent (GM)" if is_parent_mode else "Mode: Child (Adventurer)"
	var creature_name: String = str(encountered_creature.get("name", "Unknown creature"))

	if is_parent_mode:
		if task_confirmed:
			status_label.text = str(story_event.get("parent_confirmed_text", "Task confirmed."))
			action_button.text = "Task already confirmed"
			action_button.disabled = true
		else:
			status_label.text = "Task: %s. Confirm when completed." % str(sample_task.get("title", "Unknown task"))
			action_button.text = "Confirm task completion"
			action_button.disabled = false
	else:
		if creature_captured:
			status_label.text = "The forest is calm again. Your new companion is safe in the collection."
			action_button.text = "Adventure complete"
			action_button.disabled = true
		elif encounter_ready:
			status_label.text = str(story_event.get("child_encounter_text", "An encounter is waiting."))
			action_button.text = "Capture %s" % creature_name
			action_button.disabled = false
		else:
			status_label.text = "Nothing unusual is happening yet. Check back after a real-world quest is completed."
			action_button.text = "Explore"
			action_button.disabled = true

	collection_label.text = _collection_summary()

func _collection_summary() -> String:
	var creatures: Dictionary = ContentCatalog.get_creatures(content)
	if collection.count() == 0:
		return "Creature collection: 0 / %d" % creatures.size()

	var names: Array[String] = []
	for creature_id: String in collection.ids():
		var creature: Dictionary = ContentCatalog.get_creature(content, creature_id)
		names.append(str(creature.get("name", creature_id)))
	return "Creature collection: %s ✓ (%d / %d)" % [", ".join(names), collection.count(), creatures.size()]
