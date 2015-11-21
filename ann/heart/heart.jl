function topol(x,y,o)

end
function frompol(r,th,o)
	x=round(o[1]+r*cos(th))
	y=round(o[2]+r*sin(th))
	return [x,y]
end
function spiral(th)
	return exp(th/2)
end

w=120
h=100
canvas=zeros(h,w)
o=[w/2,h-h/5]

#spiral->map to array of length 628-> assemble matrix: 
#coord=[ox+r*cos(ind/100),oy+r*sin(ind/100)]
#iterate over canvas and fill every point within a certain distance from coord
function drawheart!(canvas=zeros(100,120))
	h,w=size(canvas)
	o=[w/2,h/5]
	f=x->x
	a=map(f,1:314)
	a/=maximum(a)
	r=h-h/4
	spiralx=Any[o[1]]
	spiraly=Any[o[2]]
	for i in 1:length(a)
		coord=[o[1]+r*a[i]*cos(i/100-pi/2),o[2]+r*a[i]*sin(i/100-pi/2)]
		coordr=[o[1]+r*a[i]*cos(-i/100-pi/2),o[2]+r*a[i]*sin(-i/100-pi/2)]
		push!(spiralx,coord[1],coordr[1])
		push!(spiraly,coord[2],coordr[2])
	end

	distance(p1,p2)=sqrt((p1[1]-p2[1])^2+(p1[2]-p2[2])^2)
	for i in 1:h
		for j in 1:w
			for poind in 1:length(spiralx)
				if distance([j,i],[spiralx[poind],spiraly[poind]])<5
					canvas[i,j]=1
				end
			end
		end
	end
	return canvas
end
function heartarrays(h=100,w=120)
	o=[w/2,h/5]
	f=x->x
	a=map(f,1:314)
	a/=maximum(a)
	r=h-h/4
	#spiralx=Any[o[1]]
	#spiraly=Any[o[2]]
	leftx=AbstractFloat[o[1]]
	lefty=AbstractFloat[o[2]]
	rightx=AbstractFloat[o[1]]
	righty=AbstractFloat[o[2]]
	for i in 1:length(a)
		coordr=[o[1]+r*a[i]*cos(i/100-pi/2),o[2]+r*a[i]*sin(i/100-pi/2)]
		coordl=[o[1]+r*a[i]*cos(-i/100-pi/2),o[2]+r*a[i]*sin(-i/100-pi/2)]
		if i%5==0
			#push!(spiralx,coord[1],coordr[1])
			#push!(spiraly,coord[2],coordr[2])
			push!(leftx,coordl[1])
			push!(lefty,coordl[2])
			push!(rightx,coordr[1])
			push!(righty,coordr[2])
		end
	end
	return leftx,lefty,rightx,righty
end

#canvas->iterate each point
