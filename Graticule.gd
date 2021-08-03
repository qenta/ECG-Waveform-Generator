extends Area2D

const bounds = Vector2(100,100)
var xMinInterval = 20
var yMinInterval = 20
var xMajInterval = 100
var yMajInterval = 100
var gMinPoints = []
var gMajPoints = []
var bex
var linePoints = []
var dotPoints = []
var lpColor = Color.green
var dpColor = Color.yellow
var dpSize = 0
var lpSize = 0
var lpPrior = Vector2()

func _ready():
	var bs = $Bounds.shape
	bs.set_extents(bounds)
	bex = bs.get_extents()
	var bp = $Bounds.position
	refreshBounds()
	
func refreshBounds():
	gMajPoints.clear()
	gMinPoints.clear()
	var bs = $Bounds.shape
	bex = bs.get_extents()
	for m in bex.y + 1:
		if m % yMinInterval == 0:
			for n in bex.x + 1:
				if n % xMinInterval == 0:
					var gp = Vector2(n,m)
					if n % xMajInterval == 0 and m % yMajInterval == 0:
						gMajPoints.append(gp)
					else:
						if n % xMajInterval == 0 or m % yMajInterval == 0:
							gMinPoints.append(gp)

func updateLinePoints(lp):
	linePoints = lp
	lpSize = linePoints.size()
	lpPrior = linePoints[0]
	
func updateDotPoints(dp):
	dotPoints = dp
	dpSize = dotPoints.size()

func updateExtents(bv):
	var shape = RectangleShape2D.new()
	shape.set_extents(bv)
	$Bounds.set_shape(shape)
	refreshBounds()

func _process(delta):
	update()
	
func _draw():
	var bgr = Rect2(Vector2(),bex)
	draw_rect(bgr,Color8(0,0,55,44))
	for p in gMinPoints:
		draw_circle(p,1,Color8(255,255,255,100))
		
	for p in gMajPoints:
		draw_circle(p,3,Color8(255,255,255,100))
		
	if dpSize > 0:
		for dp in dotPoints:
			draw_circle(dp,2,dpColor)
	if lpSize > 0:
		for lp in linePoints:
			draw_line(lpPrior,lp,lpColor)
			lpPrior = lp
		lpPrior = linePoints[0]


func _on_Graticule_input_event(viewport, event, shape_idx):
	if event is InputEventMouseMotion:
		var lep = to_local(event.position)
		$Label.text = "%3.0f,%3.0f" % [lep.x,lep.y]
