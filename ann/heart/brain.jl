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
	tx,ty=abs(exc[end-1]),abs(exc[end])
	x,y=0,0
	if abs(tx-ty)/(tx+ty)>0.5
		if tx>ty
			x=Integer(sign(exc[end-1]))
		else
			y=Integer(sign(exc[end]))
		end
	else
		x=Integer(sign(exc[end-1]))
		y=Integer(sign(exc[end]))
	end
	h,w=size(canvas)
	t=min(loc[1]+x,w)
	loc[1]=t==0?1:t
	t=min(loc[2]+y,h)
	loc[2]=t==0?1:t
	canvas[loc[2],loc[1]]+=1
end
rnet()=rand(9,9)-0.5
function makedrawing(net=rnet(),steps=90)
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
	h,w=size(net)
	for hi in 1:h
		for wi in 1:w
			write(sn,"$(net[hi,wi])")
			if wi!=w
				write(sn,' ')
			end
		end
		if hi!=h
			write(sn,'\n')
		end
	end
	close(sn)
end
load(filename)=readdlm(filename,' ')

function scoredrawing(drawing)
	h,w=size(drawing)
	score=0
	for hi in 1:h
		for wi in 1:w
			if heart[hi,wi]==1 && drawing[hi,wi]==1
				score+=1
			end
		end
	end
	return score
end
scorenet(net,drawlen=90)=scoredrawing(makedrawing(net,drawlen))

function improvenet(net,drawlen=90,damping=10,maxiter=1000)
	neurons=size(net,1)
	score=scorenet(net,drawlen)
	for it in 1:maxiter
		newnet=net+(rand(neurons,neurons)-0.5)/damping
		newscore=scorenet(newnet,drawlen)
		if newscore>score
			print(newscore-score,' ')
			score=newscore
			net=newnet
		end
	end
	return net
end
