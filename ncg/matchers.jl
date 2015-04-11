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
	matches=Equation[]
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
								xsq=simplify(Expression(p[1:l])^2).components
								if 2*l<=length(terms[matchi])
									for tp in permutations(terms[matchi])
										for ttp in permutations(xsq)
											if tp[1:2l]==ttp
												push!(connections,"Quadratic match! $(terms[matchi]) contains $(p[1:l])^2")
												for termi in 1:length(terms)
													if termi∈[ti,matchi]
														continue
													elseif has(terms[termi],p[1:l])
														break
													end
													a=Any[]
													for tl in 2l+1:length(tp)
														push!(a,tp[tl])
													end
													b=Any[]
													for tl in l+1:length(p)
														push!(b,p[tl])
													end
													x=p[1:l]
													c=deleteat!(deepcopy(terms),sort([ti,matchi]))
													push!(connections,"$terms is of the form ax^2+bx+c with a=$a, x^2=$xsq, b=$b, x=$x, c=$c")
													eq1=simplify(Equation(Expression(x),(-Expression(b)/(2Expression(a))+Sqrt(Expression(b)^2/(4*Expression(a)^2)-Expression(c)/Expression(a)))))
													if !in(eq1,matches)
														push!(matches,eq1)
													end
													eq2=simplify(Equation(Expression(x),(-Expression(b)-Sqrt(Expression(b)^2-4*Expression(a)*Expression(c)))/2Expression(a)))
													if !in(eq2,matches)
														push!(matches,eq2)
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
		end
	end
#	println(unique(connections))
	return matches
end
