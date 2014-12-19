module F

export g0,g1,g2,g3,gmu,uv,uvv,t,getE,Psi1,wf,der,lap,guv

include("common.jl")

σ1=[0 1;1 0]
pm1=σ1
σ2=[0 -im;im 0]
pm2=σ2
σ3=[1 0;0 -1]
pm3=σ3
σi=Array[σ1,σ2,σ3]
pmi=σi
zer=[0 0;0 0]
Σ1=[σ1 zer;zer σ1]
Σ2=[σ2 zer;zer σ2]
Σ3=[σ3 zer;zer σ3]
Σi=Array[Σ1,Σ2,Σ3]
spinopi=Σi
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
gmu=Any[g0,g1,g2,g3]

function uv(p,m,ind::Integer) #u1, u2, v2, v1
	E=getE(p,m)#sqrt(norm(p)^2+m^2)
	Em=E+m
	C=sqrt(Em/2m)
	si=1
	if length(p)==4
		si=2
	end
	if ind==1
		return C*[1,0,p[si+2]/Em,(p[si]+im*p[si+1])/Em] #u1
	elseif ind==2
		return C*[0,1,(p[si]-im*p[si+1])/Em,-p[si+2]/Em] #u2
	elseif ind==3
		return C*[p[si+2]/Em,(p[si]+im*p[si+1])/Em,1,0] #v2
	elseif ind==4
		return C*[p[si+2]/Em,(p[si]+im*p[si+1])/Em,1,0] #v1
	end
end
function uvv(p,m)
	return Any[uv(p,m,1),uv(p,m,2),uv(p,m,3),uv(p,m,4)]
end
function getE(p,m)
	if length(p)==3
		return sqrt(norm(p)^2+m^2)
	elseif length(p)==4
		return sqrt(norm(p[2:end])^2+m^2)
	end
end
abstract PsiN<:State
type Psi1<:PsiN
	p
	m
end
guv=[1 0 0 0;0 -1 0 0;0 0 -1 0;0 0 0 -1]
function wf(psi::Psi1,X)
	u1=uv(psi.p,psi.m,1)
	sa=exp(-im*dot(psi.p,X))
	ra=sa.*u1
	#=ra={}
	for i in 1:4
		push!(ra,sa[i].*u1)
	end=#
	return ra
end
function der(psi::PsiN,X,d::Integer)
	-im*psi.p[d]*wf(psi,X)
end
function lap(psi::PsiN,X) #Laplacian
	Any[der(psi,X,1),der(psi,X,2),der(psi,X,3),der(psi,X,4)]
end
function DE(psi::PsiN,X)	#Dirac Equation 
	w=wf(psi,X)
	wd=der(psi,X)
	dm=[	wd[1] 0 wd[4] wd[2]-im*wd[3];
		0 wd[1] wd[2]+im*wd[3] -wd[4];
		-wd[4] -wd[2]+im*wd[3] -wd[1] 0;
		-wd[2]-im*wd[3] wd[4] 0 -wd[1];	]
	#ra={}
	#for i in 1:4
	#	push!(ra,im.*sum((dm[i,:].*w[i]))-psi.m.*w[1])
	#end	
	#return ra#im.*(dm*w)-psi.m.*w
	de1=im.*Any[wd[1][1], 0, wd[4][3], wd[2][4]-im*wd[3][4]]
	de2=im.*Any[0, wd[1][1], wd[2][2]+im*wd[3][3], -wd[4][4]]
end
function DE()
	p3=[0.1,0.2,0.3]
	m=0.5
	E=getE(p3,m)
	p=[E,p3]
	psi=Psi1(p,m)
	X=rand(4)
	w=wf(psi,X)
	wd=lap(psi,X)
	de1=im.*[wd[1][1], 0, -wd[4][3], -wd[2][4]+im*wd[3][4]]
	de2=im.*[0, wd[1][2], -wd[2][3]-im*wd[3][3], wd[4][4]]
	de3=im.*[wd[4][1], wd[2][2]-im*wd[3][2], -wd[1][3], 0]
	de4=im.*[wd[2][1]+im*wd[3][1], -wd[4][2], 0, -wd[1][4]]
	des=[sum(de1),sum(de2),sum(de3),sum(de4)]/m
end
type Σ<:Operator
	axis::Integer
end
SpinOp=Σ
	
function t()
	t1();t2();t3()
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
function t3()
	p=rand(3)
	m=rand()
	psi1=Psi1([getE(p,m),p],m)
	d=1e-9
	X=rand(4)
	Xd=zeros(4)
	Xd+=X
	Xd[1]+=d
	w1=wf(psi1,X)
	w2=wf(psi1,Xd)
	wd=der(psi1,X,1)
	for i in 1:4
		assert(wd[i],(w2[i]-w1[i])/d)
	end
	print_with_color(:green,"3")
end
function t4()
	p=rand(3)
	m=rand()
	psi1=Psi1([getE(p,m),p],m)
	d=1e-9
	X=rand(4)
	w1=wf(psi1,X)	
	wd=lap(psi1,X)
	for i in 1:4
		Xd=deepcopy(X)
		Xd[i]+=d
		w2=wf(psi1,Xd)
		for j in 1:4
			assert(wd[i][j],(w2[j]-w1[j])/d)
		end
	end
	print_with_color(:green,"4")
end

end
