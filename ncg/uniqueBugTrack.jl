julia> for tm in m;print(prem==tm);prem=tm;end
falsefalsetruefalsefalsetrue
julia> unique(m)
6-element Array{Equation,1}:
 Equation(Expression({:y}),Expression({0,:+,-1,:x}))
 Equation(0,Expression({0,:+,-1,:x,:+,-1,{:y}}))    
 Equation(0,Expression({0,:+,-1,:x,:+,-1,{:y}}))    
 Equation(Expression({:x}),Expression({0,:+,-1,:y}))
 Equation(0,Expression({0,:+,-1,:y,:+,-1,{:x}}))    
 Equation(0,Expression({0,:+,-1,:y,:+,-1,{:x}}))

function matchesbt(eq::Equation)
	if eq.lhs==0
		return false #it only moves from left to right
	end
	m=Equation[]

	terms=addparse(eq.lhs)
	for term in 1:length(terms)
		teq=deepcopy(eq)
		tt=deepcopy(terms)
		if typeof(teq.rhs)==Expression
			push!(teq.rhs,:+)
			push!(teq.rhs,-1)
			push!(teq.rhs,terms[term])
		else
			teq.rhs=Expression([teq.rhs,:+,-1,terms[term]])
		end
		deleteat!(tt,term)
		teq.lhs=expression(tt)
		push!(m,teq)
		if teq.lhs!=0 #here
			dmt=matchesbt(teq)
			for d in dmt
				push!(m,d)
			end
		end
		tm=matches(teq)
		if tm!=false
			for tteq in matchesbt(teq)
			#	if !(tteq∈m)
					push!(m,tteq)
			#	end
			end
		end
	end

	return m
end
unique(matchesbt(equation(:x+:y))) #variable result


function matchesbt2(terms,rhs)
	m=Any[]
	for term in 1:length(terms)
		rhs=deepcopy(rhs)
		tt=deepcopy(terms)
		if typeof(rhs)==Expression
			push!(rhs,:+)
			push!(rhs,-1)
			push!(rhs,terms[term])
		else
			rhs=Expression([rhs,:+,-1,terms[term]])
		end
		deleteat!(tt,term)
		lhs=expression(tt)
		push!(m,lhs)
		if lhs!=0 #here
			dmt=matchesbt2(addparse(lhs),rhs)
			for d in dmt
				push!(m,d)
			end
		end
		tm=matchesbt2(addparse(lhs),rhs)
		if tm!=false
			for tteq in tm
			#	if !(tteq∈m)
					push!(m,tteq)
			#	end
			end
		end
	end

	return m
end
unique(matchesbt2(Array[Any[:x],Any[:y]],0)) #variable result
