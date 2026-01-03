@tool

extends Node

func _ready() -> void:
	_process_all_atlases("res://")
	print("-- yay it worked --")

func _process_all_atlases(start_dir: String) -> void:
	var dir := DirAccess.open(start_dir)
	if not dir:
		printerr("Failed to open directory: ", start_dir)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = start_dir + "/" + file_name

		if dir.current_is_dir():
			_process_all_atlases(file_path) # w recursive
		else:
			if file_name.get_extension().to_lower() == "png":
				_handle_png(file_path)
				
		file_name = dir.get_next()
	dir.list_dir_end() # dunno if i need this

func _handle_png(png_path: String) -> void:
	var base = png_path.trim_suffix(".png")
	var xml_path = base + ".xml"
	var res_path = base + ".res"

	if not FileAccess.file_exists(xml_path): # no xml? not a spritesheet brah.
		return

	if FileAccess.file_exists(res_path): # already a .res file? who gaf brah.
		print("skipping: ", res_path)
		return

	var sprite_frames = _convert_sparrow_to_spriteframes(png_path, xml_path)
	if sprite_frames:
		var err = ResourceSaver.save(sprite_frames, res_path, ResourceSaver.FLAG_COMPRESS)
		if err != OK:
			printerr("FAILED!!!: ", res_path)
		else:
			print("saved: ", res_path)

func _convert_sparrow_to_spriteframes(png_path: String, xml_path: String) -> SpriteFrames:
	var xml_parser := XMLParser.new()
	xml_parser.open(xml_path)

	var frames := SpriteFrames.new()
	var texture := load(png_path)

	var cur_anim_name: String = ""
	var prev_frame_data: Dictionary = {}

	var err = xml_parser.read()
	while err == OK:
		if xml_parser.get_node_type() == XMLParser.NODE_ELEMENT and xml_parser.get_node_name() != "TextureAtlas":
			var name_attr := xml_parser.get_named_attribute_value("name")
			var loaded_anim_name := name_attr.left(name_attr.length() - 4)

			if cur_anim_name != loaded_anim_name:
				frames.add_animation(loaded_anim_name)
				frames.set_animation_loop(loaded_anim_name, false)
				frames.set_animation_speed(loaded_anim_name, 24)
				cur_anim_name = loaded_anim_name

			var region = Rect2(
				int(xml_parser.get_named_attribute_value("x")),
				int(xml_parser.get_named_attribute_value("y")),
				int(xml_parser.get_named_attribute_value("width")),
				int(xml_parser.get_named_attribute_value("height"))
			)
			#if xml_parser.has_attribute("rotated"):
				# region = Rect2(
					#int(xml_parser.get_named_attribute_value("y")),
					#int(texture.get_width() - int(xml_parser.get_named_attribute_value("x")) - int(xml_parser.get_named_attribute_value("width"))),
					#int(xml_parser.get_named_attribute_value("height")),
					#int(xml_parser.get_named_attribute_value("width"))
				#)
			#else:
				# region = Rect2(
					#int(xml_parser.get_named_attribute_value("x")),
					#int(xml_parser.get_named_attribute_value("y")),
					#int(xml_parser.get_named_attribute_value("width")),
					#int(xml_parser.get_named_attribute_value("height"))
				#)

			var margin := Rect2()
			if xml_parser.has_attribute("frameX"):
				if not xml_parser.has_attribute("rotated"):
					margin = Rect2(
						-int(xml_parser.get_named_attribute_value("frameX")),
						-int(xml_parser.get_named_attribute_value("frameY")),
						int(xml_parser.get_named_attribute_value("frameWidth")) - region.size.x,
						int(xml_parser.get_named_attribute_value("frameHeight")) - region.size.y
					)
				else:
					margin = Rect2(
						-int(xml_parser.get_named_attribute_value("frameX")),
						-int(xml_parser.get_named_attribute_value("frameY")),
						int(xml_parser.get_named_attribute_value("frameHeight")) - region.size.x,
						int(xml_parser.get_named_attribute_value("frameWidth")) - region.size.y
					)

			var num_frames := frames.get_frame_count(cur_anim_name)
			var prev_frame = null
			if num_frames > 0:
				prev_frame = frames.get_frame_texture(cur_anim_name, num_frames - 1)

			#var use_prev = prev_frame and prev_frame_data.has("region") and prev_frame_data.has("margin")
			var use_prev = not true


			if use_prev:
				frames.add_frame(cur_anim_name, prev_frame)
			else:
				var new_frame := AtlasTexture.new()
				new_frame.atlas = texture
				new_frame.region = region
				new_frame.margin = margin
				new_frame.filter_clip = true

				if xml_parser.has_attribute("rotated"):
					var img := new_frame.get_image()
					img.rotate_90(COUNTERCLOCKWISE)
					new_frame.atlas = ImageTexture.create_from_image(img)
					new_frame.region = Rect2(Vector2.ZERO, new_frame.atlas.get_size())

				prev_frame_data = {
					"region": region,
					"margin": margin
				}
				frames.add_frame(cur_anim_name, new_frame)

		err = xml_parser.read()

	return frames
