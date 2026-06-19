extends Node

const VO_ROOT: String = "res://assets/VO"

const PERSONA_PREFIX: Dictionary = {
	"axolotl": "Axolotl",
	"fish": "Fish",
	"seal": "Seal",
	"shark": "Shark",
}

const HELLO_SUFFIX: Dictionary = {
	"seal": "Heyaaa",
	"fish": "Hi",
	"axolotl": "hi",
	"shark": "hi",
}

const INGREDIENT_VO_SLUGS: Dictionary = {
	"pineapple": "pinneaple",
}

# Keys: "persona|event_name|ingredient" — values are full .wav filenames.
const FULL_FILENAME_OVERRIDES: Dictionary = {
	"seal|wrong_ingredient|mixed_fruits": "Seal wrong mixed fruit.wav",
	"seal|wrong_ingredient|white_wine": "Seal wrong white whine.wav",
	"shark|wrong_ingredient|orange": "Shark wrong orange juice.wav",
}

var _stream_cache: Dictionary = {}


func get_customer_voice(persona: String, event_name: String, params: Dictionary = {}) -> AudioStream:
	var path: String = get_customer_voice_path(persona, event_name, params)
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	if _stream_cache.has(path):
		return _stream_cache[path]
	var stream: AudioStream = load(path)
	_stream_cache[path] = stream
	return stream


func has_customer_voice(persona: String, event_name: String, params: Dictionary = {}) -> bool:
	var path: String = get_customer_voice_path(persona, event_name, params)
	return not path.is_empty() and ResourceLoader.exists(path)


func get_customer_voice_path(persona: String, event_name: String, params: Dictionary = {}) -> String:
	if not PERSONA_PREFIX.has(persona):
		return ""

	var resolved_event: String = event_name
	if event_name == "thx_failed":
		resolved_event = "thx_bad"

	var ingredient: String = str(params.get("ingredient", ""))
	var override_key: String = "%s|%s|%s" % [persona, resolved_event, ingredient]
	var filename: String = FULL_FILENAME_OVERRIDES.get(override_key, _build_filename(persona, resolved_event, ingredient))
	if filename.is_empty():
		return ""

	var folder: String = PERSONA_PREFIX[persona]
	return "%s/%s/%s" % [VO_ROOT, folder, filename]


func _build_filename(persona: String, event_name: String, ingredient: String) -> String:
	var prefix: String = PERSONA_PREFIX[persona]
	var suffix: String = _build_suffix(persona, event_name, ingredient)
	if suffix.is_empty():
		return ""
	return "%s %s.wav" % [prefix, suffix]


func _build_suffix(persona: String, event_name: String, ingredient: String) -> String:
	match event_name:
		"hello":
			return HELLO_SUFFIX.get(persona, "hi")
		"my_drink?":
			return "my drink"
		"wrong_ingredient":
			if ingredient.is_empty():
				return ""
			return "wrong %s" % _ingredient_to_vo_slug(ingredient)
		"right_ingredient":
			if ingredient.is_empty():
				return ""
			return "add %s" % _ingredient_to_vo_slug(ingredient)
		"thx_1":
			return "thx1"
		"thx_2":
			return "thx2"
		"thx_3":
			return "thx3"
		"thx_bad":
			return "thx bad"
		_:
			return ""


func _ingredient_to_vo_slug(ingredient_key: String) -> String:
	if INGREDIENT_VO_SLUGS.has(ingredient_key):
		return INGREDIENT_VO_SLUGS[ingredient_key]
	return ingredient_key.replace("_", " ")
