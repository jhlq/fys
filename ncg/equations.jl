include("common.jl")
include("trigo.jl")

type Equation
	lhs::EX
	rhs::EX
end
equation(ex::EX)=Equation(ex,0)
==(eq1::Equation,eq2::Equation)=eq1.lhs==eq2.lhs&&eq1.rhs==eq2.rhs
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
function matches(eq::Equation)
	if eq.lhs==0
		return false #it only moves from left to right
	end
	m=Equation[]
	dm=matches(eq,Div)
	for d in dm
		if !(d∈m)
			push!(m,d)
		end
	end
	terms=addparse(eq.lhs)
	for term in 1:length(terms)
		teq=deepcopy(eq)
		tt=deepcopy(terms)
		if typeof(teq.rhs)==Expression
			push!(teq.rhs,:+)
			push!(teq.rhs,-1)
			for fac in terms[term]
				push!(teq.rhs,fac)
			end
		else
			teq.rhs=Expression([teq.rhs,:+,-1,terms[term]])
		end
		deleteat!(tt,term)
		teq.lhs=expression(tt)
		push!(m,teq)
		if teq.lhs!=0
			dmt=matches(teq,Div)
			for d in dmt
				push!(m,d)
			end
		end
		tm=matches(teq)
		if tm!=false
			for tteq in tm
				if !(tteq∈m)
					push!(m,tteq)
				end
			end
		end
	end
	for teq in m
		teq.rhs=sumnum(componify(teq.rhs))
		teq.lhs=sumnum(componify(teq.lhs))
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
function matches(eqa::Array{Equation})
	neqa=deepcopy(eqa)
	for eq in eqa
		m=matches(eq)
		for teq in m
			push!(neqa,teq)
		end
	end
	return neqa
end
function matches!(eqa::Array{Equation})
	leqa=length(eqa)
	for eq in 1:leqa
		m=matches(eqa[eq])
		for teq in m
			if teq!=false&&indin(eqa,teq)==0
				push!(eqa,teq)
			end
		end
	end
	return eqa
end
function matches(eq::Equation,recursions::Integer)
	m=matches(eq)
	for r in 1:recursions
		matches!(m)
	end
	return m
end
matches(ex::Expression)=matches(equation(ex))
evaluate(eq::Equation,symdic::Dict)=(evaluate(eq.lhs,symdic),evaluate(eq.rhs,symdic))
function solve(eq::Equation)
	seq=simplify(eq)
	mat=matches(seq)
	sol=Equation[]
	for m in mat
		if isa(m.lhs,Symbol)
			push!(sol,m)
		end
	end
	return sol
end
solve(ex::Ex)=solve(equation(ex))
