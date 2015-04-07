#module T

include("common.jl")
import Base.cos, Base.sin, Base./

type Operator <: Component
	op
	arg
end
abstract SingleArg <: Component
==(sa1::SingleArg,sa2::SingleArg)=sa1.x==sa2.x #getfield of names for more general, getfield(a,names(a)[1])
type ÷ <: SingleArg #\div
	x
end
Div=÷
/(x::X,ex::Ex)=Expression([x,Div(ex)])
function /(ex::Expression,x::Ex)
#	nex=deepcopy(ex)
#	push!(nex,Div(x))
#	return nex
	ap=addparse(ex)
	for t in ap
		push!(t,Div(x))
	end
	return expression(ap)
end
type Cos <: SingleArg
	x
end
cos(x::Ex)=Cos(x)
type Sin <: SingleArg
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
function matches_dep(ex::Component)
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
function matches(ex::Component,included=false)
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
		tm=matches(ex.x,false)
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

type Pattern
	lhs::EX
	rhs::EX
end
expats=Pattern[]
p1=Pattern(cos(:x)-sin(:x+pi/2),0)
#push!{T}(a::Array{T,1},n::Nothing)=a
function matches(p::Pattern)
	if p.lhs==0
		return false
	end
	m=Pattern[]
	terms=addparse(p.lhs)
	for term in 1:length(terms)
		tp=deepcopy(p)
		tt=deepcopy(terms)
		if typeof(tp.rhs)==Expression
			push!(tp.rhs,:+)
			push!(tp.rhs,-1)
			push!(tp.rhs,terms[term])
		else
			tp.rhs=Expression([tp.rhs,:+,-1,terms[term]])
		end
#		tp.rhs=simplify(tp.rhs)
		deleteat!(tt,term)
#		if length(tt)==1&&typeof(tt[1])==Array&&length(tt[1])==1
#			tp.lhs=tt[1][1]
#		else
			tp.lhs=expression(tt)
#		end
#		tp.lhs=simplify(tp.lhs)
		push!(m,tp)
		tm=matches(tp)
		if tm!=false
			for ttp in matches(tp)
				push!(m,ttp)
			end
		end
	end
	for tp in m
		tp.rhs=sumnum(componify(tp.rhs))
		tp.lhs=sumnum(componify(tp.lhs))
	end
	return m
end
function ==(p1::Pattern,p2::Pattern)
	m=matches(p2)
	for p in m
		if p1.rhs==p.rhs&&p1.lhs==p.lhs
			return true
		end
	end
	return false
end
function divify(term::Array)
	dis=indsin(term,Div)
	remove=Int64[]
	for i in dis
		m=indin(term,term[i].x)		
		if m>0
			push!(remove,i,m)
		end
	end
	if !isempty(remove)
		ret=deepcopy(term)
		deleteat!(ret,sort!(remove))
		if isempty(ret)
			push!(ret,1)
		end
		return ret
	else
		return term
	end	
end
function simplify(ex::Expression)
	ex=componify(sumnum(ex))
	ap=addparse(ex)
	for term in 1:length(ap)
		ap[term]=divify(ap[term])
	end
	return expression(ap)
end

#end
