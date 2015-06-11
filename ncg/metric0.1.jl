abstract Component
abstract MetricTensor <: Component
abstract MetricTensorInv <: Component
gij=MetricTensor
gji=MetricTensorInv
abstract Aij <: Component
abstract Bij <: Component
+(Aij,Bij)=MetricTensor

type Expression 
	components
end
*(a::Number,t::Type)=Expression([a,t])
+(ex::Expression,a)=begin;push!(ex.components,:+);push!(ex.components,a);ex;end
-(t::Type,a)=+(t,-1*a)

function +(t1::Type,t2::Type) 
	if t1==gij && t2==gji
		return 2*Aij
#-(MetricTensor,MetricTensorInv)=2*Bij
#+(t1::Type,t2::Type)=Expression([t1,t2])



#alternative representation:
#type MetricTensor
#	indices
#end
#gij=MetricTensor((:i,:j))
#gji=MetricTensor((:j,:i))

