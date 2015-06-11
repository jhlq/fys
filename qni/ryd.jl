R=10973731.568539 #1/m

ħ=1/2pi
hbar=ħ
m=1.11
aV0=1230
ns=1000
L=pi
rs=linspace(-L,L,ns)
dx=2L/ns
function psid(d)
	map(x->1/(pi^(1/4)*sqrt(d))*e^(-x^2/2d^2),rs)
end
function der{T}(psi::Array{T})
	l=length(psi)
	psip=zeros(T,l)
	for i in 2:l-1
		psip[i]=((psi[i+1]-psi[i])+(psi[i]-psi[i-1]))/2/dx
	end
	return psip
end#result
function f(d)
	p=psid(d)
	(-p[10:990]'*ħ/2m*der(der(p))[10:990])[1]*dx-aV0*p[500]^2
end
#indmin(real(map(f,[0.01:0.0001:0.1])))
E0=-aV0^2*m/2hbar^2
delta=zeros(ns);delta[ns/2]=1
function Ĥ(p)
	-ħ/2m*der(der(p))-aV0.*delta.*p
end

