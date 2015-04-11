function quadratic(eq::Equation)
	eq=simplify(eq)
	if (eq.rhs!=0&&eq.lhs!=0)||(eq.rhs==0&&eq.lhs==0)
		return false
	elseif eq.rhs==0
		terms=addparse(eq.lhs)
	else
		terms=addparse(eq.rhs)
	end
	connections=Any[]
	for ti in 1:length(terms)
		for p in permutations(terms[ti])
			for l in 1:length(terms[ti])
				for matchi in [[1:ti-1], [ti+1:length(terms)]]
					if l>length(terms[matchi])
						continue
					else
						for mp in permutations(terms[matchi])
							if p[1:l]==mp[1:l]
#								push!(connections,(ti,p,l,matchi,terms[matchi]))
								xsq=simplify(Expression(p[1:l])^2)
								if 2*l<=length(terms[matchi])
									for tp in permutations(terms[matchi])
										for ttp in permutations(xsq.components)
											if tp[1:2l]==ttp
												push!(connections,"Quadratic match! $(terms[matchi]) contains $(p[1:l])^2")
											end
										end
									end 
								end
							end
						end
					end
				end
			end
		end
	end
	return unique(connections)
end
