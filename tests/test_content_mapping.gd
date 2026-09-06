extends SceneTree

func _initialize() -> void:
	var content := ContentCatalog.load_content()
	var task := ContentCatalog.get_task(content, "read_20")
	var event := ContentCatalog.get_event_for_task(content, "read_20")

	_expect(not task.is_empty(), "sample task exists")
	_expect(task.get("title") == "Read for 20 minutes", "sample task title comes from data")
	_expect(task.get("completion_event_id") == "whispering_forest_light", "task maps to expected event id")
	_expect(not event.is_empty(), "mapped story event exists")
	_expect(event.get("location") == "Whispering Forest", "story event location is data-driven")
	_expect(event.get("creature_id") == "cloudlet", "story event maps to expected creature")
	_expect("Whispering Forest" in str(event.get("parent_confirmed_text", "")), "parent event text comes from mapped event")

	print("PASS: task data resolves to expected story event")
	quit(0)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error("FAIL: %s" % message)
		quit(1)
