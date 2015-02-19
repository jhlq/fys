#import Base.isequal
include("common.jl")

type MetricTensor <: Component
	indices
end
gij=MetricTensor([:i,:j])
gji=MetricTensor([:j,:i])

==(g1::MetricTensor,g2::MetricTensor)= ==(g1.indices,g2.indices)
function *(g1::MetricTensor,g2::MetricTensor)
	if g1==g2
		return 2g1
	else
		return Expression([g1,g2])
	end
end

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
