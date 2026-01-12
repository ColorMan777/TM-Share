extends Node ### THIS IS THE MAIN SINGLETON ###

const trackmania_maps_path = "Maps/My Maps/" #TM2020 Maps path

var config = ConfigFile.new()

var gbx_file
var trackmania_path:String #TM2020 Directory Path
var default_trackmania_path:String
var maps_path:String #TM2020 maps path

var import_logs_label:RichTextLabel

func _ready() -> void:
	get_tree().root.set_min_size(Vector2i(700,500))
	
	default_trackmania_path = get_trackmania_path(false)
	
	if config.load("user://config.cfg") != OK: #if config not exist get auto trackmania path
		trackmania_path = get_trackmania_path()
		config_init() # store trackmania path
		if trackmania_maps_path != "":
			maps_path = get_trackmania_path() + trackmania_maps_path
	else: # else load config
		if DirAccess.dir_exists_absolute(config.get_value("PATHS", "trackmania_path")):
			trackmania_path = config.get_value("PATHS", "trackmania_path")
			if trackmania_path.ends_with("Trackmania") or trackmania_path.ends_with("Trackmania2020"):
				maps_path = trackmania_path + "/" + trackmania_maps_path
			if trackmania_path.ends_with("Trackmania/") or trackmania_path.ends_with("Trackmania2020/"):
				maps_path = trackmania_path + trackmania_maps_path
		else:
			trackmania_path = config.get_value("PATHS", "trackmania_path") + " - DOES NO EXIST -"

		
	#print(trackmania_path)
	
	#var xml = parse_gbx("res://Assets/LevelDesign_Exercise01.Map.Gbx")
	#var xml = parse_gbx(trackmania_path + "Circuit XUS.Challenge.Gbx")
	#print(xml)
	
	#print(list_maps())
	#list_maps()

func config_init():
	config.set_value("PATHS", "trackmania_path", trackmania_path)
	config.save("user://config.cfg")

func update_trackmania_path(new_path:String):
	trackmania_path = new_path
	config_init()
	maps_path = trackmania_path + "/" +  trackmania_maps_path

func get_trackmania_path(verify_exist=true): # return empty string if nothing is found
	
	var p_final = ""
	
	match OS.get_name():
		"Windows":
			var p = DirAccess.get_drive_count() #list Windows C / D / etc
			for i in p:
				if DirAccess.get_drive_name(i) == "C:": #if C: check user / documents
					var p2 = ProjectSettings.globalize_path("user://")
					p2 = p2.erase(p2.length() - "AppData/Roaming/Godot/app_userdata/TM-Share/".length(), "AppData/Roaming/Godot/app_userdata/TM-Share/".length())
					if DirAccess.dir_exists_absolute(p2 + "Documents/Trackmania/"):
						p_final = p2 + "Documents/Trackmania/"
					if DirAccess.dir_exists_absolute(p2 + "Documents/Trackmania2020/"): #Trackmania 2020 folder first if it exists
						p_final = p2 + "Documents/Trackmania2020/"
					
				else: # else search Disk / Documents
					if DirAccess.dir_exists_absolute(DirAccess.get_drive_name(i) + "/Documents/Trackmania/") and verify_exist:
						p_final = DirAccess.get_drive_name(i) + "/Documents/Trackmania/"
					if DirAccess.dir_exists_absolute(DirAccess.get_drive_name(i) + "/Documents/Trackmania2020/") and verify_exist: # Trackmania 2020 if it exists will be prioritized
						p_final = DirAccess.get_drive_name(i) + "/Documents/Trackmania2020/"
						
					if not verify_exist and p_final == "":
						p_final = "D:/Documents/Trackmania/"
			
		"Linux":
			var p = ProjectSettings.globalize_path("user://") # get path to user Linux
			p = p.erase(p.length() - ".local/share/godot/app_userdata/TM-Share/".length(), ".local/share/godot/app_userdata/TM-Share/".length())
			p_final = p + ".steam/debian-installation/steamapps/compatdata/2225070/pfx/drive_c/users/steamuser/Documents/Trackmania/"
			# This is the steam path on Linux (with Trackmania SteamID)
			if not DirAccess.dir_exists_absolute(p_final) and verify_exist:
				p_final = ""
			elif not verify_exist:
				p_final = p + ".steam/debian-installation/steamapps/compatdata/2225070/pfx/drive_c/users/steamuser/Documents/Trackmania/"
			
	if not p_final.ends_with("/") and not p_final == "":
		p_final = p_final + "/"
		
	return p_final

