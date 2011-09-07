# SVG nodes/handles experiment
# (C) 2011 Kevin Mehall (Nonolith Labs) <km@kevinmehall.net>
# BSD License

RADIUS = 5 # Node radius, px
svg = false # canvas object global, assigned in window.ready => svg.onload
window.allNodes = []

# Helper to make a SVG object *elem* draggable
# move() is called with relative position (from start of drag) when the mouse is moved
# start() is called when the button is pressed to initiate the drag. return false to cancel
# stop() is called when the mouse is released
svgDrag = (elem, move, start, stop) ->
	ex = 0
	ey = 0
	
	mousedown = (event) ->
		if (s=start(event))==false then return
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

# Move an element to be the last child of its parent to raise it to the top of the z-stack
svgRaise = (e) ->
	$(e).appendTo($(e).parent())
		
class Node
	constructor: (@x, @y) ->
		allNodes.push this
		@dot = svg.circle(@x, @y, RADIUS)
		$(@dot).addClass 'node'
		@boundTo = []
		
		@ox = @x
		@oy = @y
		
		startDrag = => 
			if _.every(@boundTo, (i)->i.enableMove) then @startDrag() else false
		svgDrag(@dot, @move, startDrag, @drop)
		
	startDrag: (event) =>
		@ox = @x
		@oy = @y
		
		i.onStartDrag(event) for i in @boundTo
		svgRaise(@dot)
		
	move: (dx, dy, event) =>	
		@x = @ox + dx
		@y = @oy + dy
		
		if @findLink()
			$(@dot).addClass 'link-drag'
		else
			$(@dot).removeClass 'link-drag'
		
		$(@dot).attr {cx: @x, cy:@y}
		i.onMove(dx, dy, @x, @y) for i in @boundTo
		
	drop: (event) =>
		l = @findLink()
		
		i.onDrop(event) for i in @boundTo
		
		if l
			boundTo = @boundTo
			@boundTo = []
			for i in boundTo
				i.bind(l)
			@destroy()
			
	destroy: ->
		$(@dot).remove()
		allNodes.splice(allNodes.indexOf(this), 1)
			
	findLink:  ->
		for i in allNodes
			nearX = i.x - @x
			nearY = i.y - @y
			d2 = nearX*nearX + nearY*nearY
			if i != this and d2 < RADIUS*RADIUS*2
				@x = i.x
				@y = i.y
				return i
		return false
	
	addBinding: (b) ->
		if b not in @boundTo then @boundTo.push(b)
		
		if @boundTo.length > 1
			$(@dot).addClass 'linked'
		
	removeBinding: (b) ->
		if b in @boundTo then @boundTo.splice(@boundTo.indexOf(b), 1)
		
		if @boundTo.length <= 1
			$(@dot).removeClass 'linked'

# Connection between a node and an object that has attached nodes
# Wire/Part holds as a pointer to the Node object as the SVG shapes come and go
class NodeBinding
	constructor: (node, @enableMove=true) ->
		if node then @bind(node)
		
	bind: (node) ->
		if @node
			@node.removeBinding(this)
		node.addBinding(this)
		@node = node
	
	onStartDrag: ->
	onMove: ->
	onDrop: ->
	onBound: ->

# Line between two Nodes	
class Wire
	constructor: (x1,y1,x2,y2)->
		@line = svg.line()
		@n1 = new NodeBinding(new Node(x1, y1))
		@n2 = new NodeBinding(new Node(x2, y2))
		
		$(@line).attr
			'stroke-width': 2
			stroke: "#00f"
		@update()
		
		@n1.onMove = @update
		@n2.onMove = @update
		
		@n1.onStartDrag = @n2.onStartDrag = => svgRaise(@line)
	
	update: =>
		$(@line).attr {x1:@n1.node.x, y1:@n1.node.y, x2:@n2.node.x, y2:@n2.node.y}

class TestPart
	constructor: (@x, @y) ->
		@rect = svg.rect()
		
		$(@rect).attr
			'stroke-width': 2
			stroke: "#0f0"
			fill: "#cfc"
			width: 100
			height: 100
			x: @x
			y: @y
			cursor: 'move'
		
		@nodes = (
			(new NodeBinding(new Node(@x+x,@y+50), false) for x in [0, 100])
			.concat(new NodeBinding(new Node(@x+50,@y+y), false) for y in [0, 100]))
			
		onStartDrag = =>
			svgRaise(@rect)
			svgRaise(i.node.dot) for i in @nodes
		(i.onStartDrag = onStartDrag) for i in @nodes
			
		@ox = @x
		@oy = @y
		svgDrag(@rect, @move, @startDrag, @drop)
		
	startDrag: =>
		@ox = @x
		@oy = @y
		
		for node in @nodes
			if node.node then node.node.startDrag()
		
	move: (dx, dy, event) =>
		@x = @ox + dx
		@y = @oy + dy
		
		for node in @nodes
			if node.node then node.node.move(dx, dy, event)
			
		$(@rect).attr
			x: @x
			y: @y
			
	drop: (event) =>
		for node in @nodes
			if node.node then node.node.drop(event)


$(window).ready ->
	$("<div id='svgcanvas'>").appendTo(document.body).svg onLoad: (_svg) ->
		svg = _svg
		w1 = new Wire(50, 50, 100, 100)
		w2 = new Wire(50, 80, 90, 80)
		w3 = new Wire(80, 50, 120, 120)
		w3 = new Wire(140, 140, 100, 50)
		p1 = new TestPart(200, 200)
