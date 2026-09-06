class_name ContentCatalog
extends RefCounted

const CONTENT_PATH := "res://data/content.json"

static func load_content() -> Dictionary:
	var file := FileAccess.open(CONTENT_PATH, FileAccess.READ)
	if file == null:
		push_error("Unable to open content catalog: %s" % CONTENT_PATH)
		return {}

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Content catalog root must be a Dictionary")
		return {}

	return parsed as Dictionary

static func get_task(content: Dictionary, task_id: String) -> Dictionary:
	return content.get("tasks", {}).get(task_id, {}) as Dictionary

static func get_story_event(content: Dictionary, event_id: String) -> Dictionary:
	return content.get("story_events", {}).get(event_id, {}) as Dictionary

static func get_event_for_task(content: Dictionary, task_id: String) -> Dictionary:
	var task: Dictionary = get_task(content, task_id)
	var event_id: String = str(task.get("completion_event_id", ""))
	return get_story_event(content, event_id)
