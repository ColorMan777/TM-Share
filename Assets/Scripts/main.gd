extends Control

var gbx_file

func _ready() -> void:
	var xml = parse_gbx("res://Assets/LevelDesign_Exercise01.Map.Gbx")
	print(xml)


func parse_gbx(path:String):
	var gbx_string = import_file(path) #1st import with lot of binary
	#gbx_string = keep_xml_chars(gbx_string) #2nd less binary more xml
	gbx_string = extract_xml_blocks(gbx_string) # even less binary
	gbx_string = extract_xml_document(str(gbx_string), "deps") # final cleanups to extract dependencies
	gbx_string = final_xml_cleaning(gbx_string)
	return gbx_string


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
			final_line.append(i)
			
	return final_line
