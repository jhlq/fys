abstract State
abstract Operator
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
import Base.copy
copy(s::State)=deepcopy(s)
copy(o::Operator)=deepcopy(o)
type Num<:Operator
	num::Number
end
function *(n::Num,s::State)
	ns=deepcopy(s)
	ns.numcoef*=n.num
	return ns
end
*(n::Number,s::State)=Num(n)*s
*(n::Number,o::Operator)=Num(n)*o
abstract Field<:Operator

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
		print_with_color(:red,"Assertion failed, expected $b, got $a\n")
	end
end 
function assert(a::Complex,b::Complex)
	if ke(real(a),real(b)) && ke(imag(a),imag(b))
		return true
	else
		print_with_color(:red,"Assertion failed, expected $b, got $a\n")
	end
end
function assert(a::Complex,b::Number)
	assert(a,complex(b))
end
function assert(s::String,a,b)
	print("Asserting: ",s,' ')
	if assert(a,b)==true
		print_with_color(:green,"Success.\n")
	end
end
