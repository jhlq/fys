x0=0
function u(t,x)
	
	if t<0
		return 0
	else
		return e^(-t-(x-x0)^2/(4t))/sqrt(4pi*t)
	end
end
function up(t,x)
	
	if t<0
		return 0
	else
		return e^(-t-(x-x0)^2/(3t))/sqrt(3pi*t^2)
	end
end
function der(u::Function,t,x,d=0.00000001)
	dt=(u(t+d,x)-u(t,x))/d
	dx=(u(t,x+d)-u(t,x))/d
	ddx=(u(t,x+2d)-u(t,x+d))/d
	dx2=(ddx-dx)/d
	return dt,dx,dx2
end
function audt(t,x)
	(-1/(2t)-1+(x-x0)^2/(4t^2))*u(t,x)
end
function audx2(t,x)
	(-1/(2t)+(x-x0)^2/(4t^2))*u(t,x)
end

function getau()
	(t2,blerg,x2)=der(up,0.5,0.5,0.000001)

	(t1,blerg,x1)=der(up,0.3,0.3,0.000001)
	u1=up(0.3,0.3)
	u2=up(0.5,0.5)
	tau=(x2*u1-x1*u2)/(x1*t2-x2*t1)
	lamsq=(tau*t1+u1)/x1
	return tau, lamsq
end
function tryt(tau,lamsq,c,a)
	(td,blerg,xxd)=der(up,0.7,0.7,0.000001)
	u=up(0.7,0.7)
	nt=-lamsq*xxd+tau*td+u
	#c=1/lamsq
	#a=1/tau
	(td,blerg,xxd)=der(up,0.7*a,0.7*c,0.000001)
	u=up(0.7a,0.7c)
	t=-xxd+td+u
	return nt,t
end
function tryc(c,tau)
	a=1/tau
	(blerg,t1)=tryt(0,0,c,a)
	println(t1)
	a=1/tau^2
	(blerg,t1)=tryt(0,0,c,a)
	println(t1)
	a=1/tau^0.5
	(blerg,t1)=tryt(0,0,c,a)
	println(t1)
	a=tau
	(blerg,t1)=tryt(0,0,c,a)
	println(t1)
	a=tau^2
	(blerg,t1)=tryt(0,0,c,a)
	println(t1)
	a=sqrt(tau)
	(blerg,t1)=tryt(0,0,c,a)
	println(t1)
end
