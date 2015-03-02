include("common.jl")
abstract AbstractFunction
type Fun <: AbstractFunction
	variables
	#f
end
abstract Form
type OneForm
	fun::Fun
	funcs #F G 
	closed::Bool #partial(F,:y)==partial(G,:x)
end
#df=partial(f,:x)*dx+partial(f,:y)*dy
type Derivative
	ex
	var
	partial::Bool
end

#f(:x,:y,:z), :x(:t)
f=Fun([Fun(:t),Fun(:t),Fun(:t)])
#integrate(exp,vars)->integrate(exp,var)
type Plane# <: AbstractFunction
	vars
end
type Curve 
	in
	closed #1 = yes, 0 = undefined, -1 = no
end
type Surface
	boundary #oriented curve
end
intsym="∫"
type ∫
	boundary
	ex
	var
end
type ∫∫
	boundary
	ex
	vars
end
type Rule
	req
	res
end
greens = Rule([∫∫,int->(typeof(int.boundary)==Surface && int.boundary.boundary.closed==1 && typeof(int.ex)==Derivative && int.ex.partial==true && typeof(int.ex.ex)==Curve)],int->∫(int.boundary.boundary,int.ex.ex,int.vars[2]))

#,Derivative,der->(der.partial==true && typeof(der.ex)==Curve))],int->∫(int.boundary.boundary,int.ex
rules=[greens]
function checkrules(ex)
	for rule in rules
		if typeof(ex)==rule.req[1]
			if rule.req[2](ex)
				return rule.res(ex)
			end
		end
	end
	return ex
end

function t1()
	p=Plane([:x,:y])
	boundary=Curve(p,1) #1 = closed
	s=Surface(boundary)
	c=Curve(s,0) #0 = either
	green=∫∫(s,Derivative(c,:x,true),[:x,:y])
	checkrules(green)
end
