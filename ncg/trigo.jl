include("common.jl")
import Base.cos, Base.sin

type Operator <: Component
	op
	arg
end
type Cos <: Component
	x
end
cos(x::Ex)=Cos(x)
type Sin <: Component
	x
end
sin(x::Ex)=Sin(x)


#layered patterns, layer 1: Cos(:x) -> layer 2: :x==:y+pi/2
#linked patterns, [Cos,:x+pi/2], has to be able to rewrite expressions 
#make type Add, E
#division?

patterns=Dict()
patterns["Cos"]=ex->sin(ex.x+pi/2)
patterns["Sin"]=ex->cos(ex.x-pi/2)
macro maketype(key,x)
	println(key)
	return parse("$key($x)")
end
function matches(ex::Component)
	m=Any[ex]
	key=string(typeof(ex))
	if haskey(patterns,key)
		push!(m,patterns[key](ex))
	end
	if typeof(ex.x)<:Component && haskey(patterns,string(typeof(ex.x)))
		key=string(typeof(ex.x))
		tex=deepcopy(ex)
		tex.x=patterns[key](ex.x)
		push!(m,tex)
	end
	return m
end
