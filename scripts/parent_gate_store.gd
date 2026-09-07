class_name ParentGateStore
extends RefCounted

const DEFAULT_PATH := "user://family_monster_quest_parent_gate.json"

static func has_pin(path: String = DEFAULT_PATH) -> bool:
	return not load_hash(path).is_empty()

static func save_pin(pin: String, path: String = DEFAULT_PATH) -> bool:
	if not is_valid_pin(pin):
		return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Unable to open parent gate file for writing: %s" % path)
		return false
	file.store_string(JSON.stringify({"pin_hash": pin.sha256_text()}))
	return true

static func verify_pin(pin: String, path: String = DEFAULT_PATH) -> bool:
	var stored_hash := load_hash(path)
	return not stored_hash.is_empty() and pin.sha256_text() == stored_hash

static func load_hash(path: String = DEFAULT_PATH) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return ""
	return str((parsed as Dictionary).get("pin_hash", ""))

static func is_valid_pin(pin: String) -> bool:
	return pin.length() == 4 and pin.is_valid_int()

static func reset(path: String = DEFAULT_PATH) -> bool:
	if not FileAccess.file_exists(path):
		return true
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK
