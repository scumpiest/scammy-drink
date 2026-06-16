class_name CraftingComplete

extends Sprite2D

var base_path: String = "res://assets/Drinks/"
@onready var drink_marker: Marker2D = $DrinkMarker
static var png_path: String

var img = Image.new()

# Called when the node enters the scene tree for the first time.
# res://assets/drinks/Apfelschorle.png
func _ready() -> void:
	var full_path: String = base_path + png_path
	img.load_from_file(full_path)
	
	var img_texture: CompressedTexture2D = load(full_path)
	texture = img_texture
	
	position.x = drink_marker.position.x
	position.y = drink_marker.position.y

static func _set_path(path:String) -> void:
	png_path = path

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
