extends Node

const trackmania_maps_path = "Maps/My Maps/" #TM2020 Maps path

var gbx_file
var trackmania_path:String #TM2020 Directory Path
var default_trackmania_path:String
var maps_path:String #TM2020 maps path

func _ready() -> void:
	get_tree().root.set_min_size(Vector2i(700,500))
	
	default_trackmania_path = get_trackmania_path(false)
	
	trackmania_path = get_trackmania_path()
	if trackmania_maps_path != "":
		maps_path = get_trackmania_path() + trackmania_maps_path
	#print(trackmania_path)
	
	#var xml = parse_gbx("res://Assets/LevelDesign_Exercise01.Map.Gbx")
	#var xml = parse_gbx(trackmania_path + "Circuit XUS.Challenge.Gbx")
	#print(xml)
	
	#print(list_maps())
	#list_maps()

func update_trackmania_path(new_path:String):
	trackmania_path = new_path
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
					
				else: # else search Disk / Documents
					if DirAccess.dir_exists_absolute(DirAccess.get_drive_name(i) + "/Documents/Trackmania/") and verify_exist:
						p_final = DirAccess.get_drive_name(i) + "/Documents/Trackmania/"
					elif not verify_exist and p_final == "":
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

func parse_gbx(path:String):
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
