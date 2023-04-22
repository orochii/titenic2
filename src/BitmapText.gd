@tool
class_name BitmapText

extends MeshInstance2D
@export_multiline var text = "Test"
@export var color = Color(1, 1, 1)
@export var colorPick : Texture2D
var _startCoord = Vector2i(0,0)
var _charSize = Vector2i(8,8)
var _length = 26
var _characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz(|)<=>_-+/\\*., 0123456789©[#~·]!?←↑→↓↖↗↘↙🅐🅑🅒🅓🅔🅕🅖🅗🅘🅙🅚🅛🅜🅝🅞🅟🅠🅡🅢🅣🅤🅥🅦🅧🅨🅩「」\"':;"
var CODE_SYMBOL = '@'

var _lastText = ""
var _lastColor= Color(1,1,1)

func regenerateMesh():
	var tW = texture.get_width() * 1.0
	var tWW = 8 / tW
	var tH = texture.get_height() * 1.0
	var tHH = 8 / tH
	var xx = 0
	var yy = 0
	var currCol = color;
	# Process text
	var processedText = processText(text)
	var codeIdx = 0
	# Init surface tool
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	# Iter through letters
	for i in range(0,processedText["text"].length()):
		var c = processedText["text"][i]
		if (c == "\n"):
			xx = 0
			yy += _charSize.y
			continue
		if (c == CODE_SYMBOL):
			var code = processedText["params"][codeIdx]
			codeIdx += 1
			match code[0]:
				"c":
					currCol = getColor(code[1])
			continue
		# Print
		var idx = _characters.find(c)
		if idx != -1:
			var x = (_startCoord.x + (idx % _length) * _charSize.x) / tW
			var y = (_startCoord.y + (idx / _length) * _charSize.y) / tH
			# Add 6 vertices I guess? :weary:
			st.set_color(currCol)
			st.set_uv(Vector2(x,y))
			st.add_vertex(Vector3(xx,yy,0))
			st.set_uv(Vector2(x+tWW,y))
			st.add_vertex(Vector3(xx+_charSize.x,yy,0))
			st.set_uv(Vector2(x,y+tHH))
			st.add_vertex(Vector3(xx,_charSize.y+yy,0))
			
			st.set_uv(Vector2(x+tWW,y))
			st.add_vertex(Vector3(xx+_charSize.x,yy,0))
			st.set_uv(Vector2(x+tWW,y+tHH))
			st.add_vertex(Vector3(xx+_charSize.x,_charSize.y+yy,0))
			st.set_uv(Vector2(x,y+tHH))
			st.add_vertex(Vector3(xx,_charSize.y+yy,0))
		xx += 8
	# Commit changes
	self.mesh = st.commit()
	_lastText = text
	_lastColor = color

func refreshColor():
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	# Iter all vertices
	for i in range(mdt.get_vertex_count()):
		mdt.set_vertex_color(i, color)
	mesh.clear_surfaces()
	mdt.commit_to_surface(mesh)
	_lastColor = color

func _ready():
	regenerateMesh()

func _process(delta):
	if (_lastText != text):
		regenerateMesh()
	elif (_lastColor != color):
		refreshColor()

func processText(text : String) -> Dictionary:
	# Create "buffers"
	var processedText = ""+text
	var params = []
	# Iterate
	var regex = RegEx.new()
	regex.compile("\\\\c\\[(\\d+)\\]")
	var results = regex.search_all(processedText)
	for result in results:
		var s = result.get_string()
		processedText = processedText.replace(s,CODE_SYMBOL)
		var code = ["c",result.get_string(1).to_int()]
		params.push_back(code)
	# Prepare for return
	var retVal = {"text":processedText,"params":params}
	return retVal

func getColor(idx):
	var w = colorPick.get_width() / 8
	var xx = (idx % w * 8) + 1
	var yy = (idx / w * 8) + 1
	return colorPick.get_image().get_pixel(xx,yy)
