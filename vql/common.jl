import Base.assert, Base.convert, Base.isless, Base.isequal, Base.copy
export State,Operator,Num,Wavticle,assert,ke

#types
abstract State
abstract Operator
type Num<:Operator
	num::Number
end
abstract Field<:Operator
type NoState<:State
	x
end
abstract Wavticle

#behavior
function *(o1::Operator,o2::Operator)
	oa=Array(Operator,0)
	push!(oa,o1)
	unshift!(oa,o2)
	return oa
end
function *(o1::Operator,oa::Array{Operator,1})
	push!(oa,o1)
end
function *(oa1::Array{Operator,1},oa2::Array{Operator,1})
	vcat(oa1,oa2)
end
function *(oa::Array{Operator,1},o1::Operator)
	unshift!(oa,o1)
end
function *(oa::Array{Operator,1},s::State)
	ns=deepcopy(s)
	for o in oa
		ns=o*ns
	end
	return ns
end
function *(o::Operator,sa::Array{State})
	lsa=length(sa)
	nsa=Array(State,lsa)
	for si in 1:lsa
		nsa[si]=o*sa[si]
	end
	return nsa
end
copy(s::State)=deepcopy(s)
copy(o::Operator)=deepcopy(o)
#=
function *(n::Num,s::State)
	ns=deepcopy(s)
	ns.numcoef*=n.num
	return ns
end
=#
*(n::Number,s::State)=Num(n)*s
*(n::Number,o::Operator)=Num(n)*o
*(o::Operator,n::Number)=n==0?0:Num(n)*o

convert(::Type{State},n::Number)=NoState(n)
#=type Momentum 
	k
end
function convert(::Type{Momentum},a::Array)
	return Momentum(a)
end
function convert(::Type{Momentum},a::Number)
	return Momentum(a)
end
function isless(k1::Momentum,k2::Momentum)
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
end
==(m::Momentum,w::WeakRef)=m.k==w
==(w::WeakRef,m::Momentum)=w==m.k
==(m1::Momentum,m2::Momentum)=begin;m1.k==m2.k;end
==(m::Momentum,k)=begin;m.k==k;end
==(k,m::Momentum)=begin;k==m.k;end
=#
#=
function isless(p1::Wavticle,p2::Wavticle)
	if p1.p>p2.p
		return true
	end
	return p1.k<p2.k
end
=#

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

function ke(a,b,tol=1e-5)
	if a<b+tol && a>b-tol
		return true
	else
		return false
	end
end
function assert(a,b)
	if ke(a,b)
		return true
	else
		print_with_color(:red,"× Assertion failed, expected $b, got $a\n")
	end
end 
function assert(a::Complex,b::Complex)
	if ke(real(a),real(b)) && ke(imag(a),imag(b))
		return true
	else
		print_with_color(:red,"× Assertion failed, expected $b, got $a\n")
	end
end
function assert(a::Complex,b::Number)
	assert(a,complex(b))
end
function assert(a::Array,b::Number)
	s=size(a)[1]
	ba=Array(Bool,s)
	for i in 1:s
		ba[i]=assert(a[i],b)
	end
	return sum(ba)==s?true:false
end
function assert(a::Array,b::Array)
	s=size(a)[1]
	ba=Array(Bool,s)
	for i in 1:s
		ba[i]=assert(a[i],b[i])
	end
	return sum(ba)==s?true:false
end		
function assert(s::String,a,b)
	print(s,' ')
	if assert(a,b)==true
		print_with_color(:green,"ɤ Success!\n")
	end
end
