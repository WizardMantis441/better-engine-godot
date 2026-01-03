extends Node

@export_file_path('*.json') var json_path : String
@onready var json = JSON.parse_string(FileAccess.open(json_path, FileAccess.READ).get_as_text())
var root = Stage.new()
var asset_path = ''

func _ready():
	var asset_path_arr = json_path.split('/')
	asset_path_arr.remove_at(asset_path_arr.size()-1)
	asset_path = '/'.join(asset_path_arr) + '/'
	print(asset_path)
	
	root.name = json.name
	root.camera_zoom = json.cameraZoom
	
	root.player_position = Vector2(json.characters.bf.position[0],json.characters.bf.position[1])
	root.player_camera_offset = Vector2(json.characters.bf.cameraOffsets[0],json.characters.bf.cameraOffsets[1])
	root.player_z_index = json.characters.bf.zIndex
	
	root.opponent_position = Vector2(json.characters.dad.position[0],json.characters.dad.position[1])
	root.opponent_camera_offset = Vector2(json.characters.dad.cameraOffsets[0],json.characters.dad.cameraOffsets[1])
	root.opponent_z_index = json.characters.dad.zIndex
	
	root.gf_position = Vector2(json.characters.gf.position[0],json.characters.gf.position[1])
	root.gf_camera_offset = Vector2(json.characters.gf.cameraOffsets[0],json.characters.gf.cameraOffsets[1])
	root.gf_z_index = json.characters.gf.zIndex
	
	var props : Array = json.props.duplicate()
	
	for prop_index in props.size():
		var prop = props[prop_index]
		var prop_asset_path = prop.assetPath.split('/')[-1]
		var prop_obj
		if prop.has('animations'): # is animated
			prop_obj = FunkinSprite.new()
			prop_obj.name = prop.name
			prop_obj.centered = false
			prop_obj.sprite_frames = load(asset_path+prop_asset_path+'.xml')
			prop_obj.position = Vector2(prop.position[0],prop.position[1]) if prop.has('position') else Vector2.ZERO
			prop_obj.scale = Vector2(prop.scale[0],prop.scale[1]) if prop.has('scale') else Vector2.ONE
			prop_obj.z_index = prop.zIndex if prop.has('zIndex') else 0
			
			# The playing of animations is left as en exercise for the reader.
			
			#var anim_name = prop.startingAnimation
			#for i in prop_obj.sprite_frames.get_animation_names():
				#if i.begins_with(prop.startingAnimation):
					#anim_name = i
			#prop_obj.play(anim_name)
			
			if prop.has('danceEvery'):
				prop_obj.dance_every = prop.danceEvery * 4
			
		elif prop_asset_path.begins_with('#'): # color rect
			prop_obj = ColorRect.new()
			prop_obj.name = prop.name
			prop_obj.color = Color(prop_asset_path)
			prop_obj.position = Vector2(prop.position[0],prop.position[1]) if prop.has('position') else Vector2.ZERO
			prop_obj.size = Vector2(prop.scale[0],prop.scale[1]) if prop.has('scale') else Vector2.ONE
			prop_obj.z_index = prop.zIndex if prop.has('zIndex') else 0
			
		else: # static sprite
			prop_obj = Sprite2D.new()
			prop_obj.name = prop.name
			prop_obj.centered = false
			prop_obj.texture = load(asset_path+prop_asset_path+'.png')
			prop_obj.position = Vector2(prop.position[0],prop.position[1]) if prop.has('position') else Vector2.ZERO
			prop_obj.scale = Vector2(prop.scale[0],prop.scale[1]) if prop.has('scale') else Vector2.ONE
			prop_obj.z_index = prop.zIndex if prop.has('zIndex') else 0
		
		if prop.has('scroll') and not (prop.scroll[0] == 1.0 and prop.scroll[1] == 1.0):
			var scroll_obj = Parallax2D.new()
			scroll_obj.scroll_scale = Vector2(prop.scroll[0],prop.scroll[1])
			scroll_obj.name = prop.name
			scroll_obj.add_child(prop_obj)
			root.add_child(scroll_obj)
			prop_obj.owner = root
			scroll_obj.owner = root
		else:
			prop_obj.name = prop.name
			root.add_child(prop_obj)
			prop_obj.owner = root
	
	#add_child(root)
	
	var saved = PackedScene.new()
	saved.pack(root)
	ResourceSaver.save(saved, asset_path.path_join('scene.tscn'))
