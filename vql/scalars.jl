module S #Scalars
export StateK,a,ad,wf,braket,state

function covar(a::Array)
	(a.*[1,-1,-1,-1])
end

abstract State
type StateM<:State
	y::Array
	x::Array
	d::Integer
	np
	nap
end
type StateWF<:State
	f::Function
	fa::Array{Function}
	numcoef
	d::Integer
	bounds
	np
	nap
end
type StateK<:State
	K #[k,n,ap?]
	numcoef
	bounds
end
function wf(s::StateK,x)
	t=0
	for k in s.K
		t+=k[2]*exp(k[3]*k[1]*im*x)
	end
	return t*s.numcoef
end
function *(n::Number,s::StateWF)
	ns=deepcopy(s)
	ns.numcoef*=n
	return ns
end
function state(np::Integer,d::Integer=1,res::Integer=1000)
	if np==0
		return s=State(ones(res),linspace(0,2pi,res),d)
	end
end
function state(f::Function,d::Integer=1,range=(-pi,pi),np=0,nap=0)
	StateWF(f,[f],1,d,range,np,nap)
end
function state(range=(-pi,pi))
	StateK(Any[],1,range)
end
	
function braket(s1::State,s2::State)
	if s1.d!=s2.d
		error("States must have identical dimensions.")
	elseif s1.d==1
		l=length(s1.y)
		a=s1.y'*s2.y
		@assert length(a)==1
		return a[1]/l
	else
		error("Dimension $(s1.d) not supported.")
	end
end
function fg(x,fa)
	t=1
	for fun in fa
		t*=fun(x)
	end
	return t
end
function braket(s1::StateWF,s2::StateWF)
	if s1.d!=s2.d
		error("States must have identical dimensions.")
	end
	if s1.np!=s2.np
		return 0
	end
	tot=0
	#res=length(s1.bounds)
	if s1.d==1
		tf1(xt)=fg(xt,s1.fa)
		tf2(xt)=fg(xt,s2.fa)
		tot+=quadgk(x->conj(s1.numcoef*tf1(x))*s2.numcoef*tf2(x),s1.bounds[1],s1.bounds[2])[1]/(s1.bounds[2]-s1.bounds[1])
	end
	return tot
end	
function braket(s1::StateK,s2::StateK)
	if length(s1.K)!=length(s2.K)
		return 0
	end
	if length(s1.K)==0 || length(s2.K)==0
		if length(s1.K)==0 && length(s2.K)==0
			return 1
		end
		return 0
	end
	if length(s1.K[1])!=length(s2.K[1])
		error("States must have identical dimensions.")
	end	
	quadgk(x->conj(wf(s1,x))*wf(s2,x),s1.bounds[1],s1.bounds[2])[1]/(s1.bounds[2]-s1.bounds[1])/length(s1.K)
end
abstract Operator
function *(o1::Operator,o2::Operator)
	oa=Array(Operator,0)
	push!(oa,o1)
	unshift!(oa,o2)
	return oa
end
function *(o1::Operator,oa::Array{Operator,1})
	push!(oa,o1)
end
function *(oa1::Array{Operator,1},oa2::Array{Operator,1})
	vcat(oa1,oa2)
end
function *(oa::Array{Operator,1},o1::Operator)
	unshift!(oa,o1)
end
function *(oa::Array{Operator,1},s::StateWF)
	ns=deepcopy(s)
	for o in oa
		ns=o*ns
	end
	return ns
end
function *(oa::Array{Operator,1},s::StateK)
	ns=deepcopy(s)	
	for o in oa
		ns=o*ns
	end
	return ns
end

type Creation <: Operator
	k
	#create
	anti
end
function *(c::Creation,s::State)
	np=0
	ns=deepcopy(s)
	if c.anti==true
		np=s.nap+1#c.create
		ns.nap=np
		return sqrt(np)*ns
	else
		np=s.np+1#c.create
		ns.np=np
		return sqrt(np)*ns
	end
end
function *(c::Creation,s::StateK)
	ns=deepcopy(s)
	for nk in 1:length(s.K)
		if s.K[nk][1]==c.k && s.K[nk][3]==c.anti
			ns.K[nk][2]+=1
			return sqrt(ns.K[nk][2])*ns
		end
	end
	push!(ns.K,[c.k,1,c.anti])
	return ns
end
type Destruction <: Operator
	k
	anti
end
function *(a::Destruction,s::State)
	np=0
	ns=deepcopy(s)
	if a.anti==true
		np=s.nap
		ns.nap=np-1
		return sqrt(np)*ns
	else
		np=s.np
		ns.np=np-1
		return sqrt(np)*ns
	end
end
function *(c::Destruction,s::StateK)
	for nk in 1:length(s.K)
		if s.K[nk][1]==c.k && s.K[nk][3]==c.anti
			ns=deepcopy(s)
			ns.K[nk][2]-=1
			if ns.K[nk][2]==0
				deleteat!(ns.K,nk)
				return ns
			end
			return sqrt(ns.K[nk][2]+1)*ns
		end
	end
	return 0
end
function a(k,anti=1)
	Destruction(k,anti)
end
function ad(k,anti=1)
	Creation(k,anti)
end
type Num<:Operator
	num::Number
end
function *(n::Num,s::State)
	ns=deepcopy(s)
	ns.numcoef*=n.num
	return ns
end
*(n::Number,s::State)=Num(n)*s
*(n::Number,o::Operator)=Num(n)*o
abstract Field<:Operator
type Phi<:Field
	f::Function
	o::Operator
end
function *(f::Field,s::State)
	ns=f.o*s
	push!(ns.fa,f.f)
	return ns
end
function t()
	t1();t2();t3()
end
function t1() #covariant test
	a=[1,2,3,4]
	@assert length(a'*covar(a))==1
	print_with_color(:green,"Test 1 succeeded.")
end

function t2() #1D vaccuum state
	res=1000
	s=StateM(ones(res),linspace(0,2pi,res),1,0,0)
	a=braket(s,s)
	println("braket(s,s)==$a") 
	@assert a>0.999

	sf(x)=1
	s=state(sf)
	a=braket(s,s)
	println("braket(s,s)==$a") 
	@assert a>0.999
	print_with_color(:green,"Test 2 succeeded.")
end

function t3() #...
	v=state(x->1)
	ad1=ad(1)#Creation(1,1,false)
	a1=a(1)#Creation(1,-1,false)
	v1=ad1*v
	@assert braket(v1,ad1*a1*v1)==1
	#return (a*v)*(ap*v)
	print_with_color(:green,"Test 3 succeeded.")
end
function t4()
	p=Phi(x->exp(im*x),ad(1))
	v0=state(x->1)
	v1=p*v0
	println(braket(v0,v0))
	println(braket(v1,v1))
	for i in 2:9
		v=p^i*v0
		println(braket(v,v))
	end
end

end
