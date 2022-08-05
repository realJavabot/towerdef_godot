extends TextureButton

export (Resource) var tower_data

func _ready():
	texture_normal = tower_data.texture

