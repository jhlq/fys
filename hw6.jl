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
psi03d=(x1,x2,x3)->psi0(x1)+psi0(x2)+psi0(x3)
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
	(r1,r2,r3)->-delsq(p3)(r1,r2,r3)+(r1^2+r2^2+r3^2)*p3(r1,r2,r3)
end
function T(p3)
	(r1,r2,r3)->-delsq(p3)(r1,r2,r3)
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

om=3
m=1.11
d=sqrt(hbarn/(m*om))
p3dgs=1/(pi^(3/4)*d^(3/2)*exp(-(x1^2+x2^2+x3^2)/2d^2)

function integ3d(f,l1,l2,l3,ns=1000)
	rs1=linspace(-l1,l1,ns)
	dx1=2l1/ns
	rs2=linspace(-l2,l2,ns)
	dx2=2l2/ns
	rs3=linspace(-l3,l3,ns)
	dx3=2l3/ns
	tot=0
	for x1 in rs1
		for x2 in rs2
			for x3 in rs3
				tot+=f(x1,x2,x3)
			end
			tot*=dx1
		end
		tot*=dx2
	end
	tot*=dx3
	return tot
end
