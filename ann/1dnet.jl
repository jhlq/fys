nn=3
excitations=zeros(nn)
excbuf=zeros(nn)
connections=zeros(nn,nn)
for n=1:(nn-1)
	connections[n,n+1]=1
end

excitations[1]=1
for n=1:(nn-1)
	for a=1:nn
		excbuf[a]+=excitations[n]*connections[n,a]
	end
	excitations[n]=0
	excitations=excbuf
	println(excitations)
end
