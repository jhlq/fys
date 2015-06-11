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
type ZeroForm <: Form
	fun
end
type Differential <: Form
	var::Symbol
end
==(d1::Differential,d2::Differential)= ==(d1.var,d2.var)
type PForm <: Form #rename to WedgeProduct? Make new type WedgeProduct! With non modifying wedges so that p need not be a function.
	forms
	p
	PForm(f)=(pf=new(f); pf.p=()->length(pf.forms); pf)
end
function ==(pf1::PForm,pf2::PForm)
	if pf1.p()!=pf2.p()
		return false
	else
		for fn in 1:pf1.p()
			if pf1.forms[fn]!=pf2.forms[fn]
				return false
			end
		end
	end
	return true
end
abstract PFormSum
function d(x::Symbol)
	Differential(x)
end
function d(x::Symbol,dim::Integer)
	ds=Array(Differential,dim)
	for di in 1:dim
		ds[di]=d(symbol(string(x)*string(di)))
	end
	return ds
end
function ∧(f1::Differential,f2::Differential)
	PForm([f1,f2])
end
function ∧(pf::PForm,f::Differential)
	push!(pf.forms,f)
	pf
end
function ∧(f::Differential,pf::PForm)
	insert!(pf.forms,1,f)
	pf
end
wedge=∧
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
function equal_forms_cancel_rule_checker(form::PForm)
	for f in form.forms
		if length(indsin(form.forms,f))>1
			return true
		end
	end
	return false
end
equal_forms_cancel = Rule([PForm,equal_forms_cancel_rule_checker],(form)->0)
function alternating_multilinear_rc(form::PFormSum)
	
end
rules=[greens,equal_forms_cancel]
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
function t2()
	dx=d(:x)
	dy=d(:y)
	wp=dx∧dy
	wp2=wedge(dx,dy)
	@assert wp==wp2
	wp3=dx∧dx
	checkrules(wp3)
end
function t3()
	ex=wp1+wp2
	simplify(ex)
end
function t4()
	basis=d(:x,81)
	wp=basis[1]∧basis[2]
	for b in 3:length(basis)
		wp∧basis[b]
	end
	@assert checkrules(wp)==wp
	wp∧basis[1]
	@assert checkrules(wp)==0	
end
