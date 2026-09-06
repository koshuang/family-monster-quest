extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
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

	if mode_button == null or action_button == null or status_label == null or collection_label == null:
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
	_expect(action_button.text == "Capture Cloudlet", "child sees capture action")
	_expect("Cloudlet" in status_label.text, "child sees creature encounter")

	action_button.pressed.emit()
	await process_frame
	_expect(main.creature_captured, "capture updates creature state")
	_expect(not main.encounter_ready, "encounter resolves after capture")
	_expect("Cloudlet ✓" in collection_label.text, "captured creature appears in collection")

	print("PASS: parent -> child -> forest encounter -> capture happy path")
	quit(0)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)

func _fail(message: String) -> void:
	push_error("FAIL: %s" % message)
	quit(1)
