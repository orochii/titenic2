extends Node

var _popup : PopUp = null

func presearch():
	popUp()

func popUp() -> PopUp:
	if (_popup == null):
		var type = PopUp;
		_popup = findObjectOfClass(get_tree().root, "PopUp") as PopUp
	return _popup

func findObjectOfClass(node: Node, className: String) -> Node:
	# Find in children
	for child in node.get_children():
		var v = findObjectOfClass(child,className)
		if (v != null):
			return v
	# Return actual thing
	var e = eval("return node is " + className, {"node":node})
	if (e):
		return node
	else:
		return null

func eval(code:String, params:Dictionary):
	var script = GDScript.new()
	var param_code = ""
	for each in params:
		param_code += "var " + each + " = null\n"
	script.source_code = param_code+"\n\n"+"func execute():\n\t" + code
	script.reload()
	var script_instance = script.new()
	for each in params:
		var p = params[each]
		script_instance.set(each, p)
	return script_instance.call("execute")
