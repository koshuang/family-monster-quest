extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_expect(SaveStore.reset(), "development reset succeeds")
	_expect(SaveStore.load_state().is_empty(), "missing save falls back to empty state")

	var first := _new_main()
	await process_frame
	var first_ui := first.get_node("PrototypeUI")
	var first_mode_button := first_ui.get_node("ModeButton") as Button
	var first_action_button := first_ui.get_node("ActionButton") as Button
	var first_forest_button := first_ui.get_node("WorldPanel/Locations/ForestButton") as Button

	first_action_button.pressed.emit()
	await process_frame
	first_mode_button.pressed.emit()
	await process_frame
	first_forest_button.pressed.emit()
	await process_frame
	first_action_button.pressed.emit()
	await process_frame
	_expect(first.creature_captured, "first session captures creature")
	_expect(FileAccess.file_exists(SaveStore.DEFAULT_PATH), "capture creates local save")

	first.queue_free()
	await process_frame

	var second := _new_main()
	await process_frame
	_expect(second.task_confirmed, "task confirmation survives restart")
	_expect(second.creature_captured, "captured creature survives restart")
	_expect(not second.encounter_ready, "consumed encounter does not replay")
	_expect(second.collection.has("cloudlet"), "collection is restored from save")
	var second_ui := second.get_node("PrototypeUI")
	var collection_label := second_ui.get_node("CollectionLabel") as Label
	_expect("Cloudlet" in collection_label.text, "restored collection is visible in UI")

	second.queue_free()
	await process_frame

	var corrupt_file := FileAccess.open(SaveStore.DEFAULT_PATH, FileAccess.WRITE)
	_expect(corrupt_file != null, "test can create corrupt save fixture")
	corrupt_file.store_string("{not valid json")
	corrupt_file.close()

	var third := _new_main()
	await process_frame
	_expect(not third.task_confirmed, "corrupt save falls back to initial task state")
	_expect(not third.creature_captured, "corrupt save falls back to empty collection")
	third.queue_free()
	await process_frame

	_expect(SaveStore.reset(), "development reset removes save")
	print("PASS: local progress survives restart and corrupt saves fall back safely")
	quit(0)

func _new_main() -> Node:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		push_error("FAIL: Could not load main scene")
		quit(1)
		return Node.new()
	var main := packed.instantiate()
	root.add_child(main)
	return main

func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error("FAIL: %s" % message)
		SaveStore.reset()
		quit(1)
