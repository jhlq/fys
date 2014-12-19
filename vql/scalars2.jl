module S
include("common.jl")
#import Winston
import Gaston.plot
import Cubature.hcubature
import Base.isless,Base.isequal

export StateK,state,wf,plot,braket, braket_fock,braket_cub,Creation,Destruction,N,  Particle,hcubature,bs!,Operator,State,NoState
type Particle
	k
	n::Integer
	p::Integer #1 for particle, -1 for anti particle
end
type StateK<:State
	K::Array{Particle} #[k,n,ap?] 
	numcoef
	extcoef #external coefficient
	bounds
end
#=
function convert(::Type{Momentum},a::Array)
	return Momentum(a)
end
function convert(::Type{Momentum},a::Number)
	return Momentum(a)
end=#
convert(::Type{Particle},a::Array)=Particle(a[1],a[2],a[3])
convert(::Type{StateK},n::Number)=NoState(n)
#=function isless(k1::Momentum,k2::Momentum)
	dim=length(k1.k)
	if dim==1
		return k1.k<k2.k
	else
		for d in 1:length(k1.k)
			if k1.k[d]<k2.k[d]
				return true
			elseif k1.k[d]>k2.k[d]
				return false
			end
		end
	end
	return false
end=#
function isless(p1::Particle,p2::Particle)
	if p1.p>p2.p
		return true
	end
	return p1.k<p2.k
end
#= ==(m1::Momentum,m2::Momentum)=isequal(m1.k,m2.k)
==(m::Momentum,w::WeakRef)=isequal(m.k,w)
==(m::Momentum,k)=isequal(m.k,k)
==(w::WeakRef,m::Momentum)=isequal(w,m.k)
==(k,m::Momentum)=isequal(k,m.k)=#
==(p1::Particle,p2::Particle)=begin;p1.k==p2.k&&p1.n==p2.n&&p1.p==p2.p;end;
function *(o::Operator,sa::Array{StateK})
	lsa=length(sa)
	nsa=Array(State,lsa)
	for si in 1:lsa
		nsa[si]=o*sa[si]
	end
	return nsa
end
function state(range=[-pi,1pi])
	StateK(Any[],1,1,range)
end
function state(a::Array,range=[-pi,1pi])
	if a[1]==-pi
		return StateK(Any[],1,1,range)
	else
		return StateK(Any[a],1,1,range)
	end
end
function state(dim::Integer)
	range=[-pi,1pi]
	for d in 2:dim
		range=hcat(range,[-pi,1pi])
	end
	StateK(Any[],1,1,range)
end	
function wf(s::StateK,x)
	t=0
#	np=0
	for k in s.K
#		np+=k[2]
		t+=k.n*exp(k.p*im*dot(k.k,x))
	end
#	if np==0
#		np=1
#	end
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
function braket_fock(s1::StateK,s2::StateK)
	if sort(s1.K)==sort(s2.K)
		return 1
	else
		return 0
	end
	#sort(s1.K)==sort(s2.K)?1:0
end
function braket(s1::StateK,s2::StateK)
	s1.extcoef*s2.extcoef*braket_fock(s1,s2)
end
function braket(sa1::Array{StateK},sa2::Array{StateK})
	lsa=length(sa1)
	nsa=Array(Number,lsa)
	for i in 1:lsa
		nsa[i]=braket(sa1[i],sa2[i])
	end
	return nsa
end
function braket(sa1::Array{State},sa2::Array{State})
	lsa=length(sa1)
	nsa=Array(Number,lsa)
	for i in 1:lsa
		if typeof(sa1[i])==NoState
			nsa[i]=sa1[i].x
		elseif typeof(sa2[i])==NoState
			nsa[i]=sa2[i].x
		else
			nsa[i]=braket(sa1[i],sa2[i])
		end
	end
	return nsa
end
braket(sa1::Array,sa2::Array)=braket(convert(Array{State},sa1),convert(Array{State},sa2))
function braket_cub(s1::StateK,s2::StateK)
	if length(s1.bounds)==2
		return quadgk(x->conj(wf(s1,x))*wf(s2,x),s1.bounds[1],s1.bounds[2])[1]/vol(s1.bounds)
	else
		return (hcubature(x->real(conj(wf(s1,x))*wf(s2,x)),s1.bounds[1,:],s1.bounds[2,:],abstol=1e-9)[1]+im*hcubature(x->imag(conj(wf(s1,x))*wf(s2,x)),s1.bounds[1,:],s1.bounds[2,:],abstol=1e-9)[1])/vol(s1.bounds)
	end
end
function braket_map(s1::StateK,s2::StateK,res=100)
	#if length(s1.bounds)==2	
	r1=map(x->wf(s1,x),linspace(s1.bounds[1]+(s1.bounds[2]-s1.bounds[1])/res,s1.bounds[2],res))
	r2=map(x->wf(s2,x),linspace(s2.bounds[1]+(s2.bounds[2]-s2.bounds[1])/res,s2.bounds[2],res))
	t=r1'*r2./res
	if length(t)==1
		return t[1]
	else
		return t
	end
end
type Creation <: Operator
	k
	#create
	anti
end
function *(c::Creation,s::StateK)
	ns=deepcopy(s)
	for nk in 1:length(s.K)
		if s.K[nk].k==c.k && s.K[nk].p==c.anti
			ns.K[nk].n+=1
			ns.extcoef*=sqrt(ns.K[nk].n)
			return ns
		end
	end
	push!(ns.K,Particle(c.k,1,c.anti))
	return ns
end
type Destruction <: Operator
	k
	anti
end
function *(a::Destruction,s::State)
	ns=deepcopy(s)
	for nk in 1:length(s.K)
		if s.K[nk].k==a.k && s.K[nk].p==a.anti
			ns.K[nk].n-=1
			ns.extcoef*=sqrt(ns.K[nk].n+1)
			if ns.K[nk].n==0
				deleteat!(ns.K,nk)
			end
			return ns
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
function bs!(s::StateK) #bare state
	s.extcoef=1
end
function bs!(sa::Array{StateK})
	for s in sa
		bs!(s)
	end
end

function t()
	t1();t2();t3();t4();t5
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
	a1=Destruction([1,0,0,0],1)
	s1=ap1*s0
	bs!(s1)
	s3=ap1^3*s0
	bs!(s3)
	N1=N([1,0,0,0],1)
	sa=Array(StateK,0)
	for i in 1:5
		push!(sa,ap1^i*s0)
	end
	ap2=Creation([0,1,0,0],1)
	for i in 1:5
		push!(sa,ap2^i*sa[i])
	end
	bs!(sa)
	sb=Array(StateK,0)
	for i in 1:5
		push!(sb,ap2^i*s0)
	end
	
	for i in 1:10
		assert("braket(s$i,s$i)==1",braket(sa[i],sa[i]),1)
	end
	for i in 1:5
		assert("braket(s$i,N1*s$i)==$i",braket(sa[i],N1*sa[i]),i)
	end
	assert("braket(sb,N1*sb)==0",braket(sb,N1*sb),0)
end
function t6()
	s0=state(4)
	ap1=Creation([1000,0,0,0],1)
	s1=ap1*s0
	ap1p=Creation([1000,1,0,0],1)
	s1p=ap1p*s0
	assert(braket_cub(s1,s1p),0)
	s2p=ap1*ap1p*s0

end

end
