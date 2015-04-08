include("common.jl")
include("trigo.jl")

type Equation
	lhs::EX
	rhs::EX
end
equation(ex::EX)=Equation(ex,0)
==(eq1::Equation,eq2::Equation)=eq1.lhs==eq2.lhs&&eq1.lhs==eq2.lhs
function equivalent(eq1::Equation,eq2::Equation)
	m=matches(eq2)
	for eq in m
		if eq1==eq
			return true
		end
	end
	return false
end
simplify(eq::Equation)=Equation(simplify(eq.lhs),simplify(eq.rhs))
function simplify(eqa::Array{Equation})
	neqa=Equation[]
	for eq in eqa
		push!(neqa,simplify(eq))
	end
	return neqa
end
relations=Equation[]
eq1=Equation(cos(:x)-sin(:x+pi/2),0)
function matches(p::Equation)
	if p.lhs==0
		return false #it only moves from left to right
	end
	m=Equation[]
	terms=addparse(p.lhs)
	for term in 1:length(terms)
		tp=deepcopy(p)
		tt=deepcopy(terms)
		if typeof(tp.rhs)==Expression
			push!(tp.rhs,:+)
			push!(tp.rhs,-1)
			push!(tp.rhs,terms[term])
		else
			tp.rhs=Expression([tp.rhs,:+,-1,terms[term]])
		end
		deleteat!(tt,term)
		tp.lhs=expression(tt)
		push!(m,tp)
		tm=matches(tp)
		if tm!=false
			for ttp in matches(tp)
				push!(m,ttp)
			end
		end
	end
	for tp in m
		tp.rhs=sumnum(componify(tp.rhs))
		tp.lhs=sumnum(componify(tp.lhs))
	end
	return m
end
function matches(eq::Equation,op)
	if op==Div
		lhs=addparse(eq.lhs)
		rhs=addparse(eq.rhs)
		m=Equation[]
		for term in lhs
			for fac in term
				nl=deepcopy(lhs)
				nr=deepcopy(rhs)
				for t in nl
					push!(t,Div(deepcopy(fac)))
				end
				for t in nr
					push!(t,Div(deepcopy(fac)))
				end
				push!(m,Equation(expression(nl),expression(nr)))
			end
		end
		return simplify(m)
	end
end

