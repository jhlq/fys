#import Base.isequal
include("common.jl")

abstract Component
type Components <: Component
	components
	coef
end
type MetricTensor <: Component
	indices
end
gij=MetricTensor([:i,:j])
gji=MetricTensor([:j,:i])
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
==(g1::MetricTensor,g2::MetricTensor)= ==(g1.indices,g2.indices)
function *(g1::MetricTensor,g2::MetricTensor)
	if g1==g2
		return 2g1
	else
		return Expression([g1,g2])
	end
end

type Expression 
	components::Array{Any}
end
+(ex1::Expression,ex2::Expression)=begin;ex=deepcopy(ex1);push!(ex.components,:+);push!(ex.components,ex2);ex;end
+(ex::Expression,a)=begin;ex=deepcopy(ex);push!(ex.components,:+);push!(ex.components,a);ex;end
+(a,ex::Expression)=begin;ex=deepcopy(ex);insert!(ex.components,1,:+);insert!(ex.components,1,a);ex;end
*(ex1::Expression,ex2::Expression)=begin;ex=deepcopy(ex1);push!(ex.components,ex2);ex;end
*(ex::Expression,a)=begin;ex=deepcopy(ex);push!(ex.components,a);ex;end
*(a,ex::Expression)=begin;ex=deepcopy(ex);insert!(ex.components,1,a);ex;end
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

*(a::Number,t::Component)=Expression([a,t])
-(c1::Component,c2::Component)=+(c1,-1*c2)
-(c::Component,a)=+(c,-1*a)
-(a,c::Component)=+(-1*a,c)
+(c1::Component,c2::Component)=Expression([c1,:+,c2])
+(c::Component,ex::Expression)=Expression([c,:+,ex])
+(ex::Expression,c::Component)=Expression([ex,:+,c])
+(c::Component,a)=Expression([c,:+,a])
+(a,c::Component)=Expression([a,:+,c])

Aij=0.5gij+0.5gji

function componify(ex::Expression,raw=false)
	#ex=deepcopy(ex)
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
	lex=length(ex.components)
	cs=Array(Components,0)
	#ccoefs=Array(Number,0)
	adds=findin(ex.components,[:+])
	insert!(adds,1,0)
	push!(adds,lex+1)
	nadds=length(adds)
	for add in 1:nadds-1
		tcs=Array(Component,0)
		coef=1
		for term in adds[add]+1:adds[add+1]-1
			if typeof(ex.components[term])<:Component
				push!(tcs,ex.components[term])
			elseif typeof(ex.components[term])<:Number
				coef*=ex.components[term]
			end
			#println(coef,tcs)
		end
		com=Components(tcs,coef)
		#println(com)
		ind=indin(cs,com)
		#println(cs)
		if ind==0
			push!(cs,com)
		else
			cs[ind].coef+=com.coef
		end
	end
	exa=Any[]
	for c in cs
		if c.coef!=0
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
	deleteat!(exa,length(exa))
	return Expression(exa)
end

#tests
function t1()
	1/2*(gij+gji)+1/2*(gij-gji) == gij
end
function t1_1()
	ex1=gij*gji
	ex1=3*ex1
	ex2=gij+gji
	ex2=5*ex2
	ex3=ex1+ex2
end
