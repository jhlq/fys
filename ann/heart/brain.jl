numneurons=9
net=rand(numneurons,numneurons)-0.5
exc=zeros(numneurons) #excitations
exc[1]=1

w=12
h=10
canvas=zeros(h,w)

loc=Integer[h-3,w/2]

function sigmoid(x)
	1/(1+exp(-x))
end
function sigmoid(a::Array)
	for xi in 1:length(a)
		a[xi]=1/(1+exp(-a[xi]))
	end
	return a
end

function step!(net,exc,loc,canvas)
	exc[1:end]=atan(net*exc)
	x=Integer(sign(exc[end-1]))
	y=Integer(sign(exc[end]))
	h,w=size(canvas)
	loc[1]=mod(loc[1]+x,h)
	loc[2]=mod(loc[2]+y,w)
	canvas[loc[1]+1,loc[2]+1]+=1
end

nstep=999
for st in 1:nstep
	step!(net,exc,loc,canvas)
end

#=
using Winston
imagesc(canvas)
=#
