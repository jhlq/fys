#1
L=3
n=1
pn=x->sqrt(2/L)*sin(n*pi*x/L)
pr=quadgk(x->pn(x)^2,0,L/2)

#9
al=3
m=1.11
hbar=1/2pi
pal=x->sqrt(m*al)/hbar*exp(-m*al*abs(x)/hbar^2)
pal3=x->sqrt(m*3)/hbar*exp(-m*3*abs(x)/hbar^2)
pal6=x->sqrt(m*6)/hbar*exp(-m*6*abs(x)/hbar^2)
Ĥ=p->

p=(x,t)->cos(1/hbar*x)*exp(im/hbar*(-t/2m))
p=(x,t)->cos(1/hbar*(x+t/2m))
p=(x,t)->exp(im/hbar*(x))

using Calculus
-hbar^2/2m*((x->p(x,0.12))''(0.45))-im*hbar*((t->p(0.45,t))'(0.12))
