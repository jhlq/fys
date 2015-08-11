include("heart.jl")
#const heart=drawheart!()
#const heartx,hearty=heartarrays()

#=
numneurons=9
net=rand(numneurons,numneurons)-0.5
exc=zeros(numneurons) #excitations
exc[1]=1

w=120
h=100
canvas=zeros(h,w)

loc=Integer[w/2,h]
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
	#t=min(loc[1]+x,w)
	#loc[1]=t==0?1:t
	#t=min(loc[2]+y,h)
	#loc[2]=t==0?1:t
	loc[1]+=x
	loc[2]+=y
	if 0<loc[1]<=w && 0<loc[2]<=h
		canvas[loc[2],loc[1]]+=1
	end
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
function makedrawing(net1,net2,steps,h=100,w=120)
	canvas=zeros(h,w)
	n1=size(net1,1)
	exc1=zeros(n1) #excitations
	exc1[1]=1
	loc1=Integer[w/2,h]
	n2=size(net2,1)
	exc2=zeros(n2)
	exc2[1]=1
	loc2=Integer[w/2,h]
	for st in 1:steps
		step!(net1,exc1,loc1,canvas)
		step!(net2,exc2,loc2,canvas)
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

function scoredrawing_dep(drawing)
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
function scoredrawing(drawing,heartx,hearty)
	score=0
	for i in 1:length(heartx)
		x,y=round(Int,heartx[i]),round(Int,hearty[i])
		brk=false
		for xi in x-3:x+3
			for yi in y-3:y+3
				if drawing[yi,xi]>0
					score+=1
					brk=true
					break
				end
			end
			if brk
				break
			end
		end
	end
	return score
end
scoredrawing(drawing,t::Tuple)=scoredrawing(drawing,t[1],t[2])+scoredrawing(drawing,t[3],t[4])
scorenet(net,heartx,hearty,drawlen=90)=scoredrawing(makedrawing(net,drawlen),heartx,hearty)

function improvenet(net,maxiter=1000,damping=10,drawlen=90,right=true)
	neurons=size(net,1)
	heart=heartarrays()
	if right
		heartx,hearty=heart[3],heart[4]
	else
		heartx,hearty=heart[1],heart[2]
	end
	score=scorenet(net,heartx,hearty,drawlen)
	for it in 1:maxiter
		newnet=net+(rand(neurons,neurons)-0.5)/damping
		newscore=scorenet(newnet,heartx,hearty,drawlen)
		if newscore>score
			print(newscore-score,' ')
			score=newscore
			net=newnet
		end
	end
	print(score)
	return net
end
function improvenet2(net,maxiter=1000,damping=10,nmod=3,drawlen=90,right=true)
	neurons=size(net,1)
	heart=heartarrays()
	if right
		heartx,hearty=heart[3],heart[4]
	else
		heartx,hearty=heart[1],heart[2]
	end
	score=scorenet(net,heartx,hearty,drawlen)
	for it in 1:maxiter
		newnet=deepcopy(net)
		for n in 1:nmod
			r1,r2=mod(rand(Int),neurons)+1,mod(rand(Int),neurons)+1
			newnet[r1,r2]+=(rand()-0.5)/damping
		end
		newscore=scorenet(newnet,heartx,hearty,drawlen)
		if newscore>score
			print(newscore-score,' ')
			score=newscore
			net=newnet
		end
	end
	print(score)
	return net
end
