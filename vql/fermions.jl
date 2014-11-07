module F

export g0,g1,g2,g3,gmu,uv,uvv,t,getE

include("common.jl")

pm1=[0 1;1 0]
pm2=[0 -im;im 0]
pm3=[1 0;0 -1]

function gamma(mu::Integer)
	if mu==0
		return [eye(2) 0*eye(2);0*eye(2) -eye(2)]
	elseif mu==1
		return [0*eye(2) pm1;-pm1 0*eye(2)]
	elseif mu==2
		return [0*eye(2) pm2;-pm2 0*eye(2)]
	elseif mu==3
		return [0*eye(2) pm3;-pm3 0*eye(2)]
	else
		return 0
	end
end
g0=gamma(0);g1=gamma(1);g2=gamma(2);g3=gamma(3)
gmu={g0,g1,g2,g3}

function uv(p,m,ind::Integer) #u1, u2, v2, v1
	E=sqrt(norm(p)^2+m^2)
	Em=E+m
	C=sqrt(Em/2m)
	if ind==1
		return C*[1,0,p[3]/Em,(p[1]+im*p[2])/Em] #u1
	elseif ind==2
		return C*[0,1,(p[1]-im*p[2])/Em,-p[3]/Em] #u2
	elseif ind==3
		return C*[p[3]/Em,(p[1]+im*p[2])/Em,1,0] #v2
	elseif ind==4
		return C*[p[3]/Em,(p[1]+im*p[2])/Em,1,0] #v1
	end
end
function uvv(p,m)
	return {uv(p,m,1),uv(p,m,2),uv(p,m,3),uv(p,m,4)}
end
function getE(p,m)
	return sqrt(norm(p)^2+m^2)
end
function t()
	t1();t2()
end
function t1()
	for i in 1:4
		@assert g0*gmu[i]*g0==gmu[i]'
	end
	print_with_color(:green,"1")
end
function t2()
	p=rand(3)
	m=rand()
	E=getE(p,m)
	uvs=uvv(p,m)
	for i in 1:4
		res=(uvs[i]'*uvs[i])[1]
		assert(imag(res),0)
		assert(real(res),E/m)
	end
	print_with_color(:green,"2")
end

end
