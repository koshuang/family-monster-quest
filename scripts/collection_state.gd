class_name CollectionState
extends RefCounted

var _captured: Dictionary = {}

func capture(creature_id: String) -> bool:
	if creature_id.is_empty() or _captured.has(creature_id):
		return false
	_captured[creature_id] = true
	return true

func has(creature_id: String) -> bool:
	return _captured.has(creature_id)

func count() -> int:
	return _captured.size()

func ids() -> Array[String]:
	var result: Array[String] = []
	for creature_id: Variant in _captured.keys():
		result.append(str(creature_id))
	return result