func list_maps(complete_path=false) -> PackedStringArray:
	var dir = DirAccess.open(maps_path)
	var filepaths = PackedStringArray()
	var extensions = PackedStringArray()
	extensions = ["gbx", "Gbx"] # for filtering .Gbx

	if dir:
		dir.list_dir_begin()
		while true:
			var path := dir.get_next()
			
			if path == "": break
			
			if path.get_extension() in extensions:
				if complete_path: #full path or just file name
					var filepath = maps_path + path
					filepaths.append(filepath)
				else:
					filepaths.append(path)
			
		dir.list_dir_end()
	return filepaths

func parse_gbx(path:String): #Whole parser (different functions used - thx ChatGPT I'm too bad for this lol)
	var gbx_string = import_file(path) #1st import with lot of binary
	#gbx_string = keep_xml_chars(gbx_string) #2nd less binary more xml
	gbx_string = extract_xml_blocks(gbx_string) # even less binary
	gbx_string = extract_xml_document(str(gbx_string), "deps") # final cleanups to extract dependencies
	gbx_string = final_xml_cleaning(gbx_string) # true final cleanup
	return gbx_string


func import_file(path:String): #Thanks ChatGPT lol
	var file := FileAccess.open(path, FileAccess.READ)

	var xml_text := ""
	var max_bytes := 200000 # security

	for i in range(max_bytes):
		if file.eof_reached():
			break

		var b := file.get_8()

		# caractères ASCII imprimables + retours à la ligne
		if b == 9 or b == 10 or b == 13 or (b >= 32 and b <= 126):
			xml_text += char(b)
		else:
			continue

	file.close()
	
	#print(xml_text)
	return xml_text

	
func keep_xml_chars(text: String) -> String: #DEPRECATED : I don't even know what that does lol
	var out := ""
	for c in text:
		if c in "<>/=\"' \t\r\n" or c.is_valid_ascii_identifier() or c in ":-_.":
			out += c
	return out

func extract_xml_blocks(text: String) -> Array[String]:
	var blocks: Array[String] = []
	var current := ""
	var in_tag := false

	for c in text:
		if c == "<":
			in_tag = true
			current = "<"
		elif in_tag:
			current += c
			if c == ">":
				blocks.append(current)
				in_tag = false

	return blocks

func extract_xml_document(text: String, root: String) -> String:
	var start := text.find("<" + root)
	if start == -1:
		return ""

	var end := text.find("</" + root + ">")
	if end == -1:
		return ""

	end += ("</" + root + ">").length()
	return text.substr(start, end - start)


func format_xml(raw_text: String) -> String:
	# Step 1: Replace the escaped quotes (\") with actual quotes (")
	var cleaned_text := raw_text.replace("\\\"", "\"")

	# Step 2: Add newlines between tags (this assumes the structure is correctly formed)
	var formatted_text := cleaned_text.replace("<", "\n<").replace(">", ">\n").strip_edges()

	return formatted_text

func final_xml_cleaning(xml:String):

	var regex := RegEx.new()
	regex.compile("<[^>]+>")  # Compiles the regex pattern

	var matches := regex.search_all(xml)  # Find all matches

	var tags := []
	for match in matches:
		tags.append(match.strings[0])  # Add the matched tag to the array
		
	var final = format_xml("".join(tags))
	final = final.replace('<dep file="', "")
	final = final.replace('"/>', "")
	final = final.replace(r'<deps>', "")
	final = final.replace(r'</deps>', "")
	final = final.replace(r'\\', "/") #r'//' because r help since // is a line jump
	
	return lines_to_array(final)

