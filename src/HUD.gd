extends Node
class_name HUD

@export var lifesText:BitmapText
@export var mansText:BitmapText
@export var scoreText:BitmapText
@export var enemyText:BitmapText

func refresh():
	refreshLifes()

func refreshLifes():
	if (State.player == null):
		return
	var cur = State.player.remLifes()
	var max = State.player.maxLifes()
	lifesText.text = makeBar(cur,max)
	print("LIFE: " + str(cur) + "/" + str(max))

# [#~·]
func makeBar(cur:int,max:int):
	var t = "["
	for i in range(0,max/2):
		if (cur >= 2):
			t += "#"
		elif(cur==1):
			t += "~"
		else:
			t += "·"
		cur -= 2
	t += "]"
	return t
