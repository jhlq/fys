abstract Component
type MetricTensor <: Component
	indices
end
gij=MetricTensor((:i,:j))
gji=MetricTensor((:j,:i))
function *(g1::MetricTensor,g2::MetricTensor)
	if g1.indices==g2.indices
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
