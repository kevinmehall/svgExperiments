
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
		
		
class Node
	constructor: (@x, @y) ->
		allNodes.push this
		@dot = svg.circle(@x, @y, RADIUS)
		$(@dot).addClass 'node'
		@boundTo = []
		
		@ox = @x
		@oy = @y
		
		start = =>
			@ox = @x
			@oy = @y
			
		move = (dx, dy, event) =>
			@x = @ox + dx
			@y = @oy + dy
			
			if @findLink()
				$(@dot).addClass 'linked'
			else
				$(@dot).removeClass 'linked'
			
			$(@dot).attr {cx: @x, cy:@y}
			@onMove(dx, dy, @x, @y)
			
		drop = (event) =>
			l = @findLink()
			if l
				for i in @boundTo
					i.bind(l)
				@destroy()
		
		svgDrag(@dot, move, start, drop)
			
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
		
	onMove: ->
		i.onMove() for i in @boundTo
	onDrop: ->
		i.onDrop() for i in @boundTo
	
	addBinding: (b) ->
		if b not in @boundTo then @boundTo.push(b)
		console.log 'addBinding', b, @boundTo
		
	removeBinding: (b) ->
		if b in @boundTo then @boundTo.splice(@boundTo.indexOf(b), 1)
	
	
		

class NodeBinding
	constructor: (node) ->
		if node then @bind(node)
		
	bind: (node) ->
		if @node
			@node.removeBinding(this)
		node.addBinding(this)
		@node = node
	
	onMove: ->
	onBound: ->
		
		

class Wire
	constructor: ->
		@line = svg.line()
		@n1 = new NodeBinding(new Node(50, 50))
		@n2 = new NodeBinding(new Node(100, 100))
		
		
		$(@line).attr
			'stroke-width': 2
			stroke: "#00f"
		@update()
		
		@n1.onMove = @update
		@n2.onMove = @update
	
	update: =>
		$(@line).attr {x1:@n1.node.x, y1:@n1.node.y, x2:@n2.node.x, y2:@n2.node.y}
		
	
		
		

$(window).ready ->
	$("<div id='svgcanvas'>").appendTo(document.body).svg onLoad: (_svg) ->
		svg = _svg
		console.log(svg)
		w = new Wire()
		w2 = new Wire()
		w3 = new Wire()
