#module Hexiqi

storage=Dict()
storage[:players]=[(1,0,0),(0,1,0),(0,0,1),(1,1,1)]
storage[:player]=1
storage[:lock]=false
lock=()->storage[:lock]=!storage[:lock]
storage[:np]=3 #numplayers
np=(n)->storage[:np]=n
storage[:layers]=5
storage[:window]=(900,700)
storage[:size]=storage[:window][2]/(storage[:layers]*3)
storage[:sequence]=Array{Tuple,1}()
storage[:delete]=false
delete=()->storage[:delete]=!storage[:delete]
storage[:connectivity]=[(1,0,0),(-1,0,0),(0,1,0),(0,-1,0),(1,-1,0),(-1,1,0), (0,0,1),(1,0,1),(0,1,1),(0,0,-1),(1,0,-1),(1,-1,-1)]

using Gtk, Graphics
c = @GtkCanvas()
win = GtkWindow(c, "Hexiqi",storage[:window][1],storage[:window][2])
#storage[:ctx]=getgc(c)

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
storage[:map]=Dict((0,0,2)=>0)
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
	rectangle(ctx, 0, 0, w, h)
	set_source_rgb(ctx, 1, 1, 1)
	fill(ctx)
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
	set_source_rgb(ctx, storage[:players][storage[:player]]...)
	arc(ctx, size, size, size/3, 0, 2pi)
	fill(ctx)
end
function resetmap()
	for loc in storage[:grid]
		storage[:map][loc]=0
	end
	#drawboard()
	#reveal(c,true)
end

function adjacent(hex,spacing=1,layer=false)
	connections=[(1,0,0),(-1,0,0),(0,1,0),(0,-1,0),(1,-1,0),(-1,1,0), (0,0,1),(1,0,1),(0,1,1),(0,0,-1),(1,0,-1),(1,-1,-1)]
	if layer
		connections=[(1,0,0),(-1,0,0),(0,1,0),(0,-1,0),(1,-1,0),(-1,1,0)]
	end
	if hex[3]==1
		if layer
			connections=[(1,0,0),(-1,0,0),(0,1,0),(0,-1,0),(1,-1,0),(-1,1,0)]
		else
			connections=[(1,0,0),(-1,0,0),(0,1,0),(0,-1,0),(1,-1,0),(-1,1,0), (0,0,1),(-1,0,1),(-1,1,1)]
		end
	elseif hex[3]==3
		if layer
			connections=[(1,0,0),(-1,0,0),(0,1,0),(0,-1,0),(1,-1,0),(-1,1,0)]
		else
			connections=[(1,0,0),(-1,0,0),(0,1,0),(0,-1,0),(1,-1,0),(-1,1,0),(0,0,-1),(-1,0,-1),(0,-1,-1)]
		end
	end
	adj=Array{Tuple,1}()
	for c in connections
		x,y,z=hex
		x+=spacing*c[1];y+=spacing*c[2];z+=spacing*c[3]
		push!(adj,(x,y,z))
	end
	return adj
end
function placewhite(spacing::Integer)
	ori=(0,0,2)
	white=length(storage[:players])
	storage[:map][ori]=white
	placed=[ori]
	adj=adjacent(ori,spacing,true)
	for ad in adj
		storage[:map][ad]=white
		push!(placed,ad)
	end
end
function getgroup(hex)
	player=storage[:map][hex]
	if player==0
		return []
	end
	group=Tuple[hex]
	temp=[hex]
	while !isempty(temp)
		temp2=Tuple[]
		for t in temp
			for h in adjacent(t)
				if !in(h,group) && !in(h,temp) && !in(h,temp2) && in(h,keys(storage[:map])) && storage[:map][h]==player
					push!(temp2,h)
				end
			end
		end
		for t2 in temp2
			push!(group,t2)
		end
		temp=temp2
	end
	return group
end
function liberties(group)
	if isempty(group)
		return 1
	end
	checked=Tuple[]
	libs=0
	for hex in group
		for h in adjacent(hex)
			if !in(h,group) && !in(h,checked) && in(h,keys(storage[:map]))
				if storage[:map][h]==0
					libs+=1
				end
				push!(checked,h)
			end
		end
	end
	return libs
end
function connections()
	nc=0
	for (loc,col) in storage[:map]
		if col>0 
			for c in adjacent(loc)
				if in(c,keys(storage[:map]))
					ac=storage[:map][c]
					if ac!=0 && ac!=col
						nc+=1
					end
				end
			end
		end
	end
	return nc/2
end
function surrounded(layer::Integer)
	checked=[(0,0,2)]
	points=Dict()
	for (loc,col) in storage[:map]
		if col==0
			if !in(loc,checked)
				push!(checked,loc)
				locs=[loc]
				check=adjacent(loc)
				while !empty(check)
					ncheck=Array{Tuple,1}()
					for ch in check
						col=storage[:map][ch]
						if col==0

						end
					end
				end
			end
		end
	end
end

function harvest()

end
function score()
	claims=Dict()
	for player in 1:storage[:np]
		checked=Tuple[]
		for hexp in storage[:map]
			hex,p=hexp
			if p==player
				if in(hex,keys(claims)) 
					if claims[hex][p]<1
						claims[hex][p]=1.0
					end
				else
					a=zeros(storage[:np])
					a[p]=1.0
					claims[hex]=a
				end
				for ahex in adjacent(hex)
					if !in(ahex,checked) && in(ahex,storage[:grid])
						if in(ahex,keys(claims)) 
							if claims[ahex][p]<0.5
								claims[ahex][p]=0.5
							end
						else
							a=zeros(storage[:np])
							a[p]=0.5
							claims[ahex]=a
						end
					end
				end
				push!(checked,hex)
			end
		end
	end
	scores=zeros(storage[:np])
	for hexa in claims
		hex,a=hexa
		m=maximum(a)
		inds=findin(a,m)
		l=length(inds)
		for p in inds
			scores[p]+=1/l #add complementary harvesting, two 0.5 claims don't conflict since one can't harvest all
		end #subtract 0.001 per unit
	end
	maxpoints=length(storage[:map])
	return scores,maxpoints
end
function undo() #wont undo captures
	hex=pop!(storage[:sequence])
	storage[:map][hex]=0
	storage[:player]=storage[:player]-1
	if storage[:player]<1
		storage[:player]=storage[:np]
	end
	return hex
end
function pass()
	storage[:player]=storage[:player]%storage[:np]+1
end
@guarded draw(c) do widget
    ctx = getgc(c)
    h = height(c)
    w = width(c)
	storage[:window]=(w,h)
	storage[:size]=storage[:window][2]/(storage[:layers]*3)
    
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
	exists=in(hex,keys(storage[:map]))
	if exists
		if storage[:delete]==true && storage[:map][hex]!=0
			storage[:map][hex]=0
		elseif storage[:map][hex]==0
			storage[:map][hex]=storage[:player]
			push!(storage[:sequence],hex)
			hs=adjacent(hex)
			push!(hs,hex)
			for he in hs
				if in(he,keys(storage[:map]))
					g=getgroup(he)
					if !isempty(g) && liberties(g)==0
						for gh in g
							storage[:map][gh]=0
						end
					end
				end
			end
			if !storage[:lock]
				storage[:player]=storage[:player]%storage[:np]+1
			end
		end
	end
#	println((event.x-w/2,event.y-h/2),',',["main","up","down"][best])
	drawboard(ctx,w,h)
	reveal(widget)
	
end
show(c)

#end
