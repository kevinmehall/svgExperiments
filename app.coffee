
paper = false

RADIUS = 5

allNodes = []

class Node
	constructor: (@x, @y) ->
		allNodes.push this
		@dot = paper.circle(@x, @y, RADIUS)
		
		@dot.attr
			stroke: "#00f"
			fill: "#00f"
			'fill-opacity': 0.2
			'stroke-width': 2
			
		@dot.mouseover ->
			@animate 'fill-opacity':1, 200
			
		@dot.mouseout ->
			@animate 'fill-opacity':0.2, 200
		
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
					
			
			@dot.attr {cx: @x, cy:@y, fill:if @linked then '#0f0' else '#00f'}
			@onMove(dx, dy, @x, @y)
		
		@dot.drag(move, start, @onDrop)
		
	onMove: ->
	onDrop: ->
		

class Wire
	constructor: ->
		@line = paper.path()
		@n1 = new Node(50, 50)
		@n2 = new Node(100, 100)
		
		
		@line.attr
			'stroke-width': 2
			stroke: "#00f"
		@update()
		
		@n1.onMove = @update
		@n2.onMove = @update
	
	update: =>
		@line.attr "path", "M#{@n1.x} #{@n1.y}L#{@n2.x} #{@n2.y}"
		
	
		
		

window.onload = ->
	paper = Raphael(0, 0, 800, 800)
	w = new Wire()
	w2 = new Wire()
	w3 = new Wire()
