include("heart.jl")
heart=drawheart!()

numneurons=9
net=rand(numneurons,numneurons)-0.5
exc=zeros(numneurons) #excitations
exc[1]=1

w=120
h=100
canvas=zeros(h,w)

loc=Integer[w/2,h]

#=

function sigmoid(x)
	1/(1+exp(-x))
end
function sigmoid(a::Array)
	for xi in 1:length(a)
		a[xi]=1/(1+exp(-a[xi]))
	end
	return a
end
nstep=999
for st in 1:nstep
	step!(net,exc,loc,canvas)
end
=#

function step!(net,exc,loc,canvas)
	exc[1:end]=atan(net*exc)
	x=Integer(sign(exc[end-1]))
	y=Integer(sign(exc[end]))
	h,w=size(canvas)
	loc[1]=mod(loc[1]+x,w)
	loc[2]=mod(loc[2]+y,h)
	canvas[loc[2]+1,loc[1]+1]+=1
end
rnet()=rand(9,9)-0.5
function makedrawing(net=rnet(),steps=300)
	h=100;w=120
	canvas=zeros(h,w)
	neurons=size(net,1)
	exc=zeros(neurons) #excitations
	exc[1]=1
	loc=Integer[w/2,h]
	for st in 1:steps
		step!(net,exc,loc,canvas)
	end
	return canvas
end

#=
using Winston
imagesc(canvas)
=#

function save(net,filename)
	sn=open(filename,"w") #write append
	write(sn,"$net")
	close(sn)
end
