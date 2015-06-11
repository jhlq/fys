#1
n=1
L=3
function pn(x)
	if x>0 && x<L
		return sqrt(2/L)*sin(n*pi*x/L)
	else
		return 0
	end
end
p=quadgk(x->pn(x)^2,0,L/2)

#2

#8
ω=3
om=ω
ħ=1/2pi
hbar=ħ
m=1.11
function der{T}(psa::Array{T})
	l=length(psa)
	psap=zeros(T,l)
	for i in 2:l-1
		psap[i]=((psa[i+1]-psa[i])+(psa[i]-psa[i-1]))/2/dx
	end
	return psap
end
function p̂(psa::Array)
	-im*ħ.*der(psa)
end
phat=p̂
function â{T}(psa::Array{T},par=-1)
	l=length(psa)
	psap=zeros(T,l)
	phatpsa=phat(psa)
	for x in 1:l
		psap[x]=sqrt(m*ω/2ħ)*rs[x]*psa[x]-im*phatpsa[x]/sqrt(2*m*ω)
	end
	return psap
end
Eps=4.56
q=-7.21
ns=1000
L=5pi
rs=linspace(-L,L,ns)
dx=2L/ns
psi0=x->(m*ω/(pi*ħ))^(1/4)*exp(-m*ω/(2*ħ)*x^2)
psa0=map(psi0,rs)
psa1=â(psa0)
Ĥ = psa->-hbar^2/2m*der(der(psa))+m*om^2/2*(rs.^2.*psa)-q*Eps*(rs.*psa)

#9
delta=zeros(ns)
delta[ns/2]=1
L=0.01pi
rs=linspace(-L,L,ns)
dx=2L/ns

Ĥ2=(psa,al)->-hbar^2*der(der(psa))-al.*delta.*psa
p0al3=map(x->sqrt(m*3)/hbar*exp(-m*3*abs(x)/hbar^2),rs)
p0al6=map(x->sqrt(m*6)/hbar*exp(-m*6*abs(x)/hbar^2),rs)
p1al3=â(p0al3)
p1al3=p1al3/sqrt(sum(p1al3.^2)*dx)
p1al6=â(p0al6)
p1al6=p1al6/sqrt(sum(p1al6.^2)*dx)

#12
function crea(psi::Array,m=0.111,ω=3)
	l=length(psi)
	psip=zeros(l)
	phatpsi=phat(psi)
	for x in 1:l
		psip[x]=sqrt(m*ω/2ħ)*rs[x]*psi[x]-im*phatpsi[x]/sqrt(2*m*ω)
	end
	return psip
end
function psan(psa0::Array,n::Integer)
	p=psa0
	for i in 0:(n-1)
		p=crea(p)/sqrt(i+1)
	end
	return p
end