func lines_to_array(raw_text: String) -> Array:
	# Split the string into lines based on newline character "\n"
	var lines = raw_text.split("\n")
	var final_line = []
	# Remove leading and trailing spaces from each line
	for i in lines:
		if i != "":
			if i.contains('" url='):
				i = i.erase(i.find('" url='), i.length() - i.find('" url=') ) # clean URLs since we don't need to copy them : external dependencies not local
			final_line.append(i)
			
	return final_line

func save_json(data, path:String):
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	var json_text := JSON.stringify(data)
	file.store_string(json_text)
	file.close()
	
func load_json(path:String):
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	
	var result = JSON.parse_string(content)
	return result

func export_maps(map_path:String, export_path:String): ### EXPORT MAPS FUNCTION
	var deps = parse_gbx(map_path) # deps array from map path
	
	var dir = DirAccess.open("user://") # user:// is used as a temp folder
	var map_name = map_path.get_file().replace(".Map.Gbx", "")
	var deps_array = [] # config file for easier import later
	if not deps == []:
		for d in deps:
			var d_path
			if trackmania_path.ends_with("/"):
				d_path = trackmania_path + d
			else:
				d_path = trackmania_path + "/" + d
			#print(d_path)
			var d_file = FileAccess.open(d_path, FileAccess.READ) # read to see if exist before copy
			if d_file != null: #built-in trackmania dependencies are skipped here
				
				deps_array.append(d) #local deps added (not built-in trackmania)
				var d_directories = d_path.get_base_dir().replace(trackmania_path, "")
				
				
				#print(ProjectSettings.globalize_path("user://" + map_name))
				if not dir.dir_exists("user://" + map_name):
					dir.make_dir_recursive("user://" + map_name + "/" + d_directories) # create firsts folders for 1st dependency
					#print(ProjectSettings.globalize_path("user://" + map_name + "/" + d_directories))
					dir.copy(d_path, "user://" + map_name + "/" + d) # copy 1st file
					
				else: # create folders for other dependencies
					dir.make_dir_recursive("user://" + map_name + "/" + d_directories) # make directories for other files
					#print(d_path)
					#print(ProjectSettings.globalize_path("user://" + map_name + "/" + d))
					dir.copy(d_path, "user://" + map_name + "/" + d) # copy files and overwrite

	else: # IF NO DEPENDENCIES
		#print("user://" + map_name)
		dir.make_dir("user://" + map_name) #make base folder in user:// (temporary)
	
	#print(ProjectSettings.globalize_path("user://" + map_name + "/" + map_path.get_file())) #GBX path (temp dir)
	dir.copy(map_path, "user://" + map_name + "/" + map_path.get_file()) #copy map
	save_json(deps_array, "user://" + map_name + "/" + map_path.get_file() + ".json") #copy deps array
	#print(load_json("user://" + map_name + "/" + map_path.get_file() + ".json")) #test load json
	
	### TEMP DIRECTORY CREATED + COPY OF FILES + DEPENDENCIES
	
	var zip_writer = ZIPPacker.new() #init zip packer
	zip_writer.open("user://" + map_name + ".zip") #create zip container
	zip_dir(map_name, zip_writer) #create ZIP archive (put files in etc)
	zip_writer.close()
	
	### ZIP DONE YAY :)
	
	#print(ProjectSettings.globalize_path("user://" + map_name + ".zip"))
	dir.copy("user://" + map_name + ".zip", export_path + "/" + map_name + ".zip") # copy zip to final destination
	
	dir.remove("user://" + map_name + ".zip") # remove temp files
	rmdir("user://" + map_name)


