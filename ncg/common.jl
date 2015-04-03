abstract Component
type Components <: Component
	components
	coef
end

function ==(cs1::Components, cs2::Components)
	nc=length(cs1.components)
	if nc != length(cs2.components)
		return false
	else
		for c in 1:nc
			if length(indsin(cs1.components,cs1.components[c]))!=length(indsin(cs2.components,cs1.components[c]))
				return false
			end
		end
	end
	return true
end

type Expression #<: Component?
	components::Array{Any}
end
X=Union(Number,Symbol,Component)
Ex=Union(Symbol,Component,Expression)

+(ex1::Expression,ex2::Expression)=begin;ex=deepcopy(ex1);push!(ex.components,:+);push!(ex.components,ex2);ex;end
+(ex::Expression,a::X)=begin;ex=deepcopy(ex);push!(ex.components,:+);push!(ex.components,a);ex;end
+(a::X,ex::Expression)=begin;ex=deepcopy(ex);insert!(ex.components,1,:+);insert!(ex.components,1,a);ex;end
#-(ex::Expression,a)=begin;ex=deepcopy(ex);push!(ex.components,:+);push!(ex.components,-1);push!(ex.components,a);ex;end
#-(a,ex::Expression)=begin;ex=deepcopy(ex);insert!(ex.components,1,:+);insert!(ex.components,1,-1);insert!(ex.components,1,a);ex;end
*(ex1::Expression,ex2::Expression)=begin;ex=deepcopy(ex1);push!(ex.components,ex2);ex;end
#*(ex::Expression,a)=begin;ex=deepcopy(ex);push!(ex.components,a);ex;end
#*(a,ex::Expression)=begin;ex=deepcopy(ex);insert!(ex.components,1,a);ex;end
/(ex::Expression,n::Number)=*(1/n,ex)
function *(a::Number,ex::Expression)
	ex=deepcopy(ex)
	insert!(ex.components,1,a)
	ps=findin(ex.components,[:+])
	nps=length(ps)
	if nps==0
		return ex
	else
		for p in ps
			insert!(ex.components,p+1,a)
		end
		return ex
	end
end

*(a::Number,c::Component)=Expression([a,c])
*(c1::Union(Component,Symbol),c2::Union(Component,Symbol))=Expression([c1,c2])
-(c1::Component,c2::Component)=+(c1,-1*c2)
#-(c::Component,a)=+(c,-1*a)
#-(a,c::Component)=+(-1*a,c)
+(c1::Component,c2::Component)=Expression([c1,:+,c2])
+(c::Component,ex::Expression)=Expression([c,:+,ex])
+(ex::Expression,c::Component)=Expression([ex,:+,c])
#+(c::Component,a)=Expression([c,:+,a])
#+(a,c::Component)=Expression([a,:+,c])

+(x1::X,x2::X)=Expression([x1,:+,x2])
-(x1::X,x2::X)=Expression([x1,:+,-1,x2])
*(x1::X,x2::X)=Expression([x1,x2])

abstract Operation <: Component

function indin(array,item)
	ind=0
	for it in array
		ind+=1
		if it==item
			return ind
		end
	end
	return 0
end
function indsin(array,item)
	ind=Int64[]
	for it in 1:length(array)
		if array[it]==item
			push!(ind,it)
		end
	end
	return ind
end
function addparse(ex::Expression)
	adds=findin(ex.components,[:+])
	nadd=length(adds)+1
	parsed=Array(Any,0)
	s=1
	for add in adds
		push!(parsed,ex.components[s:add-1])
		s=add+1
	end
	push!(parsed,ex.components[s:end])
	return parsed
end
function componify(ex::Expression,raw=false)
	lex=length(ex.components)
	stuff=Array(Any,0)	
	for term in 1:lex
		com=ex.components[term]
		if typeof(com)==Expression
			rex=componify(com,true)
			stuff=[stuff,rex]
		else
			stuff=[stuff,com]
		end
	end	
	if raw==true
		return stuff
	else
		return Expression(stuff)
	end		
end
function simplify(ex::Expression)
	ex=deepcopy(ex)
	ex=componify(ex)
#	lex=length(ex.components)
	cs=Array(Components,0)
#	adds=findin(ex.components,[:+])
#	insert!(adds,1,0)
#	push!(adds,lex+1)
	adds=addparse(ex)
	nadds=length(adds)
	for add in 1:nadds
		tcs=Array(Ex,0)
		coef=1
		for term in adds[add]
			if typeof(term)<:Ex
				push!(tcs,term)
			elseif typeof(term)<:Number
				coef*=term
			else			
				warn("Don't know how to handle $term")
			end
		end
		com=Components(tcs,coef)
		ind=indin(cs,com)
		if ind==0
			push!(cs,com)
		else
			cs[ind].coef+=com.coef
		end
	end
	exa=Any[]
	for c in cs
		if c.coef!=0
			if isempty(c.components)
				push!(exa,c.coef)
				push!(exa,:+)
			else
				if length(c.components)==1
					if c.coef!=1
						push!(exa,c.coef)
					end
					push!(exa,c.components[1])
					push!(exa,:+)
				else
					push!(exa,c)
					push!(exa,:+)
				end
			end
		end	
	end
	deleteat!(exa,length(exa))
	if length(exa)==1
		return exa[1]
	else
		return Expression(exa)
	end
end
