using Calculus
using Cubature
ω=3
k=3.75
m=1.11
ns=1000
l=2pi
ħ=1/2pi
hbar=ħ
rs=linspace(-l,l,ns)
dx=2l/ns
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
function delsq(p3)
	(r1,r2,r3)->(x->p3(x,r2,r3))''(r1)+(x->p3(r1,x,r3))''(r2)+(x->p3(r1,r2,x))''(r3)
end
psid=(x1,x2,x3,d)->1/(pi^(3/4)*d^(3/2))*exp(-(x1^2+x2^2+x3^2)/2d^2)

function Ed(d)
	if typeof(d)<:Array
		d=d[1]
	end
	psi=(x1,x2,x3)->psid(x1,x2,x3,d)
	Hb=(x1,x2,x3)->psi(x1,x2,x3)*(-hbar^2/2m*delsq(psi)(x1,x2,x3)+k*sqrt(x1^2+x2^2+x3^2)*psi(x1,x2,x3))
	integ3d(Hb,5d,5d,5d,50)
end
d=0.20074310546875002
da=(3hbar^2*sqrt(pi)/(4m*k))^(1/3)
avgT=3hbar^2/(4m*d^2)
Es=(hbar^2*k^2/m)^(1/3)
E0a=-(hbar^2*k^2/2m)^(1/3)*(-l)
Edd=1.2665138657753694
psi=(x1,x2,x3)->psid(x1,x2,x3,d)
Hb=(x)->psi(x[1],x[2],x[3])*(-hbar^2/2m*delsq(psi)(x[1],x[2],x[3])+k*sqrt(x[1]^2+x[2]^2+x[3]^2)*psi(x[1],x[2],x[3]))
Ecub=hcubature(Hb,[-10d,-10d,-10d],[10d,10d,10d],reltol=1e-5)[1]
EEs=3*(3/4pi)^(1/3)

psir=(r)->psid(r,0,0,d)

l=2.338
airy0=-2.338107410459764
ns=10000
rs=linspace(-l,l,ns)
dx=2l/ns
air=map(x->airy(0,x),rs)
airpp=map((x->airy(0,x))'',rs)
Ĥ=x->-hbar^2/(2m*x)*(x->airy(0,x))''(x)+k*(x+l)*airy(0,x)

iv=[4950:5050];
E0=-(air[iv]'*hbar^2/2m*(airpp[iv]./(rs[iv].+l)))*dx+(air[iv]'*k*((rs[iv].+l).*(air[iv]./(rs[iv].+l))))*dx
nairy=t->airy(0,t+airy0)
Hb2=x->nairy(x)/x*(-hbar^2/2m*nairy''(x)/x+k*nairy(x))
