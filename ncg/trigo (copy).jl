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
patterns["Cos"]=ex->sin(simplify(ex.x+pi/2))
patterns["Sin"]=ex->cos(simplify(ex.x-pi/2))
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
function matches_rec(ex::Component,included=false)
	m=Any[]
	if included
		push!(m,ex)
	end
	key=string(typeof(ex))
	if haskey(patterns,key)
		tex1=patterns[key](ex)
		
		push!(m,tex1)
	end
	if typeof(ex.x)<:Component && haskey(patterns,string(typeof(ex.x)))
	#	key=string(typeof(ex.x))
		tm=matches_rec(ex.x,false)
	#	tex=deepcopy(ex)
	#	tex.x=patterns[key](ex.x)
		for tex in tm
			tx=deepcopy(ex)
			tx.x=tex
			push!(m,tx)
		end
	end
	return m
end

expat1=Dict()
expat2=Dict()
expats=Dict[expat1,expat2]
