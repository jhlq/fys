g=9.8
M=1.6749e-27
Mn=1.6749
hbar=1.0546e-34
hbarn=1.0546
k=1.3806e-23
x=-0.1
using Calculus
#p=plot([x->airy(0,x),x->airy(1,x),x->airy(0,x)',x->airy(0,x)'',x->airy(2,x)],-3,2);draw(PNG("a.png", 9inch, 6inch), p)

l=2.338
ns=10000
rs=linspace(-l,l,ns)
dx=2l/ns
air=map(x->airy(0,x),rs)
airpp=map((x->airy(0,x))'',rs)
Ĥ=x->-hbar^2/2M*(x->airy(0,x))''(x)+M*g*(x+l)*airy(0,x)

E0=-(air'*hbar^2/2M*airpp)*dx+(air'*M*g*((rs.+l).*air))*dx



ω=3
ns=1000
l=2pi
ħ=1/2pi
rs=linspace(-l,l,ns)
dx=2l/ns
psi0=x->(ω/(pi*ħ))^(1/4)*exp(-ω/(2*ħ)*x^2)
psa0=map(psi0,rs)
psi03d=(x1,x2,x3)->psi0(x1)*psi0(x2)*psi0(x3)

om1=1
om2=1
om3=2
m=1.11
#d=sqrt(hbarn/(m*om))
p3dgs=(x1,x2,x3)->sqrt(2)/(pi^(3/4)*d^(3/2))*exp(-(x1^2+x2^2+4*x3^2)/2d^2)
p01=x->(m*om1/(pi*hbarn))^(1/4)*exp(-m*om1/(2*hbarn)*x^2)
p11=x->real(â(p01,om1)(x))
p02=x->(m*om2/(pi*hbarn))^(1/4)*exp(-m*om2/(2*hbarn)*x^2)
p12=x->real(â(p02,om2)(x))
p03=x->(m*om3/(pi*hbarn))^(1/4)*exp(-m*om3/(2*hbarn)*x^2)
p13=x->real(â(p03,om3)(x))
p3du=(x1,x2,x3)->p01(x1)*p02(x2)*p03(x3)
p3du1a=(x1,x2,x3)->p11(x1)*p02(x2)*p03(x3)
p3du1b=(x1,x2,x3)->p01(x1)*p02(x2)*p13(x3)
p3du2a=(x1,x2,x3)->p11(x1)*p02(x2)*p13(x3)
p3du2b=(x1,x2,x3)->p11(x1)*p12(x2)*p03(x3)


function delsq(p3)
	(r1,r2,r3)->(x->p3(x,r2,r3))''(r1)+(x->p3(r1,x,r3))''(r2)+(x->p3(r1,r2,x))''(r3)
end
function delv(p3,r1,r2,r3)
	if length(p3(r1,r2,r3))==1
		return [(x->p3(x,r2,r3))'(r1),(x->p3(r1,x,r3))'(r2),(x->p3(r1,r2,x))'(r3)]
	else
		return [(x->p3(x,r2,r3))'(r1)[1],(x->p3(r1,x,r3))'(r2)[2],(x->p3(r1,r2,x))'(r3)[3]]
	end
end
function ham(p3)
	(r1,r2,r3)->-hbarn^2/2m*delsq(p3)(r1,r2,r3)+m/2*(om1^2*r1^2+om2^2*r2^2+om3^2*r3^2)*p3(r1,r2,r3)
end
function T(p3)
	(r1,r2,r3)->-hbarn^2/2m*delsq(p3)(r1,r2,r3)
end
function V(p3)
	(r1,r2,r3)->(r1^2+r2^2+r3^2)*p3(r1,r2,r3)
end
function phat(p3,r1,r2,r3)
	-im*ħ.*[derivative(x->p3(x,r2,r3))(r1),derivative(x->p3(r1,x,r3))(r2),derivative(x->p3(r1,r2,x))(r3)]
end
function L(p3)
	(r1,r2,r3)->-im*ħ.*cross([r1,r2,r3],delv(p3,r1,r2,r3))
end
function rdotp(p3)
	(r1,r2,r3)->-im*ħ*dot([r1,r2,r3],delv(p3,r1,r2,r3))
end

#quadgk(y->(quadgk(x->psi03d(x,y,c3)^2,-l,l)[1]),-l,l)
#quadgk(z->(quadgk(y->(quadgk(x->psi03d(x,y,z)^2,-l,l)[1]),-l,l)[1]),-l,l)

function integ3d(f,l1,l2,l3,ns=100)
	rs1=linspace(-l1,l1,ns)
	dx1=2l1/ns
	rs2=linspace(-l2,l2,ns)
	dx2=2l2/ns
	rs3=linspace(-l3,l3,ns)
	dx3=2l3/ns
	tot=Array(Float64,ns,ns,ns)
	t1=Array(Float64,ns)
	for x1 in 1:ns
		print("$x1,")
		for x2 in 1:ns
			for x3 in 1:ns
				tot[x1,x2,x3]=f(rs1[x1],rs2[x2],rs3[x3])
			end
		end
	end
	println("\nSumming")
	t1=Array(Float64,ns,ns)
	for x1 in 1:ns
		for x2 in 1:ns
			t1[x1,x2]=sum(tot[x1,x2,:])*dx3
		end
	end
	t2=Array(Float64,ns)
	for x1 in 1:ns
		t2[x1]=sum(t1[x1,:])*dx2
	end
	return sum(t2)*dx1
end



function der{T}(psa::Array{T})
	l=length(psi)
	psip=zeros(T,l)
	for i in 2:l-1
		psip[i]=((psi[i+1]-psi[i])+(psi[i]-psi[i-1]))/2/dx
	end
	return psip
end
function p̂(psa::Array)
	-im*hbarn.*der(psa)
end
function p̂(psi::Function)
	x->-im*hbarn*psi'(x)
end

function â{T}(psa::Array{T},omega=1,par=-1)
	l=length(psa)
	psap=zeros(T,l)
	phatpsa=phat(psa)
	for x in 1:l
		psap[x]=sqrt(m*omega/2ħ)*rs[x]*psa[x]-im*phatpsa[x]/sqrt(2*m*ω)
	end
	return psap
end
function â(psi::Function,omega=1,par=-1)
	x->sqrt(m*omega/2hbarn)*x*psi(x)-im*p̂(psi)(x)/sqrt(2*m*omega)
end
