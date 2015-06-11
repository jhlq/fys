ħ=1
m=0.111
ω=3
ns=1000
L=5pi
rs=linspace(-L,L,ns)
dx=2L/ns
psi0=x->(m*ω/(pi*ħ))^(1/4)*exp(-m*ω/(2*ħ)*x^2)
psa0=map(psi0,rs)
function der(psi::Array{Float64})
	println("der")
	l=length(psi)
	psip=zeros(l)
	for i in 2:l-1
		psip[i]=((psi[i+1]-psi[i])+(psi[i]-psi[i-1]))/2/dx
	end
	return psip
end
function der(psi::Array{Complex{Float64}})
	println("der complex")
	l=length(psi)
	psip=zeros(Complex{Float64},l)
	for i in 2:l-1
		a=
		psip[i]=((psi[i+1]-psi[i])+(psi[i]-psi[i-1]))/2/dx
	end
	return psip
end

function phat(psi::Array)
	println("phat array")
	-im*ħ.*der(psi)
end

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

function kin(psa::Array)
	phat(phat(psa))./2m
end
function pot(psa::Array)
	m*ω^2*rs.^2.*psa./2
end
