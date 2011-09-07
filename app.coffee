
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
		
		@moveEnabled = true
		@snapEnabled = true
		
		svgDrag(@dot, @move, @startDrag, @drop)
		
	startDrag: (event) =>
		@ox = @x
		@oy = @y
		
		svgRaise(@dot)
		
		i.onStartDrag(event) for i in @boundTo
		
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
				console.log 'binding', @boundTo, i, l
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
		console.log 'addBinding', b, @boundTo
		
		if @boundTo.length > 1
			$(@dot).addClass 'linked'
		
	removeBinding: (b) ->
		if b in @boundTo then @boundTo.splice(@boundTo.indexOf(b), 1)
		
		if @boundTo.length <= 1
			$(@dot).removeClass 'linked'
		
	
	
		

class NodeBinding
	constructor: (node) ->
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
			(new NodeBinding(new Node(@x+x,@y+50)) for x in [0, 100])
			.concat(new NodeBinding(new Node(@x+50,@y+y)) for y in [0, 100]))
			
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
		console.log(svg)
		w1 = new Wire(50, 50, 100, 100)
		w2 = new Wire(50, 80, 90, 80)
		w3 = new Wire(80, 50, 120, 120)
		w3 = new Wire(140, 140, 100, 50)
		p1 = new TestPart(200, 200)
