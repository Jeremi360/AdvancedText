@tool
extends Resource

## Base class used by AdvancedTexts addon Parsers
class_name TextParser

## RegEx used by this class
var re := RegEx.new()

## Used to store result of last RegEx search
var result: RegExMatch

## Used to store replacement for RegEx search
var replacement := ""

## Here will be stored all code between code tags in given text
var in_code := []

## Root ref is needed to check if other compatible addons are installed
var root: Node

## This only exits to be override by Parsers classes that inherits from it
## This func just returns given with out any changes
func parse(text: String) -> String:
	return text

## Func used get singletons from other addons
func get_singleton(singleton: String) -> Node:
	if root.has_node(singleton):
		return root.get_node(singleton)
	return null

## Func that my parsers uses to replace result in given text with replacement.
func replace_regex_match(text: String, result: RegExMatch, replacement: String) -> String:
	var start_string := text.substr(0, result.get_start())
	var end_string := text.substr(result.get_end(), text.length())
	return start_string + replacement + end_string

## Returns given path to image as BBCode img
## Size must be given as "<height>x<width>" without "< >"
## Size is this way to be easy to use by Parsers
func to_bbcode_img(path: String, size:="") -> String:
	if size == "":
		return "[img]%s[/img]" % path
	
	return "[img=%s]%s[/img]" % [size, path]

## Returns given path/url to image as BBCode link
## If link_text != "" it will be displayed as link text
func to_bbcode_link(path: String, link_text:="") -> String:
	if link_text == "":
		return "[url]%s[/url]" % path
	
	return "[url=%s]%s[/url]" % [path, link_text]

## It find all code in between code tags in given text
## And add its start and end paris into in_code array,
## to make easy to skip them in parsing process
## This func should be run as first in parse()
func find_all_in_code(text: String, open_code_tag:="[code]", close_code_tag:="[/code]") -> Array:
	var _in_code := []
	re.compile("%s(.*)%s" % [open_code_tag, close_code_tag])
	result = re.search(text)
	while result != null:
		_in_code.append([result.get_start(1), result.get_end(1)])
		result = re.search(text)

	return _in_code

## It checks if given result is in code tags
## used to skip parts of text that are in code tags in parsing process
func is_in_code(result: RegExMatch) -> bool:

	for pair in in_code:
		if result.get_start() >= pair[0]:
			if result.get_end() <= pair[1]:
				return true

	return false

## Used to replace given `what` Regex String
## with `for_what` String in given text,
## skipping parts of text that are in code tags,
## for this to work `in_code = find_all_in_code(text)`
## must be called first.
func safe_replace(what: String, for_what: String, text: String) -> String:
	re.compile(what)
	result = re.search(text)
	while result != null:
		if is_in_code(result):
			result = re.search(text)
			continue
		
		text = replace_regex_match(text, result, for_what)
		result = re.search(text)

	return text
