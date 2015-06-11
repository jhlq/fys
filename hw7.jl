*(f1::Function,f2::Function)=[f1,f2]
*(f::Function,psa::Array)=f(psa)
*(fa::Array{Function,1},f::Function)=push!(fa,f)
function *(fa::Array{Function,1},psa::Array)
	p=psa	
	for f in fa
		p=f(p)
	end
	return p
end
+(f1::Function,f2::Function)=(ma=Array(Array{Function,1},2);ma[1]=[f1];ma[2]=[f2];ma)
function *(fa::Array{Array{Function,1},1},f::Function)
	nfp=length(fa[:])
	#nfa=Array(Function,nfm,nfp)
	for np in 1:nfp
		#nfa[nm,np]=fa[n]*f
		fa[np]*f
	end
	#return nfa
end
function *{T}(fa::Array{Function,2},psa::Array{T})
	nf=length(fa)
	nfa=Array(Array{T},nf)	
	for n in 1:nf
		nfa[n]=fa[n]*psa
	end
	return nfa
end
function *{T}(ft::Array{Array{Function,1},1},psa::Array{T})
#	println("Not redundant!")
	nfa=length(ft)
	psatot=Array(Array{T,1},nfa)
	for n in 1:nfa
		#nf=length(ft[n])
		#ft[n]=ft[n]*psa
#		println(ft[n])
		psatot[n]=ft[n]*psa
	end
#	println(psatot)
	return sum(psatot)
end

ħ=1/2pi
hbar=ħ
m=1.11
ω=3
om=ω
ns=1000
L=5pi
rs=linspace(-L,L,ns)
dx=2L/ns
function der{T}(psi::Array{T})
	l=length(psi)
	psip=zeros(T,l)
	for i in 2:l-1
		psip[i]=((psi[i+1]-psi[i])+(psi[i]-psi[i-1]))/2/dx
	end
	return psip
end
psi0=x->(m*ω/(pi*ħ))^(1/4)*exp(-m*ω/(2*ħ)*x^2)
psa0=map(psi0,rs)
psa0c=convert(Array{Complex,1},psa0)
H=psa->-psa[5:end-5]'*hbar^2/2m*(der*der*psa)[5:end-5]*dx+psa[5:end-5]'*m*om^2/2*(rs.^2.*psa)[5:end-5]*dx
bH=(psa,rs)->-psa[5:end-5]'*(hbar^2/2m.*(der*der*psa))[5:end-5]*dx+psa[5:end-5]'*(m*om^2/2.*rs.^2.*psa)[5:end-5]*dx+psa[5:end-5]'*(m.*g.*rs[5:end-5].*psa[5:end-5])*dx
E0=H(psa0)

g=9.8
d=sqrt(hbar/(m*om))
V=m*g.*rs
H3=(psa,rs)->-hbar^2/2m*(der*der*psa)[5:end-5]+m*om^2/2*(rs.^2.*psa)[5:end-5]
lhs=H3(1./psa0[452:550],rs[452:550]).-E0.*(1./psa0[457:546])
p1=-1./(lhs./V[457:546])
A=sum((psa0[457:546].*p1).^2)*dx
ptn=psa0[457:546].*p1./sqrt(A)

E2=psa0[457:546]'*(V[457:546].*p1)*dx


function delv(p3,r1,r2,r3)
	if length(p3(r1,r2,r3))==1
		return [(x->p3(x,r2,r3))'(r1),(x->p3(r1,x,r3))'(r2),(x->p3(r1,r2,x))'(r3)]
	else
		return [(x->p3(x,r2,r3))'(r1)[1],(x->p3(r1,x,r3))'(r2)[2],(x->p3(r1,r2,x))'(r3)[3]]
	end
end
function Lv(p3::Function)
	(r1,r2,r3)->-im*ħ.*cross([r1,r2,r3],delv(p3,r1,r2,r3))
end
#function Lv2(p)
#	map(p,[-5:0.01:5])'*map(
#sum(Lv(p)

f1=(x1,x2,x3)->x1*x2*x3
f2=(x1,x2,x3)->sqrt(x1^2+x2^2+x3^2)^3
f3=(x1,x2,x3)->(x1+x2*im)^3
f4=(x1,x2,x3)->sqrt(x1^2+x2^2+x3^2)^2*(x1+x2+x3)
f5=(x1,x2,x3)->(x3-im*x1)^3
f6=(x1,x2,x3)->x1+x2+x3
