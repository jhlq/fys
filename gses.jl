function kindaequals(x,y,d=1.01)
	if x*d>y && x/d<y
		return true
	else
		return false
	end
end

U0=3
a=1
ga=1
C=1
A=1
m=0.1
hbar=1
tanx=k->tan(a*k/2)
si=sqrt(m*U0*a^2/2hbar^2)
#tan(x)=sqrt((si/x)^2-1)
frh=k->sqrt(complex((si/(a*k/2))^2-1))
k=[0:0.001:0.75]
lh=map(tanx,k)
rh=map(frh,k)
intersect=0
for ki in 1:length(k)
	if kindaequals(lh[ki],real(rh[ki]))
		intersect=lh[ki]
		println(intersect)
	end
end
k1=2/a*atan(intersect)
ga=k1*intersect
C=0.5ga/(cos(k1*a/2)+ga/k1*sin(k1*a/2))
A=C*k1/ga*sin(k1*a/2)*exp(ga*a/2)
function psi(x)
	if x<-a/2
		return A*exp(ga*x)
	elseif x<a/2
		return C*cos(k1*x) 
	else
		return A*exp(-ga*x)
	end
end

using Gadfly
p=plot(psi,-1,1);draw(PNG("p.png", 9inch, 6inch), p)
