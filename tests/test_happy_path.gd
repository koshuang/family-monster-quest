extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	SaveStore.reset()
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("Could not load main scene")
		return

	var main := packed.instantiate()
	root.add_child(main)
	await process_frame

	var ui := main.get_node_or_null("PrototypeUI")
	if ui == null:
		_fail("PrototypeUI missing")
		return

	var mode_button := ui.get_node_or_null("ModeButton") as Button
	var action_button := ui.get_node_or_null("ActionButton") as Button
	var status_label := ui.get_node_or_null("StatusLabel") as Label
	var collection_label := ui.get_node_or_null("CollectionLabel") as Label
	var world_panel := ui.get_node_or_null("WorldPanel") as VBoxContainer
	var location_label := world_panel.get_node_or_null("LocationLabel") as Label
	var world_signal_label := world_panel.get_node_or_null("WorldSignalLabel") as Label
	var forest_button := world_panel.get_node_or_null("Locations/ForestButton") as Button

	if mode_button == null or action_button == null or status_label == null or collection_label == null or forest_button == null or location_label == null or world_signal_label == null:
		_fail("Expected prototype controls are missing")
		return

	_expect(main.is_parent_mode, "starts in parent mode")
	_expect(not main.task_confirmed, "sample task starts unconfirmed")
	_expect(action_button.text == "Confirm task completion", "parent sees task confirmation action")

	action_button.pressed.emit()
	await process_frame
	_expect(main.task_confirmed, "parent confirmation updates task state")
	_expect(main.encounter_ready, "parent confirmation unlocks encounter")
	_expect("Whispering Forest" in status_label.text, "parent sees forest event evidence")

	mode_button.pressed.emit()
	await process_frame
	_expect(not main.is_parent_mode, "mode switches to child")
	_expect(main.current_location == main.LOCATION_HOME, "child starts from home")
	_expect(world_panel.visible, "child sees adventure map")
	_expect("Home" in location_label.text, "current location is explicit")
	_expect("changed" in world_signal_label.text, "world change cue is explicit")
	_expect("!" in forest_button.text, "forest signals pending world event")
	_expect(action_button.disabled, "encounter action is not exposed before entering forest")

	forest_button.pressed.emit()
	await process_frame
	_expect(main.current_location == main.LOCATION_FOREST, "child enters forest")
	_expect("Whispering Forest" in location_label.text, "forest location is explicit")
	_expect("moving" in world_signal_label.text, "forest encounter cue is explicit")
	_expect(action_button.text == "Befriend Cloudlet", "forest reveals companion action")
	_expect("Cloudlet" in status_label.text, "child sees creature encounter")

	action_button.pressed.emit()
	await process_frame
	_expect(main.creature_captured, "companion action captures creature in collection state")
	_expect(not main.encounter_ready, "encounter resolves after capture")
	_expect("Cloudlet ✓" in collection_label.text, "captured creature appears in collection")

	SaveStore.reset()
	print("PASS: parent -> child world cue -> forest encounter -> companion collection happy path")
	quit(0)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)

func _fail(message: String) -> void:
	push_error("FAIL: %s" % message)
	SaveStore.reset()
	quit(1)
