ħ=1
m=0.111
ω=3
ns=1000
L=5pi
rs=linspace(-L,L,ns)
dx=2L/ns
function der(psi::Array)
	l=length(psi)
	psip=zeros(l)
	for i in 2:l-1
		psip[i]=((psi[i+1]-psi[i])+(psi[i]-psi[i-1]))/2/dx
	end
	return psip
end
function der(psi::Array{Complex{Float64}})
	l=length(psi)
	psip=zeros(Complex,l)
	for i in 2:l-1
		a=
		psip[i]=((psi[i+1]-psi[i])+(psi[i]-psi[i-1]))/2/dx
	end
	return psip
end
	
using Calculus

function p̂(psi::Function)
	println("blergh")
	#x->-im*ħ*derivative(psi)(x)
end
#function psi(x)
#	exp(-im*x)
#end

function crea(psi::Function,m=0.111,ω=3)
	x->sqrt(m*ω/2ħ)*x*psi(x)-im*p̂(psi)(x)/sqrt(2*m*ω)
end
function p̂(psi::Array)
	println("..?")
	-im*ħ.*der(psi)
end
phat(psa)=p̂(psa)
function crea(psi::Array,m=0.111,ω=3)
	l=length(psi)
	psip=zeros(l)
	p̂psi=p̂(psi)
	for x in 1:l
		psip[x]=sqrt(m*ω/2ħ)*rs[x]*psi[x]-im*p̂psi[x]/sqrt(2*m*ω)
	end
	#sf=sum(psip.^2)*dx
	#psip=1/sqrt(sf)*psip
	return psip
end
#using Gadfly
#p=plot([x->real(psi(x)),x->real(crea(psi)(x))],-pi,pi);draw(PNG("cre.png", 9inch, 6inch), p)


psir=x->cos(ω*x)/sqrt(pi)
psi0=x->(m*ω/(pi*ħ))^(1/4)*exp(-m*ω/(2*ħ)*x^2)
psa0=map(psi0,rs)
function kin(psi,x)
	p̂(p̂(psi))(x)/2m
end
function pot(psi,x)
	m*ω^2*x^2*psi(x)/2
end
function expec(op,psi::Function)
	ne=1000
	bra=map(psi,linspace(-pi,pi,ne))'
	ket=map(x->op(psi,x),linspace(-pi,pi,ne))
	bra*ket/ne
end
function psin(psi0,n::Integer)
	p=psi0
	for i in 0:(n-1)
		p=x->crea(p)(x)/sqrt(i+1)
	end
	return p
end
function psan(psa0::Array,n::Integer)
	p=psa0
	for i in 0:(n-1)
		p=crea(p)/sqrt(i+1)
	end
	return p
end
function kin(psa::Array)
	p̂(p̂(psa))./2m
end
function pot(psa::Array,x)
	m*ω^2*x^2.*psa./2
end
function expec(op,psa::Array)
	ne=1000
	bra=map(psi,linspace(-pi,pi,ne))'
	ket=map(x->op(psi,x),linspace(-pi,pi,ne))
	bra*ket/ne
end

#sum(map(x->abs(psi2(x))^2,linspace(0,3pi,1000)))*3pi/1000

heart=(m*ω/(pi*ħ))^(1/4)
