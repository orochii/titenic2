extends Node
class_name StateClass
enum FlagNames {LIFE,SCORE,UPGRADES}

var composition = [4,6,2,3,7,0,5,1]
var password = ""

var _flags = PackedInt32Array()
var _allObjs = Array()

func initialize():
	# For load, the following must happen:
	# - Read new flags
	readPassword()
	# - Refresh all objects
	var root = get_node('/root')
	findByClass(root, _allObjs)
	refresh()

func refresh():
	for obj in _allObjs:
		print ("REFRESH: " + obj.name)
		obj.refresh()

func generatePassword():
	var newPass = ""
	for i in composition:
		var f = getFlag(i)
		if (f > 15):
			f = 15
		newPass += String.chr(f + 65)
	return newPass

func readPassword():
	for i in range(0,password.length()):
		var j = composition[i]
		var c = password.unicode_at(i)
		var f = (c - 65)
		setFlag(j, f)

func getFlag(idx:int):
	if idx < _flags.size():
		return _flags[idx]
	return 0

func setFlag(idx:int, v:int):
	if idx >= _flags.size():
		_flags.resize(_flags.size()+8)
	_flags[idx] = v

func findByClass(node: Node, result : Array) -> void:
	var v = node is ReactObject
	if v:
		result.push_back(node)
	for child in node.get_children():
		findByClass(child, result)
