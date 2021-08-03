extends Path2D

var baseline = 0
var baselineEnd = 0
var minWaveform = 0
var maxWaveform = 0
var ecg_background = Rect2()
var padding = 20

var xOffset = 0
var xLast = 0

var raw = []
var rawSize = 0

var steps = 0
var linearised = []
var dpv = []
var prior = Vector2()

var yPoints = []
var yInverted = []
var yScaled = []

onready var rtl = $RichTextLabel

func _ready():

	raw = self.curve.tessellate(3,4)
	rawSize = raw.size()
	prior = raw[0]
	assessRaw()

func assessRaw():
	baseline = raw[0].y
	baselineEnd = raw[rawSize-1].y
	xOffset = raw[0].x
	xLast = raw[rawSize-1].x
	maxWaveform = baseline
	minWaveform = baseline
	
	for i in rawSize:
		var p = raw[i]
		if p.y < maxWaveform:
			maxWaveform = p.y
		if p.y > minWaveform:
			minWaveform = p.y
		if p.x > xLast:
			xLast = p.x
			baselineEnd = p.y
	var tlc = Vector2(xOffset - padding, maxWaveform - padding)
	var brc = Vector2(xLast + padding,minWaveform + padding)
	ecg_background = Rect2(tlc,brc)
	var rawExtents = Vector2(int(xLast+xOffset),int(minWaveform+padding))

	$RawGraticule.updateExtents(rawExtents)
	$RawGraticule.updateLinePoints(raw)
	$RawGraticule.updateDotPoints(raw)
	
	add_header("Tesselation")
	add_line("Total points", String(rawSize))
	add_line("Baseline Start", String(baseline))
	add_line("Baseline End", String(baselineEnd))
	add_line("Min Waveform", String(minWaveform))
	add_line("Max Waveform", String(maxWaveform))
	
	steps = xLast - xOffset
	var pointCounter = 0
	var offsetCounter = 0
	var maxYv = 0
	var thisPoint = Vector2(raw[pointCounter])
	var nextPoint = Vector2(raw[pointCounter+1])
#	var dpvi = Vector3()
	for step in steps:
		if step+xOffset > nextPoint.x:
			pointCounter += 1
			offsetCounter = step
			thisPoint = Vector2(raw[pointCounter])
			nextPoint = Vector2(raw[pointCounter+1])
		var lurp = nextPoint - thisPoint
		var tee = (step-offsetCounter)/lurp.x
		var yv = thisPoint.y + (lurp.y * tee)
		if yv > maxYv:
			maxYv = yv
		var xy = Vector2(step,yv)
		linearised.append(xy)
		
	add_header("Linearised")
	add_line("Total points", String(steps))
	add_line("x Offset", String(xOffset))
	add_line("Last x", String(xLast))
#	add_line("Export path", OS.get_user_data_dir())
		
	var xyExtents = Vector2(steps,maxYv + padding)
	$XYGraticule.updateExtents(xyExtents)
	$XYGraticule.updateLinePoints(linearised)
	$XYGraticule.updateDotPoints(linearised)
	$XYGraticule.lpColor = Color.purple
	$XYGraticule.dpColor = Color.red
	
	extract(linearised)

func extract(lv):
	var steps = lv.size()
	if steps > 0:
		for step in steps:
			var yp = lv[step].y
			yPoints.append(yp)

func add_header(header):
	rtl.append_bbcode("\n[b][u][color=#6df]{header}[/color][/u][/b]\n".format({
		header = header,
	}))
func add_line(key, value):
	rtl.append_bbcode("[b]{key}:[/b] {value}\n".format({
		key = key,
		value = value if str(value) != "" else "[color=#8fff](empty)[/color]",
	}))
	
func invert(yp):
	yInverted = []
	var maxY = yPoints.max()
	var minY = yPoints.min()
	
	for p in yPoints:
		var np = maxY - p
		yInverted.append(np)
func scale(bits):
	invert(yPoints)
	yScaled = []
	var maxY = yInverted.max()
	var minY = yInverted.min()
	var gsh = float(pow(2,bits)-1)
	var multFactor = gsh/maxY
	for yv in yInverted:
		var syv = int(yv * multFactor)
		yScaled.append(syv)
func serialiseXY(arrayofpoints):
	var result = ""
	for p in arrayofpoints:
		result += "(" + String(p.x) + ":" + String(p.y) + "),"
	return result
func serialiseY(arrayofpoints):
	var result = ""
	for p in arrayofpoints:
		result += String(p) + ","
	return result
func saveEcg(content,loc):
	var file = File.new()
	if loc == "XY":
		file.open("user://ecg_curveXY.csv",File.WRITE)
	elif loc == "Y":
		file.open("user://ecg_curveY.csv",File.WRITE)
	elif loc == "raw":
		file.open("user://ecg_curveRaw.csv",File.WRITE)
	elif loc == "inv":
		file.open("user://ecg_inv_y.csv",File.WRITE)
	elif loc == "12b":
		file.open("user://ecg_12b_y.csv",File.WRITE)
	elif loc == "10b":
		file.open("user://ecg_10b_y.csv",File.WRITE)
	file.store_string(content)
	file.close()

#func _process(delta):
#	update()
#
#func _draw():
#	draw_rect(ecg_background,Color8(0,0,55,20))
#	for p in raw:
#		draw_circle(p,2,Color.yellow)
#		draw_line(prior,p,Color.green)
#		prior = p
#
#	prior = Vector2()
#	prior = linearised[0]
#	for p in linearised:
#		draw_circle(p,2,Color.red)
#		draw_line(prior,p,Color.purple)
#		prior = p

func _on_Button_pressed():
	var vals = serialiseXY(linearised)
	saveEcg(vals,"XY")
func _on_Button2_pressed():
	var path = OS.get_user_data_dir()  #OS.get_environment("USERPROFILE")
	OS.shell_open(path)
func _on_Button3_pressed():
	var vals = serialiseY(yPoints)
	saveEcg(vals,"Y")
func _on_Button4_pressed():
	var vals = serialiseXY(raw)
	saveEcg(vals,"raw")
func _on_Button5_pressed():
	scale(12)
	var val = serialiseY(yScaled)
	saveEcg(val,"12b")
func _on_Button6_pressed():
	scale(10)
	var val = serialiseY(yScaled)
	saveEcg(val,"10b")
func _on_Button7_pressed(): #inverted
	invert(yPoints)
	var val = serialiseY(yInverted)
	saveEcg(val,"inv")
	



