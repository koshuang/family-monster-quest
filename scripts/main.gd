extends Control

const SAMPLE_TASK_ID := "read_20"
const LOCATION_HOME := "home"
const LOCATION_FOREST := "forest"

var is_parent_mode := true
var task_confirmed := false
var encounter_ready := false
var creature_captured := false
var current_location := LOCATION_HOME
var reset_armed := false

var content: Dictionary = {}
var sample_task: Dictionary = {}
var story_event: Dictionary = {}
var encountered_creature: Dictionary = {}
var collection := CollectionState.new()

var mode_label: Label
var status_label: Label
var mode_button: Button
var action_button: Button
var reset_button: Button
var collection_label: Label
var world_panel: VBoxContainer
var location_label: Label
var world_signal_label: Label
var home_button: Button
var forest_button: Button

func _ready() -> void:
	_load_content()
	_load_progress()
	_build_ui()
	_refresh_ui()

func _load_content() -> void:
	content = ContentCatalog.load_content()
	sample_task = ContentCatalog.get_task(content, SAMPLE_TASK_ID)
	story_event = ContentCatalog.get_event_for_task(content, SAMPLE_TASK_ID)
	var creature_id: String = str(story_event.get("creature_id", ""))
	encountered_creature = ContentCatalog.get_creature(content, creature_id)

func _load_progress() -> void:
	var saved: Dictionary = SaveStore.load_state()
	if saved.is_empty():
		return

	task_confirmed = bool(saved.get("task_confirmed", false))
	encounter_ready = bool(saved.get("encounter_ready", false))
	var captured_ids: Variant = saved.get("captured_ids", [])
	if typeof(captured_ids) == TYPE_ARRAY:
		for creature_id: Variant in captured_ids:
			collection.capture(str(creature_id))

	var current_creature_id: String = str(story_event.get("creature_id", ""))
	creature_captured = collection.has(current_creature_id)
	if creature_captured:
		encounter_ready = false

func _save_progress() -> void:
	SaveStore.save_state({
		"task_confirmed": task_confirmed,
		"encounter_ready": encounter_ready,
		"captured_ids": collection.ids(),
	})

func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.name = "PrototypeUI"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 48)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 14)
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

	world_panel = VBoxContainer.new()
	world_panel.name = "WorldPanel"
	world_panel.alignment = BoxContainer.ALIGNMENT_CENTER
	world_panel.add_theme_constant_override("separation", 10)
	root.add_child(world_panel)

	var world_title := Label.new()
	world_title.name = "WorldTitle"
	world_title.text = "Adventure Map"
	world_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	world_title.add_theme_font_size_override("font_size", 22)
	world_panel.add_child(world_title)

	location_label = Label.new()
	location_label.name = "LocationLabel"
	location_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	location_label.add_theme_font_size_override("font_size", 18)
	world_panel.add_child(location_label)

	world_signal_label = Label.new()
	world_signal_label.name = "WorldSignalLabel"
	world_signal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	world_signal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	world_panel.add_child(world_signal_label)

	var locations := HBoxContainer.new()
	locations.name = "Locations"
	locations.alignment = BoxContainer.ALIGNMENT_CENTER
	locations.add_theme_constant_override("separation", 12)
	world_panel.add_child(locations)

	home_button = Button.new()
	home_button.name = "HomeButton"
	home_button.text = "🏠 Home"
	home_button.custom_minimum_size = Vector2(180, 72)
	home_button.pressed.connect(_go_home)
	locations.add_child(home_button)

	forest_button = Button.new()
	forest_button.name = "ForestButton"
	forest_button.custom_minimum_size = Vector2(240, 72)
	forest_button.pressed.connect(_go_forest)
	locations.add_child(forest_button)

	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(status_label)

	action_button = Button.new()
	action_button.name = "ActionButton"
	action_button.custom_minimum_size = Vector2(280, 64)
	action_button.pressed.connect(_advance_happy_path)
	root.add_child(action_button)

	reset_button = Button.new()
	reset_button.name = "ResetButton"
	reset_button.custom_minimum_size = Vector2(280, 52)
	reset_button.pressed.connect(_request_reset)
	root.add_child(reset_button)

	collection_label = Label.new()
	collection_label.name = "CollectionLabel"
	collection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(collection_label)

func _toggle_mode() -> void:
	is_parent_mode = not is_parent_mode
	current_location = LOCATION_HOME
	reset_armed = false
	_refresh_ui()

