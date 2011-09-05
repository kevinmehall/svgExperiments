
svg = false

RADIUS = 5

allNodes = []

svgDrag = (elem, move, start, stop) ->
	ex = 0
	ey = 0
	
	mousedown = (event) ->
		start(event)
		ex = event.pageX
		ey = event.pageY
		$(document.body).mousemove(mousemove)
		                .mouseup(mouseup)
	
	mousemove = (event) ->
		move(event.pageX - ex, event.pageY - ey, event)
	
	mouseup = (event) ->
		$(document.body).unbind('mousemove', mousemove)
		                .unbind('mouseup', mouseup)
		stop(event)
		
	$(elem).mousedown(mousedown)
		
		

class Node
	constructor: (@x, @y) ->
		allNodes.push this
		@dot = svg.circle(@x, @y, RADIUS)
		
		$(@dot).addClass 'node'
		
		@ox = @x
		@oy = @y
		
		start = =>
			@ox = @x
			@oy = @y
			
		move = (dx, dy) =>
			@x = @ox + dx
			@y = @oy + dy
			
			@linked = false
			for i in allNodes
				if i == this
					continue
				nearX = i.x - @x
				nearY = i.y - @y
				d2 = nearX*nearX + nearY*nearY
				if d2 < RADIUS*RADIUS*2
					@x = i.x
					@y = i.y
					@linked = true
					console.log "linked"
					break
					
			$(@dot).attr {cx: @x, cy:@y, fill:if @linked then '#0f0' else '#00f'}
			@onMove(dx, dy, @x, @y)
		
		svgDrag(@dot, move, start, @onDrop)
		
	onMove: ->
	onDrop: ->
		

class Wire
	constructor: ->
		@line = svg.line()
		@n1 = new Node(50, 50)
		@n2 = new Node(100, 100)
		
		
		$(@line).attr
			'stroke-width': 2
			stroke: "#00f"
		@update()
		
		@n1.onMove = @update
		@n2.onMove = @update
	
	update: =>
		$(@line).attr {x1:@n1.x, y1:@n1.y, x2:@n2.x, y2:@n2.y}
		
	
		
		

$(window).ready ->
	$("<div id='svgcanvas'>").appendTo(document.body).svg onLoad: (_svg) ->
		svg = _svg
		console.log(svg)
		w = new Wire()
		w2 = new Wire()
		w3 = new Wire()
