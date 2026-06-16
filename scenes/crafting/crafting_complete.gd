class_name crafting_complete

extends Sprite2D

var base_path: String = "res://assets/drinks/"
static var png_path: String

var img = Image.new()

# Called when the node enters the scene tree for the first time.
# res://assets/drinks/Apfelschorle.png
func _ready() -> void:
	var full_path: String = base_path + png_path
	img.load_from_file(full_path)
	print(img)
	texture = ImageTexture.create_from_image(img)
	print("Loaded Thing :Thumbs_up_emoji:")

static func _set_path(path:String) -> void:
	png_path = path

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