func _go_home() -> void:
	current_location = LOCATION_HOME
	_refresh_ui()

func _go_forest() -> void:
	if is_parent_mode:
		return
	current_location = LOCATION_FOREST
	_refresh_ui()

func _advance_happy_path() -> void:
	if is_parent_mode and not task_confirmed:
		task_confirmed = true
		encounter_ready = true
		_save_progress()
		_refresh_ui()
		return

	if not is_parent_mode and current_location == LOCATION_FOREST and encounter_ready and not creature_captured:
		var creature_id: String = str(story_event.get("creature_id", ""))
		creature_captured = collection.capture(creature_id)
		if creature_captured:
			encounter_ready = false
			_save_progress()
		_refresh_ui()

func _request_reset() -> void:
	if not is_parent_mode:
		return
	if not reset_armed:
		reset_armed = true
		_refresh_ui()
		return
	_reset_playtest_progress()

func _reset_playtest_progress() -> void:
	SaveStore.reset()
	task_confirmed = false
	encounter_ready = false
	creature_captured = false
	current_location = LOCATION_HOME
	collection = CollectionState.new()
	reset_armed = false
	_refresh_ui()

func _refresh_ui() -> void:
	mode_label.text = "Mode: Parent (GM)" if is_parent_mode else "Mode: Child (Adventurer)"
	world_panel.visible = not is_parent_mode
	reset_button.visible = is_parent_mode
	reset_button.text = "Confirm reset demo progress" if reset_armed else "Reset demo progress"
	var creature_name: String = str(encountered_creature.get("name", "Unknown creature"))
	forest_button.text = "🌲 Whispering Forest  ✨ !" if encounter_ready else "🌲 Whispering Forest"

	if is_parent_mode:
		if reset_armed:
			status_label.text = "Reset is armed. Press reset again to clear this demo's local progress."
		elif task_confirmed:
			status_label.text = str(story_event.get("parent_confirmed_text", "Task confirmed."))
			action_button.text = "Task already confirmed"
			action_button.disabled = true
		else:
			status_label.text = "Task: %s. Confirm when completed." % str(sample_task.get("title", "Unknown task"))
			action_button.text = "Confirm task completion"
			action_button.disabled = false
		if reset_armed:
			action_button.disabled = true
	else:
		_refresh_child_ui(creature_name)

	collection_label.text = _collection_summary()

func _refresh_child_ui(creature_name: String) -> void:
	if current_location == LOCATION_HOME:
		location_label.text = "You are at: 🏠 Home"
		home_button.disabled = true
		forest_button.disabled = false
		if encounter_ready:
			world_signal_label.text = "✨ The forest changed while you were away."
			status_label.text = "Something is glowing in Whispering Forest. Where do you want to explore?"
		else:
			world_signal_label.text = "The world is quiet."
			status_label.text = "You are home. Look around when the world changes."
		action_button.text = "Choose a place on the map"
		action_button.disabled = true
		return

	location_label.text = "You are at: 🌲 Whispering Forest"
	home_button.disabled = false
	forest_button.disabled = true
	if creature_captured:
		world_signal_label.text = "🌿 The strange glow has faded."
		status_label.text = "The forest is calm again. Your new companion is safe in the collection."
		action_button.text = "Adventure complete"
		action_button.disabled = true
	elif encounter_ready:
		world_signal_label.text = "✨ Something is moving between the trees!"
		status_label.text = str(story_event.get("child_encounter_text", "An encounter is waiting."))
		action_button.text = "Befriend %s" % creature_name
		action_button.disabled = false
	else:
		world_signal_label.text = "🌲 Leaves rustle in the breeze."
		status_label.text = "The trees rustle softly, but nothing unusual is here yet."
		action_button.text = "Nothing to investigate yet"
		action_button.disabled = true

func _collection_summary() -> String:
	var creatures: Dictionary = ContentCatalog.get_creatures(content)
	if collection.count() == 0:
		return "Creature collection: 0 / %d" % creatures.size()

	var names: Array[String] = []
	for creature_id: String in collection.ids():
		var creature: Dictionary = ContentCatalog.get_creature(content, creature_id)
		names.append(str(creature.get("name", creature_id)))
	return "Creature collection: %s ✓ (%d / %d)" % [", ".join(names), collection.count(), creatures.size()]
