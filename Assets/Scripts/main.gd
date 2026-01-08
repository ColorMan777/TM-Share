extends Control

var gbx_file

func _ready() -> void:
	#print(load_from_file())
	#gbx_file = load_from_file()
	var test = import_file("res://Assets/LevelDesign_Exercise01.Map.Gbx")
	test = keep_xml_chars(test)
	test = extract_xml_blocks(test)
	test = extract_xml_document(str(test), "deps")
	print(test)
	#var parser = XMLParser.new()
	#parser.open("res://Assets/LevelDesign_Exercise01.Map.Gbx")
	#print(parser.read())
	#while parser.read() != ERR_FILE_EOF:
		#if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			#var node_name = parser.get_node_name()
			#var attributes_dict = {}
			#for idx in range(parser.get_attribute_count()):
				#attributes_dict[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)
			#print("The ", node_name, " element has the following attributes: ", attributes_dict)
	
#func load_from_file():
	##print(FileAccess.file_exists("res://Assets/LevelDesign_Exercise01.Map.Gbx"))
	##var file = FileAccess.open("res://Assets/LevelDesign_Exercise01.Map.Gbx", FileAccess.READ)
	##var content = file.get_as_text()
	##var bytes = FileAccess.get_file_as_bytes("res://Assets/TMGamesSurfside Part2.Map.Gbx")
	##var content = bytes.get_string_from_ascii()
	##return content
	#
	#var file := FileAccess.open("res://Assets/LevelDesign_Exercise01.Map.Gbx", FileAccess.READ)
	#var bytes: PackedByteArray = file.get_buffer(file.get_length())
	##print(bytes.get_string_from_ascii())


func import_file(path:String): #Thanks ChatGPT lol
	var file := FileAccess.open(path, FileAccess.READ)

	var xml_text := ""
	var max_bytes := 200000 # sécurité

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

	
func keep_xml_chars(text: String) -> String:
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
