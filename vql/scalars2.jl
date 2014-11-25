module S
include("common.jl")
#import Winston
import Gaston.plot
import Cubature.hcubature
import Base.convert

export StateK,state,wf,plot,braket,Creation,Destruction,N,Momentum,hcubature

type StateK<:State
	K #[k,n,ap?]
	numcoef
	bounds
end
type Momentum 
	k
end
function convert(::Type{Momentum},a::Array)
	return Momentum(a)
end
function state(range=[-pi,1pi])
	StateK(Any[],1,range)
end
function state(a::Array,range=[-pi,1pi])
	if a[1]==-pi
		return StateK(Any[],1,range)
	else
		return StateK(Any[a],1,range)
	end
end
function state(dim::Integer)
	range=[-pi,1pi]
	for d in 2:dim
		range=hcat(range,[-pi,1pi])
	end
	StateK(Any[],1,range)
end	
function wf(s::StateK,x)
	t=0
	np=0
	for k in s.K
		np+=k[2]
		t+=k[2]*exp(k[3]*im*dot(k[1].k,x))
	end
	if np==0
		np=1
	end
	return t*s.numcoef
end
function wfm(s::StateK,x)
	t=1
	for k in s.K
		t*=exp(k[2]*k[3]*k[1]*im*x)
	end
	return t*s.numcoef
end
function plot(s::StateK)
	#Winston.plot(x->wf(s,x),s.bounds[1],s.bounds[2])
	r=map(x->wf(s,x),linspace(s.bounds[1],s.bounds[2],100))
	plot([real(r) imag(r)])
end
function plot(st::(StateK...))
	a=zeros(100)
	for s in st
		r=map(x->wf(s,x),linspace(s.bounds[1],s.bounds[2],100))
		a=hcat(a,[real(r) imag(r)])
	end
	plot(a)
end
function vol(bounds)
	l=length(bounds)
	d=l/2
	v=0
	if d==1
		return bounds[2]-bounds[1]
	elseif d==4
		(t,x,y,z)=(bounds[2,1]-bounds[1,1],bounds[2,2]-bounds[1,2],bounds[2,3]-bounds[1,3],bounds[2,4]-bounds[1,4])
		return t*x*y*z
	end	
end		
	
function braket(s1::StateK,s2::StateK,res=100)
	if length(s1.bounds)==2
		r1=map(x->wf(s1,x),linspace(s1.bounds[1]+(s1.bounds[2]-s1.bounds[1])/res,s1.bounds[2],res))
		r2=map(x->wf(s2,x),linspace(s2.bounds[1]+(s2.bounds[2]-s2.bounds[1])/res,s2.bounds[2],res))
		t=r1'*r2./res
		if length(t)==1
			return t[1]
		else
			return t
		end  
	elseif false
		return quadgk(x->conj(wf(s1,x))*wf(s2,x),s1.bounds[1],s1.bounds[2])[1]/vol(s1.bounds)
	else
		return (hcubature(x->real(conj(wf(s1,x))*wf(s2,x)),s1.bounds[1,:],s1.bounds[2,:],abstol=1e-9)[1]+im*hcubature(x->imag(conj(wf(s1,x))*wf(s2,x)),s1.bounds[1,:],s1.bounds[2,:],abstol=1e-9)[1])/vol(s1.bounds)
	end
end
type Creation <: Operator
	k::Momentum
	#create
	anti
end
function *(c::Creation,s::StateK)
	ns=deepcopy(s)
	for nk in 1:length(s.K)
		if s.K[nk][1]==c.k && s.K[nk][3]==c.anti
			ns.K[nk][2]+=1
			return (1/sqrt(ns.K[nk][2]))*ns
		end
	end
	push!(ns.K,[c.k,1,c.anti])
	return ns
end
type Destruction <: Operator
	k::Momentum
	anti
end
function *(a::Destruction,s::State)
	ns=deepcopy(s)
	for nk in 1:length(s.K)
		if s.K[nk][1]==a.k && s.K[nk][3]==a.anti
			ns.K[nk][2]-=1
			return (1/sqrt(ns.K[nk][2]+1))*ns
		end
	end
	return 0
end
function /(s1::StateK,s2::StateK)
	if s1.K!=s2.K
		return NaN
	end
	return s1.numcoef/s2.numcoef
end
function /(s::StateK,n::Number)
	ns=copy(s)
	ns.numcoef/=n
	return ns
end
type N<:Operator
	k
	anti
end
function *(Nk::N,s::State)
	Creation(Nk.k,Nk.anti)*Destruction(Nk.k,Nk.anti)*s
end
function Ntot(s::State)
	n=0
	for k in s.K
		n+=k[2]*k[3]
	end
	return n
end

function t()
	t1();t2();t3();t4()
end
function t1()
	s0=state()
	ap=Creation(1,1)
	s1=ap*s0
	s2=ap*s1
	assert(braket(s0,s0),1)
	assert(braket(s0,s1),0)
	assert(braket(s1,s1),1)
	assert(braket(s2,s1),0)
	assert(braket(s2,s2),1)
end
function t2()
	s0=state()
	ap1=Creation(1,1)
	ap2=Creation(2,1)
	s1=ap1*s0
	s2=ap2*s0
	assert(braket(s2,s1),0)
	assert(braket(s2,s2),1)
end
function t3()
	s0=state()
	ap1=Creation(1,1)
	ap2=Creation(2,1)
	ap3=Creation(3,1)
	s1=ap1*s0
	s2=ap2*s1
	s3=ap3*s0
	assert(braket(s2,s1),0)
	assert(braket(s2,s2),1)
	assert(braket(s3,s1),0)
	assert(braket(s3,s2),0)
	assert(braket(s3,s3),1)
end
function t4()
	s0=state()
	ap1=Creation(1,1)
	a1=Destruction(1,1)
	sa=Array(StateK,0)
	push!(sa,ap1*s0)
	for i in 2:5
		push!(sa,ap1^i*s0)
	end
	s5=ap1^5*s0
	N1=N(1,1)

	assert("Vaccuum destruction. ",a1*s0,0)
	for i in 1:5
		assert(sa[i]/(ap1*a1*sa[i]),i)
	end
	for i in 1:5
		assert("<$i|$i>",braket(sa[i],sa[i]),1)
	end
end
function t5()
	s0=state(4)
	ap1=Creation([1,0,0,0],1)
	s1=ap1*s0
	assert(braket(s1,s1),1)
end

end
