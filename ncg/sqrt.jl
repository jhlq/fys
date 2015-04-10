import Base.sqrt
type Sqrt <: SingleArg #using \sqrt causes problems
	x
end
#Sqrt=√
sqrt(a)=Sqrt(a)

function simplify!(sq::Sqrt)
	if isa(sq.x,Number)
		return sqrt(sq.x)
	elseif isa(sq.x,Expression)
		sq.x=simplify(sq.x)
		ap=addparse(sq.x)
		if length(ap)==1
			facs=ap[1]
			nfacs=length(facs)
			if iseven(nfacs)
				for p in permutations(facs)
					if p[1:nfacs/2]==p[nfacs/2+1:nfacs]
						return simplify(Expression(p[1:nfacs/2]))
					end
				end
			end
		end
	end
	return sq
end
simplify(sq::Sqrt)=simplify!(deepcopy(sq))
