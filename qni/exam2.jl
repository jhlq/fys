ω=3
om=ω
m=1.11
ns=1000
l=2pi
ħ=1/2pi
hbar=ħ
rs=linspace(-l,l,ns)
dx=2l/ns
psi0=x->(ω/(pi*ħ))^(1/4)*exp(-ω/(2*ħ)*x^2)
psa0=map(psi0,rs)

function der{T}(psa::Array{T})
	l=length(psa)
	psap=zeros(T,l)
	for i in 2:l-1
		psap[i]=((psa[i+1]-psa[i])+(psa[i]-psa[i-1]))/2/dx
	end
	return psap
end
function p̂(psa::Array)
	-im*hbar.*der(psa)
end
phat=p̂
function â{T}(psa::Array{T},par=-1)
	l=length(psa)
	psap=zeros(T,l)
	phatpsa=phat(psa)
	for x in 1:l
		psap[x]=sqrt(m*om/2ħ)*rs[x]*psa[x]-im*phatpsa[x]/sqrt(2*m*ω)
	end
	return psap
end
function psan(psa0::Array,n::Integer)
	p=psa0
	for i in 0:(n-1)
		p=â(p)/sqrt(i+1)
	end
	return p
end
