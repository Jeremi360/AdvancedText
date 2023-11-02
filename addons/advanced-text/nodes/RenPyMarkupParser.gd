@tool
@icon("res://addons/advanced-text/icons/ren16.png")
extends ExtendedBBCodeParser

## This parser is every limited as its just translates RenPy Markup to BBCode
## This parser also adds Headers {h1}, :emojis: and icons {icon:name} add Rakugo variables with <var_name>
class_name RenPyMarkupParser

## returns given text parsed to BBCode
func parse(text: String) -> String:
	text = parse_links(text)
	text = parse_imgs(text)
	text = parse_imgs_size(text)
	## BBCode and Ren'Py are the same,
	## but RenPy uses '{}' instead of '[]'
	## so we need to replace them
	text = text.replace("{", "[")
	text = text.replace("}", "]")

	return super.parse(text)

# parse Ren'Py links into BBCode
# Ren'Py links examples:
# {a=https://some_domain.com}link{/a}
# {a}https://some_domain.com{/a}
func parse_links(text: String) -> String:
	re.compile("(?<!\\{)\\{(\\/{0,1})a(?:(=[^\\}]+)\\}|\\})")
	result = re.search(text)
	while result != null:
		replacement = "[%surl%s]" % [
			result.get_string(1), result.get_string(2)]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())
		
	return text

## parse Ren'Py images with out size into BBCode
## Ren'Py images example:
## {img=<path>}
func parse_imgs(text:String) -> String:
	re.compile("(?<!\\{)\\{img=([^\\}\\s]+)\\}")
	result = re.search(text)
	while result != null:
		replacement = "[img]%s[/img]" % result.get_string(1)
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())

	return text

## parse Ren'Py images with size into BBCode
## Ren'Py images with size example:
# {img=<path> size=<height>x<width>}
func parse_imgs_size(text:String) -> String:
	re.compile("(?<!\\{)\\{img=([^\\}\\s]+) size=([^\\}]+)\\}")
	result = re.search(text)
	while result != null:
		replacement = "[img=%s]%s[/img]" % [
			result.get_string(2), result.get_string(1)]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text, result.get_end())

	return text