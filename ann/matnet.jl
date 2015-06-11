function feed(signal,con)
	l=length(signal)
	nn=size(con)[1]
	exc=zeros(1,nn)
	output=zeros(l)
	for s in 1:l
		exc[1]+=signal[s]
		exc=exc*con
		output[s]=exc[nn]
	end
	return output
end
function loop(inits,con,loops)
	sl=length(inits)
	nn=size(con)[1]
	exc=zeros(1,nn)
	output=zeros(sl+loops)
	for s in 1:sl
		exc[1]+=inits[s]
		exc=exc*con
		#print("$(exc[nn]) ")
		output[s]=exc[nn]
	end
	for s in 1:loops
		exc[1]+=exc[nn]
		exc=exc*con
		#print("$(exc[nn]) ")
		output[sl+s]=exc[nn]
	end
	#print("\n")
	return output
end
function save(nets,filename)
	sn=open(filename,"w") #write append
	write(sn,"$nets")
	close(sn)
end
function load(filename)
	nets=readdlm(filename,'\t')
	nn=size(nets)[2]
	nnn=convert(Int64,size(nets)[1]/nn)
	fnets=zeros(nn,nn,nnn)
	for n in 1:nnn
		fnets[:,:,n]=nets[(1+(n-1)*3):(1+(n-1)*3+2),:]
	end
	return fnets
end
function plotnets(nets,signal)
	nnn=1
	if ndims(nets)>2
		nnn=size(nets)[3]
	end
	for n=1:nnn
		o=feed(signal,nets[:,:,n])
		figure(n)
		plot(o)
	end
end
function mutate(onets,nmutas=3,filter=0)
	nets=deepcopy(onets)
	nn=size(nets)[1]
	nnn=1
	if ndims(nets)>2
		nnn=size(nets)[3]
	end
	if filter==0
		filter=ones(nn,nn)
	end
	for net in 1:nnn
		mutations=zeros(nn,nn)
		for m in 1:nmutas
			r1=abs(rand(Int64)%nn)+1
			r2=abs(rand(Int64)%nn)+1
			mutations[r1,r2]+=rand()-0.5
		end
		nets[:,:,net]+=mutations.*filter
	end
	return nets
end
function rescue(nets,these) #[nets, to, be, rescued]
	nn=size(nets)[1]
	nr=length(these)
	rescued=zeros(nn,nn,nr)
	for n in 1:nr
		rescued[:,:,n]=nets[:,:,these[n]]
	end
	return rescued
end
function skeleton(nn)
	net=zeros(nn,nn)
	for n in 1:(nn-1)
		net[n,n+1]=1
	end
	net[nn,1]=1
	return net
end	
function skeletons(nn,nnn)
	nets=zeros(nn,nn,nnn)
	for net in 1:nnn
		nets[:,:,net]=skeleton(nn)
	end
	return nets
end	
function mergenets(net,nets)
	totnets=0
	if ndims(nets)>2
		totnets+=size(nets)[3]
	else 
		totnets+=1
	end
	n1=1
	if ndims(net)>2
		n1=size(net)[3]
		totnets+=n1
	else 
		totnets+=1
	end
	nn=size(net)[1]
	mnet=zeros(nn,nn,totnets)
	mnet[:,:,1:n1]=net
	mnet[:,:,(n1+1):end]=nets
	return mnet
end
function breed(net, nchildren)
	nn=size(net)[1]
	children=zeros(nn,nn,nchildren)
	for c in 1:nchildren
		children[:,:,c]=mutate(net)
	end
	return children
end

#ri[r1,r2]=rand()-0.5
"""
nn=3
nnn=2
exc=zeros(1,nn)
con=zeros(nn,nn)
nets=zeros(nn,nn,nnn)
for n=1:(nn-1)
	con[n,n+1]=0.8
end
ri=zeros(nn,nn)
r1=abs(rand(Int32)%nn)+1
r2=abs(rand(Int32)%nn)+1
ri[r1,r2]=rand()-0.5
r1=abs(rand(Int32)%nn)+1
r2=abs(rand(Int32)%nn)+1
ri[r1,r2]+=rand()-0.5
r1=abs(rand(Int32)%nn)+1
r2=abs(rand(Int32)%nn)+1
ri[r1,r2]+=rand()-0.5
nets[:,:,1]=con[:,:]+ri
ri=zeros(nn,nn)
r1=abs(rand(Int32)%nn)+1
r2=abs(rand(Int32)%nn)+1
ri[r1,r2]=rand()-0.5
r1=abs(rand(Int32)%nn)+1
r2=abs(rand(Int32)%nn)+1
ri[r1,r2]+=rand()-0.5
r1=abs(rand(Int32)%nn)+1
r2=abs(rand(Int32)%nn)+1
ri[r1,r2]+=rand()-0.5
nets[:,:,2]=con[:,:]+ri

#con[1,nn]=-0.5
#con[nn,nn]=0.3

s=[ones(3),zeros(nn)]
sig=[0.5,0,0.5,0.5]
o1=loop(sig,con,30)
o2=loop(sig,nets[:,:,1],30)
o3=loop(sig,nets[:,:,2],30)
figure(1)
plot(o1)
figure(2)
plot(o2)
figure(3)
plot(o3)
"""

