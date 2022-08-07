extends TextureButton

export (Resource) var tower_data

func _ready():
	texture_normal = tower_data.texture
	update()

func update():
	$RichTextLabel.bbcode_text = '[center]%d' % tower_data.cost
	
