storage=Dict()
storage[:players]=[(1,0,0),(0,1,0)]
storage[:player]=1
storage[:layers]=5
storage[:window]=(900,700)
storage[:size]=storage[:window][2]/(storage[:layers]*3)

function makegrid(layers=3)
	grid=Set{Tuple}()
	push!(grid,(0,0,2))
	connections=[(1,0,0),(-1,0,0),(0,1,0),(0,-1,0),(1,-1,0),(-1,1,0), (0,0,1),(1,0,1),(0,1,1),(0,0,-1),(1,0,-1),(1,-1,-1)]
	for layer in 2:layers
		tgrid=Array{Tuple,1}()
		for loc in grid
			if loc[3]==2
				for c in connections
					x,y,z=loc
					x+=c[1];y+=c[2];z+=c[3]
					push!(tgrid,(x,y,z))
				end
			end
		end
		for t in tgrid
			push!(grid,t)
		end
	end
	return grid
end
storage[:grid]=makegrid(storage[:layers])
storage[:map]=Dict((0,0,0)=>0)
for loc in storage[:grid]
	storage[:map][loc]=0
end

g=makegrid(3)
@assert length(g)==43
function hex_to_pixel(q,r,size=storage[:size])
    x = size * sqrt(3) * (q + r/2)
    y = size * 3/2 * r
    return x, y
end
function pixel_to_hex(x, y, size=storage[:size])
    q = (x * sqrt(3)/3 - y / 3) / size
    r = y * 2/3 / size
    return (q, r)
end

using Gtk, Graphics
c = @GtkCanvas()
win = GtkWindow(c, "Hexiqi",storage[:window][1],storage[:window][2])

function triangle(ctx,x,y,size,up=-1)
	polygon(ctx, [Point(x,y),Point(x+size,y),Point(x+size/2,y+up*size)])
	fill(ctx)
end
function hexlines(ctx,x,y,size)
	size*=2
	move_to(ctx,x-size/4,y-size*sin(pi/3)/2)
	rel_line_to(ctx,size/2,size*sin(pi/3))
	move_to(ctx,x-size/2,y)
	rel_line_to(ctx,size,0)
	move_to(ctx,x+size/4,y-size*sin(pi/3)/2)
	rel_line_to(ctx,-size/2,size*sin(pi/3))
	stroke(ctx)
end
function drawboard(ctx,w,h)
	size=storage[:size]
	set_source_rgb(ctx, 0,0,0)
	for loc in storage[:grid]
		if loc[3]==2
			x,y=hex_to_pixel(loc[1],loc[2],size)
			hexlines(ctx,x+w/2,y+h/2,size)
		end
	end
	for move in storage[:map]
		if move[2]>0
			set_source_rgb(ctx, storage[:players][move[2]]...)
			offset=(0,0)
			if move[1][3]==1
				offset=(-cos(pi/6)*size,sin(pi/6)*size)
			elseif move[1][3]==3
				offset=(-cos(pi/6)*size,-sin(pi/6)*size)
			end
			loc=hex_to_pixel(move[1][1],move[1][2])
			#println(loc)
			arc(ctx, loc[1]+offset[1]+w/2, loc[2]+offset[2]+h/2, size/3, 0, 2pi)
			fill(ctx)
		end
	end
end
@guarded draw(c) do widget
    ctx = getgc(c)
    h = height(c)
    w = width(c)
	storage[:window]=(w,h)
	storage[:size]=storage[:window][2]/(storage[:layers]*3)
    # Paint red rectangle
    #rectangle(ctx, 0, 0, w, h/2)
    #set_source_rgb(ctx, 1, 0, 0)
    #fill(ctx)
    # Paint blue rectangle
    rectangle(ctx, 0, 3h/4, w, h/4)
    set_source_rgb(ctx, 0, 0, 1)
    fill(ctx)
#	polygon(ctx, [Point(50,100),Point(100,100),Point(75,100-50sin(pi/3))])
#	set_source_rgb(ctx, 0.9, 0.6, 0.7)
#	fill(ctx)
#	triangle(ctx,150,200,30)
#	triangle(ctx,150,200,30,1)
#	set_source_rgb(ctx, 1, 0, 0)
#	move_to(ctx,70,70)
#	rel_line_to(ctx,15,15)
#	stroke(ctx)
	set_source_rgb(ctx,0,0,0)
	size=storage[:size]
#	x,y=hex_to_pixel(1,2,size)
#	hexlines(ctx,x,y,size)
#	x,y=hex_to_pixel(1,1,size)
#	hexlines(ctx,x,y,30)
#	for i in 1:9
#		for j in 1:9
#			x,y=hex_to_pixel(i,j,size)
#			hexlines(ctx,x,y,size)
#		end
#	end
	drawboard(ctx,w,h)
	
	
end

c.mouse.button1press = @guarded (widget, event) -> begin
    ctx = getgc(widget)
    #set_source_rgb(ctx, 0, 1, 0)
#	set_source_rgb(ctx, storage[:players][storage[:player]]...)
#    arc(ctx, event.x, event.y, 5, 0, 2pi)
#    stroke(ctx)

	h = height(c)
	w = width(c)
	size=storage[:size]
	q,r=pixel_to_hex(event.x-w/2,event.y-h/2)
	maindiff=abs(round(q)-q)+abs(round(r)-r)
	qup,rup=pixel_to_hex(event.x-w/2+size*cos(pi/6),event.y-h/2+sin(pi/6)*size)
	updiff=abs(round(qup)-qup)+abs(round(rup)-rup)
	qdown,rdown=pixel_to_hex(event.x-w/2+size*cos(pi/6),event.y-h/2-sin(pi/6)*size)
	downdiff=abs(round(qdown)-qdown)+abs(round(rdown)-rdown)
	best=findmin([maindiff,updiff,downdiff])[2]
	hex=[(round(Int,q),round(Int,r),2),(round(Int,qup),round(Int,rup),3),(round(Int,qdown),round(Int,rdown),1)][best]
	if in(hex,keys(storage[:map])) && storage[:map][hex]==0
		storage[:map][hex]=storage[:player]
		storage[:player]=storage[:player]%length(storage[:players])+1
	end
#	println((event.x-w/2,event.y-h/2),',',["main","up","down"][best])
	drawboard(ctx,w,h)
	reveal(widget)
	
end
show(c)