func import_maps(path:String): ### IMPORT MAPS BASED ON PATH + return progress in string
	var base_dir = extract_all_from_zip(path) # return main folder name
	
	var dir = DirAccess.open("user://" + base_dir)
	
	for f in dir.get_files():
		if f.ends_with(".json"): #use json to get deps
			var deps = load_json("user://" + base_dir + "/" + f) # read to get array of deps
			import_logs_label.text += tr("READING_DEPS") + "\n"
			#print("user://" + base_dir + "/" + f)
			for d in deps:
				#print("user://" + base_dir + "/" + d)
				#print(trackmania_path + d)
				var t_path
				if not trackmania_path.ends_with("/"):
					t_path = trackmania_path + "/"
				else:
					t_path = trackmania_path
				
				if not dir.file_exists(t_path + d):
					dir.copy("user://" + base_dir + "/" + d, t_path + d) # COPY DEPENDENCY
				else:
					import_logs_label.text += "[color=yellow]" + tr("DEPS_ALREADY_EXIST") + d + "[/color]" + "\n"
				
			import_logs_label.text += "[color=green]" + tr("DEPS_COPIED") + "[/color]" + "\n"
		
	for f in dir.get_files(): # map after so new loop
		if f.ends_with("Gbx"): #Get map gbx
			#print("user://" + base_dir + "/" + f)
			#print(maps_path + f)
			if not dir.file_exists(maps_path + f):
				dir.copy("user://" + base_dir + "/" + f, maps_path + f) # COPY MAP GBX
				import_logs_label.text += "[color=green]" + tr("MAP_COPIED") + f + "[/color]" + "\n"
			else:
				import_logs_label.text += "[color=red]" + tr("MAP_ALREADY_EXIST") + f + "[/color]" + "\n"
	
	#print("user://" + base_dir)
	rmdir("user://" + base_dir) #Delete temp directory
	


func zip_dir(dir_name: String, writer:ZIPPacker) -> void: # Credits for this function to : https://github.com/jhlothamer/godot_project_zip/blob/main/addons/project_zip/godot_project_zip_plugin.gd
	var dir := DirAccess.open("user://%s" % dir_name) # Thanks a lot it was so hard I could't figure it out :(
	if !dir:
		printerr("could not open project directory user://%s" % dir_name)
		return
	dir.include_hidden = true
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var full_file_path := "%s/%s" % [dir_name, file_name]
		if dir.current_is_dir():
			zip_dir(full_file_path, writer)
		else:
			var file_contents := FileAccess.get_file_as_bytes("user://%s" % full_file_path)
			writer.start_file(full_file_path)
			writer.write_file(file_contents)
			writer.close_file()
		file_name = dir.get_next()

func rmdir(directory: String) -> void: #Credits : https://github.com/Elip100/godot_remove_directory/blob/main/addons/remove_directory/rmdir.gd
	for file in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(file))
	for dir in DirAccess.get_directories_at(directory):
		rmdir(directory.path_join(dir))
	DirAccess.remove_absolute(directory)

func extract_all_from_zip(path):
	import_logs_label.text += tr("START_EXTRACT_ZIP") + "\n"
	var reader = ZIPReader.new()
	reader.open(path)

	# Destination directory for the extracted files (this folder must exist before extraction).
	# Not all ZIP archives put everything in a single root folder,
	# which means several files/folders may be created in `root_dir` after extraction.
	var root_dir = DirAccess.open("user://") #USER AS A TEMP DIRECTORY

	var files = reader.get_files()
	
	var files_dir
	
	for file_path in files:
		#print(file_path)
		# If the current entry is a directory.
		if file_path.ends_with(".json"): # get highest directory (based on the json that is in it)
			#print(f.get_base_dir())
			files_dir = file_path.get_base_dir()
			
		if file_path.ends_with("/"):
			root_dir.make_dir_recursive(file_path)
			continue

		# Write file contents, creating folders automatically when needed.
		# Not all ZIP archives are strictly ordered, so we need to do this in case
		# the file entry comes before the folder entry.
		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var file = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		var buffer = reader.read_file(file_path)
		file.store_buffer(buffer)
		
	import_logs_label.text += tr("EXTRACT_ZIP_FINISHED") + "\n"
	
	return files_dir
