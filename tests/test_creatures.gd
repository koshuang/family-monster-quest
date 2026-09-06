extends SceneTree

func _initialize() -> void:
	var content: Dictionary = ContentCatalog.load_content()
	var creatures: Dictionary = ContentCatalog.get_creatures(content)
	_expect(creatures.size() == 5, "exactly five MVP creatures exist")

	var required_fields: Array[String] = ["name", "theme", "rarity", "story"]
	for creature_id: Variant in creatures.keys():
		var id: String = str(creature_id)
		_expect(not id.is_empty(), "creature id is non-empty")
		var creature: Dictionary = ContentCatalog.get_creature(content, id)
		for field: String in required_fields:
			_expect(creature.has(field), "%s has %s" % [id, field])
			_expect(not str(creature.get(field, "")).is_empty(), "%s.%s is non-empty" % [id, field])

	var collection := CollectionState.new()
	_expect(collection.capture("cloudlet"), "first capture succeeds")
	_expect(not collection.capture("cloudlet"), "duplicate capture is rejected")
	_expect(collection.count() == 1, "duplicate capture does not increase collection count")
	_expect(collection.has("cloudlet"), "captured creature is present")
	_expect(collection.ids() == ["cloudlet"], "collection lists captured creature exactly once")

	print("PASS: five original creatures and duplicate-safe collection state")
	quit(0)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error("FAIL: %s" % message)
		quit(1)
