extends Path2D

var y_arr = []
var pointsSize = 0
var prior = Vector2()
var waveformBackground = Rect2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func showY(points):
	pointsSize = points.size()
	y_arr = points
	prior = Vector2(0,points[0])
	var tlc = Vector2(0,points.min())
	var brc = Vector2(pointsSize-1,points.max())
	waveformBackground = Rect2(tlc,brc)
func _draw():
	if pointsSize > 0:
		draw_rect(waveformBackground,Color8(0,0,55,25))
		for item in pointsSize-1:
			var current = Vector2(item,y_arr[item])
			draw_line(prior,current,Color.blue)
			prior = current
