
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
				$(@dot).addClass 'link-drag'
			else
				$(@dot).removeClass 'link-drag'
			
			$(@dot).attr {cx: @x, cy:@y}
			@onMove(dx, dy, @x, @y)
			
		drop = (event) =>
			l = @findLink()
			if l
				boundTo = @boundTo
				@boundTo = []
				for i in boundTo
					console.log 'binding', @boundTo, i, l
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
	
	onMove: ->
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
	
	update: =>
		$(@line).attr {x1:@n1.node.x, y1:@n1.node.y, x2:@n2.node.x, y2:@n2.node.y}


$(window).ready ->
	$("<div id='svgcanvas'>").appendTo(document.body).svg onLoad: (_svg) ->
		svg = _svg
		console.log(svg)
		w1 = new Wire(50, 50, 100, 100)
		w2 = new Wire(50, 80, 90, 80)
		w3 = new Wire(80, 50, 120, 120)
		w3 = new Wire(140, 140, 100, 50)
