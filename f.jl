h=6.62606957e-34
hbar=h/2pi
hbar=1

m=0.104
al=1.72

E=-m*al^2/(2*hbar^2)

C=-(al*m/hbar^2)
psi=x->al*sqrt(m*al)/hbar*exp(C*abs(x))
psik=k->al*psi(0)/(hbar^2*k^2/2m-E)

using Calculus
#o=integrate(k->1/(hbar^2*k^2/2m+abs(E)),-pi,pi)*al/2pi

xt=0.45
psit=integrate(k->real(psik(k)*exp(-im*k*xt)),-50pi,50pi)/2pi
