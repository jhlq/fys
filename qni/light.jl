L=2pi
ns=1000
rs=linspace(0,L,ns)
dx=L/1000
ca=map(cos,rs)
sa=map(sin,rs)
#E=[sa -2sa sa]
B=[ca -2ca ca]

function der{T}(psa::Array{T})
	lt=size(psa)
	n=1
	if length(lt)==2
		l=lt[1]
		n=lt[2]
	elseif length(lt)==1
		l=lt[1]
	else
		error("Too many (or too few) dimensions.")
	end	
	psap=zeros(T,l,n)
	#print(size(psap))
	for j in 1:n
		for i in 2:l-1
			psap[i,j]=((psa[i+1,j]-psa[i,j])+(psa[i,j]-psa[i-1,j]))/2/dx
		end
	end
	return psap
end
function invder{T}(psa::Array{T})
	lt=size(psa)
	n=1
	if length(lt)==2
		l=lt[1]
		n=lt[2]
	elseif length(lt)==1
		l=lt[1]
	else
		error("Too many (or too few) dimensions.")
	end	
	psap=zeros(T,l,n)
	#print(size(psap))
	for j in 1:n
		tot=0
		for i in 2:l-1
			tot+=((psa[i+1,j]+psa[i,j])/2*dx+(psa[i,j]+psa[i-1,j])/2*dx)/2
			psap[i,j]=tot
		end
	end
	return psap
end
function curl(F)
	[(der(F[:,3]).-der(F[:,2]))  (der(F[:,1]).-der(F[:,3]))  (der(F[:,2]).-der(F[:,1]))]
end
function divergence(F)
	der(F[:,1])+der(F[:,2])+der(F[:,3])
end


B=[ca -2ca ca]
D=invder(curl(B))
