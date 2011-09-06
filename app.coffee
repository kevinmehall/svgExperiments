
svg = false

RADIUS = 5

window.allNodes = []

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
		
		
idCntr = 0
class Node
	constructor: (@x, @y) ->
		allNodes.push this
		@id = idCntr++
		@dot = svg.circle(@x, @y, RADIUS)
		@linkedTo = [this]
		
		$(@dot).addClass 'node'
		
		@ox = @x
		@oy = @y
		
		start = =>
			@ox = @x
			@oy = @y
			
		move = (dx, dy, event) =>
			@x = @ox + dx
			@y = @oy + dy
			
			@testLinked(!event.shiftKey)
			
			$(@dot).attr {cx: @x, cy:@y}
			@onMove(dx, dy, @x, @y)
			
			if event.shiftKey
				for i in @linkedTo
					i.x = @x
					i.y = @y
					$(i.dot).attr {cx: @x, cy:@y}
					i.onMove(dx, dy, @x, @y)
		
		svgDrag(@dot, move, start, @onDrop)
			
	testLinked: (canDisconnect) ->
		links = []
		
		for i in allNodes
			nearX = i.x - @x
			nearY = i.y - @y
			d2 = nearX*nearX + nearY*nearY
			if i != this and d2 < RADIUS*RADIUS*2
				links.push(i)
				@x = i.x
				@y = i.y
				
		added = _.difference(links, @linkedTo)
		removed = _.difference(@linkedTo, links)
		
		
		if canDisconnect
			@linkedTo = links
				
			for i in removed
				i.testLinked(canDisconnect)
		else
			@linkedTo = @linkedTo.concat(added)
			
		for i in added
				i.testLinked(canDisconnect)
						
		if added or removed
				@updateLinks()
					
	updateLinks: ->
		if @linkedTo.length
			$(@dot).addClass('linked')
		else
			$(@dot).removeClass('linked')
		

		
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
