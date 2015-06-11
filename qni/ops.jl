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
m=1.11
ω=3
ns=1000
L=5pi
rs=linspace(-L,L,ns)
dx=2L/ns
psi0=x->(m*ω/(pi*ħ))^(1/4)*exp(-m*ω/(2*ħ)*x^2)
psa0=map(psi0,rs)
psa0c=convert(Array{Complex,1},psa0)
function der{T}(psi::Array{T})
	l=length(psi)
	psip=zeros(T,l)
	for i in 2:l-1
		psip[i]=((psi[i+1]-psi[i])+(psi[i]-psi[i-1]))/2/dx
	end
	return psip
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
		psap[x]=sqrt(m*ω/2ħ)*rs[x]*psa[x]+par*im*phatpsa[x]/sqrt(2*m*ω)
	end
	return psap
end
â´(psa::Array)=â(psa,par=1)
