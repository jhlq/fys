import Base./
#include("common.jl")

abstract SingleArg <: Component
==(sa1::SingleArg,sa2::SingleArg)=sa1.x==sa2.x #getfield of names for more general, getfield(a,names(a)[1])
type ÷ <: SingleArg #\div
	x
end
Div=÷
/(x::X,ex::Ex)=Expression([x,Div(ex)])
function /(ex::Expression,x::Ex)
	ap=addparse(ex)
	for t in ap
		push!(t,Div(x))
	end
	return expression(ap)
end

function divify(term::Array)
	dis=indsin(term,Div)
	remove=Int64[]
	for i in dis
		m=indin(term,term[i].x)		
		if m>0
			push!(remove,i,m)
		end
	end
	if !isempty(remove)
		ret=deepcopy(term)
		deleteat!(ret,sort!(remove))
		if isempty(ret)
			push!(ret,1)
		end
		return ret
	else
		return term
	end	
end
divify(x::X)=x
