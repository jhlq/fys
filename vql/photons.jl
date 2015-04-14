module P
include("common.jl")
import Base.ctranspose,Base.isless, Base.display, Cubature.hcubature, Cubature.pcubature, Base.sum
export polmat,guv,cmu,PRL,wf,Photon,PhotonState, PhotonField, state,photon,braket,braket_fock, bs!, Aμ, Amu, πμ, pimu, der, lap, integrate, hcubature, pcubature, multarr, getexp, PhotonFields#, precision

#global precision = [Float64, 1e-1] #or BigFloat

#d_ada, d_a=[d0,-d1,-d2,-d3], da=[d0,d1,d2,d3]
#d_ada*StateP=0

function polmat(k)
	ep0=[1,0,0,0]
	ep1=zeros(4)
	ep2=zeros(4)
	ep3=k./norm(k)
	k3=k[2:4]
	k3p=zeros(3)
	if k[1:3]==[1,0,0]
		ep1+=[0,1,0,0]
		ep2+=[0,0,1,0]
	else
		k3p=deepcopy(k3)
		k3p+=rand(3)
		k32=cross(k3,k3p)
		k31=cross(k3,k32)
		ep2+=[0,k32]
		ep2/=norm(ep2)
		ep1+=[0,k31]
		ep1/=norm(ep1)
	end
	return [ep0 ep1 ep2 ep3]
end
guv=[1 0 0 0;0 -1 0 0;0 0 -1 0;0 0 0 -1]
cmu=[-1,1,1,1]
type Photon <: Wavticle
	k
	n::Integer
	polarity
	existance #0 to 1
	bounds
end
function display(p::Photon)
	symmetrical=true
	for d in 1:length(p.bounds)/2-1
		if p.bounds[:,d]!=p.bounds[:,d+1]
			symmetrical=false
		end
	end
	if symmetrical
		boundstr="Bounded in all dimensions from $(p.bounds[1,1]) to $(p.bounds[2,1])."
	else
		boundstr=""
		for d in 1:length(p.bounds)/2
			boundstr*="Bounded in dimension $d from $(p.bounds[1,d]) to $(p.bounds[2,d]).\n"
		end
	end	
	println("Photon\nk=$(p.k), n=$(p.n), polarity=$(p.polarity), existance=$(p.existance)\n$boundstr")
end
#photon()=Photon([1,0,0,1],1,[0,1,0,0],1)
function photon(k=[1,0,0,1],n=1,polarity=[0,1,0,0],existance=1,bounds=[-precision[1](pi/precision[2]),precision[1](pi/precision[2])],dim::Integer=4) #decimal numbers to 1e-9 will fit with whole waves
	bc=deepcopy(bounds)
	for d in 2:dim
		bounds=hcat(bounds,bc)
	end
	Photon(k,n,polarity,existance,bounds)
end
==(p1::Photon,p2::Photon)=p1.k==p2.k&&p1.n==p2.n&&p1.polarity==p2.polarity
function isless(p1::Photon,p2::Photon)
	for kmu in 1:length(p1.k)
		if p1.k[kmu]<p2.k[kmu]
			return true
		end
	end
	if p1.n<p2.n
		return true
	end
	for pvi in 1:length(p1.polarity)
		if p1.polarity[pvi]<p2.polarity[pvi]
			return true
		end
	end
	return p1.existance<p2.existance
end
type PRL<:Operator #Photon Raising Lowering
	photon::Photon
	raise::Bool
end
function display(tup::((PRL...,)...,))
	str="("
	for t in tup
		str*=" ($(t[1].raise), $(t[2].raise)),"
	end
	str=str[1:end-1]*" )"
	println(str)
end
function ctranspose(a::PRL)
	ap=deepcopy(a)
	#for vi in 1:length(ap.vec)
	#	ap.vec[vi]=ap.vec[vi]'
	#end
	ap.raise=!a.raise
	return ap
end
type PhotonState<:State
	K::Array{Photon}
	num
	bounds
end
function *(a::PRL,s::PhotonState)
	ns=deepcopy(s)
	if a.raise==true
		for nk in 1:length(s.K)
			if s.K[nk].k==a.photon.k && s.K[nk].polarity==a.photon.polarity
				ns.K[nk].n+=1
				ns.num*=sqrt(ns.K[nk].n)
				return ns
			end
		end
		push!(ns.K,a.photon)
		return ns
	else
		for nk in 1:length(s.K)
			if s.K[nk].k==a.photon.k && s.K[nk].polarity==a.photon.polarity
				ns.K[nk].n-=1
				ns.num*=sqrt(ns.K[nk].n+1)
				if ns.K[nk].n==0
					deleteat!(ns.K,nk)
				end
				return ns
			end
		end
		return 0
	end
end
function wf(ps::PhotonState,X)
	#Sum{r,k} 1/sqrt(2Vomk)*pol(mu,r,k)*a(r,k)*exp(-ikx) + C.C.
	tot=[0,0,0,0]
	V=vol(ps.bounds)
	for photon in ps.K
		epm=polmat(photon.k)
		for r in 1:4
			tot+=1/sqrt(2V*norm(photon.k[2:end]))*( photon.existance*epm[:,r]*photon.polarity[r]*exp(-im*dot(photon.k,X))+photon.existance'*epm[:,r]*photon.polarity[r]*exp(im*dot(photon.k,X)) )
		end
	end
	return tot
end
function state(dim::Integer=4,range=[-1e9pi,1e9pi]) #decimal numbers to 1e-9 will fit with whole waves
	rc=deepcopy(range)
	for d in 2:dim
		range=hcat(range,rc)
	end
	PhotonState([],1,range)
end
type PhotonField<:Field
	photon::Photon
	functions #deprecated
	coefs
	exponents
	operators
	f
	PhotonField(ph,fs,co,ex,op)=(pf=new(ph,fs,co,ex,op); pf.f=X->wf(pf,X); pf)
end
-(pf::PhotonField)=(npf=deepcopy(pf); npf.coefs*=-1; npf)
function Aμ(p::Photon) 
	om=norm(p.k[2:end])
	epm=polmat(p.k)	
	V=vol(p.bounds)
	coefs=Array[complex(p.existance/sqrt(2V*om)*epm*p.polarity),complex(p.existance/sqrt(2V*om)*epm*p.polarity)]
	function Aμplus(X)
		tot=[0,0,0,0]
		for r in 1:4
			tot+=p.existance/sqrt(2V*om)*epm[:,r]*p.polarity[r]*exp(-im*dot(p.k,X))
		end
		return tot
	end
	function Aμminus(X)
		tot=[0,0,0,0]	
		for r in 1:4
			tot+=p.existance/sqrt(2V*om)*epm[:,r]*p.polarity[r]*exp(im*dot(p.k,X))
		end
		return tot
	end
	exponents=(Any[-im,dot,p.k,:X],Any[im,dot,p.k,:X])
	PhotonField(p,(Aμplus,Aμminus),coefs,exponents,(PRL(p,false),PRL(p,true)))
end
Aμ()=Aμ(photon())
Amu=Aμ
function wf(pf::PhotonField,X)
	(pf.functions[1](X),pf.functions[2](X))
end
function wf(pf::PhotonField,X,f::Integer)
	expon=deepcopy(pf.exponents[f])
	Xloc=findin(expon,[:X])
	#expon[Xloc]=X
	d=dot(expon[Xloc-1][1],X)
	d*=multarr(expon[1:Xloc[1]-3])
	return pf.coefs[f]*exp(d)
end
function multarr(arr::Array)
	tot=1
	for a in arr
		tot*=a
	end
	return tot
end
function der(pf::PhotonField,dim::Integer=1)
	pfd=deepcopy(pf)
	dotloc1=findin(pf.exponents[1],[dot])
	dotloc2=findin(pf.exponents[2],[dot])
	m1=pfd.coefs[1]*multarr(pfd.exponents[1][1:dotloc1[1]-1])*pf.photon.k[dim]
	m2=pfd.coefs[2]multarr(pfd.exponents[2][1:dotloc2[1]-1])*pf.photon.k[dim]
	for d in 1:length(m1)
		pfd.coefs[1][d]=m1[d]
		pfd.coefs[2][d]=m2[d]
	end
	return pfd
end
function der(pf::PhotonField,X::Array,dim::Integer=1,d=precision[2]/10)
	(f1,f2)=wf(pf,X)
	X[dim]+=d
	(fp1,fp2)=wf(pf,X)
	return ((fp1-f1)/d,(fp2-f2)/d)	
end
function lap(pf::PhotonField,X,d=precision[2]/10)
	dd=[der(pf,X,1,d),der(pf,X,2,d),der(pf,X,3,d),der(pf,X,4,d)]
	return (Array[dd[1][1],dd[2][1],dd[3][1],dd[4][1]],Array[dd[1][2],dd[2][2],dd[3][2],dd[4][2]])
end
function sum(a1::Array{Array},a2::Array{Array})
	dim1=length(a1)
	dim2=length(a1[1])
	typ=typeof(a1[1][1])
	s=Array(typ,dim1)
	for d2 in 1:dim2
		for d1 in 1:dim1
			s[d2]+=a1[d1][d2]+a2[d1][d2]
		end
	end
	return s
end
#πμ=-der(Aμ)
function πμ(p::Photon)
	om=norm(p.k[2:end])
	epm=polmat(p.k)	
	V=vol(p.bounds)
	coefs=(im*p.k[1]*p.existance/sqrt(2V*om)*epm*p.polarity,-im*p.k[1]*p.existance/sqrt(2V*om)*epm*p.polarity)
	function πμplus(X)
		tot=[0,0,0,0]
		for r in 1:4
			tot+=im*p.k[1]*p.existance/sqrt(2V*om)*epm[:,r]*p.polarity[r]*exp(-im*dot(p.k,X))
		end
		return tot
	end
	function πμminus(X)
		tot=[0,0,0,0]	
		for r in 1:4
			tot+=-im*p.k[1]*p.existance/sqrt(2V*om)*epm[:,r]*p.polarity[r]*exp(im*dot(p.k,X))
		end
		return tot
	end
	exponents=(Any[-im,dot,p.k,:X],Any[im,dot,p.k,:X])
	PhotonField(p,(πμplus,πμminus),coefs,exponents,(PRL(p,false),PRL(p,true)))
end
πμ()=πμ(photon())
pimu=πμ
type FieldProduct<:Field
	x
end
type PhotonFields<:Product
	photons::Array{Photon}
	functions#::Array{(Function,Function)} #deprecated
	coefs::Tuple#Array#{Array}
	exponents::((Array...,)...,)#(Array{Array{Array}}
	operators::((Operator...,)...,)#Array{(Operator,Operator)}
end
function *(pf1::PhotonField,pf2::PhotonField)
	photons=[pf1.photon,pf2.photon]
	coef1=pf1.coefs[1].*pf2.coefs[1]
	coef2=pf1.coefs[1].*pf2.coefs[2]
	coef3=pf1.coefs[2].*pf2.coefs[1]
	coef4=pf1.coefs[2].*pf2.coefs[2]
	coefs=(coef1,coef2,coef3,coef4)

	exp1=(pf1.exponents[1],pf2.exponents[1])
	exp2=(pf1.exponents[1],pf2.exponents[2])
	exp3=(pf1.exponents[2],pf2.exponents[1])
	exp4=(pf1.exponents[2],pf2.exponents[2])
	exps=(exp1,exp2,exp3,exp4)
	
	ops1=(pf1.operators[1],pf2.operators[1])
	ops2=(pf1.operators[1],pf2.operators[2])
	ops3=(pf1.operators[2],pf2.operators[1])
	ops4=(pf1.operators[2],pf2.operators[2])
	opses=(ops1,ops2,ops3,ops4)

	return PhotonFields(photons,0,coefs,exps,opses)
end
type PhotonFieldsSum<:Sum

end
function getexp(pf::PhotonField,X)
	Xloc1=findin(pf.exponents[1],[:X])
	Xloc2=findin(pf.exponents[2],[:X])
	d1=dot(pf.exponents[1][Xloc1-1][1],X)
	d1*=multarr(pf.exponents[1][1:Xloc1[1]-3])
	d2=dot(pf.exponents[2][Xloc2-1][1],X)
	d2*=multarr(pf.exponents[2][1:Xloc2[1]-3])
	return (d1,d2)
end
function integrate(pf::PhotonField,abstol=precision[2])
	(e1,e2)=getexp(pf,rand(4))
	if e1!=1 && e2!=1
		return (0,0)
	end
	#(hcubature(x->real(conj(wf(s1,x))*wf(s2,x)),s1.bounds[1,:],s1.bounds[2,:],abstol=1e-9)[1]+im*hcubature(x->imag(conj(wf(s1,x))*wf(s2,x)),s1.bounds[1,:],s1.bounds[2,:],abstol=1e-9)[1])/vol(s1.bounds)
	function intfun(X,v,f::Integer=1)
		tv=pf.functions[f](X)
		for d in 1:length(tv)
			v[2d-1]=real(tv[d])
			v[2d]=imag(tv[d])
		end
		return v
	end
	dim=length(pf.photon.bounds[1,:])
	rv1=zeros(Complex,dim)
	rv2=zeros(Complex,dim)
	tv1=hcubature(2dim,intfun,pf.photon.bounds[1,:]+precision[2]/10,pf.photon.bounds[2,:],abstol=abstol)
	tv2=hcubature(2dim,intfun,pf.photon.bounds[1,:]+precision[2]/10,pf.photon.bounds[2,:],abstol=abstol)	
	for d in 1:dim
		rv1[d]=complex(tv1[1][2d-1],tv1[1][2d])
		rv2[d]=complex(tv2[1][2d-1],tv2[1][2d])
	end
	return (rv1,rv2)
end
function getexp(pfs::PhotonFields,X)
	expses=length(pfs.exponents)
	#Xlocs=Array(Any,expses)
	#for i in 1:expses
	#	Xlocs[i]=(findin(pfs.exponents[i][1],[:X])[1],findin(pfs.exponents[i][2],[:X])[1])
	#end
	Xlocs=4
	ds=zeros(Complex64,expses)
	for i in 1:expses
		ds[i]=pfs.exponents[i][1][1]*dot(pfs.exponents[i][1][Xlocs-1],X)+pfs.exponents[i][2][1]*dot(pfs.exponents[i][2][Xlocs-1],X)
		#ds[i]*=multarr(pfs.exponents[1][1:Xlocs-3])
	end
	#d1*=multarr(pfs.exponents[1][1:Xloc1[1]-3])
	#d2=dot(pfs.exponents[2][Xloc2-1][1],X)
	#d2*=multarr(pfs.exponents[2][1:Xloc2[1]-3])
	return ds
end
function integrate(pfs::PhotonFields,abstol=precision[2])
	exps=getexp(pfs,rand(4)) #this can be made more efficient by checking if pfs.exponents[indecies] cancel 
	nterms=length(exps)
	results=zeros(4)
	for term in 1:nterms
		if exps[term]==0
			results[term]=1
		end
	end
	return results
end
function braket_fock(s1::PhotonState,s2::PhotonState)
	sort(s1.K)==sort(s2.K)?1:0
end
function braket(s1::PhotonState,s2::PhotonState)
	s1.num*s2.num*braket_fock(s1,s2)
end
#=	
F=[	0	E[2]	E[3]	E[4];
	-E[2]	0	B[4]	-B[3];
	-E[3]	-B[4]	0	B[2];
	-E[4]	B[3]	-B[2]	0	]
=#
type CreationP
	ar
end
type OperatorCoef
end


#pol=eye(4)
#polv0
function polvec(r::Integer,k)
	if r==3
		return k./norm(k)
	end
end

function bs!(s::PhotonState) #bare state
	s.num=1
end
function bs!(sa::Array{PhotonState})
	for s in sa
		bs!(s)
	end
end


function t1()
	k=rand(4)#[0,0,0,1]
	k[1]=0
	epm=polmat(k)
	assert("1",sum(guv*epm[:,1].*epm[:,1]),1)
	assert("2",sum(guv*epm[:,2].*epm[:,2]),-1)
	assert("3",sum(guv*epm[:,3].*epm[:,3]),-1)
	assert("4",sum(guv*epm[:,4].*epm[:,4]),-1)
	assert("5",dot(k[2:4],epm[2:4,2]),0)
	assert("6",dot(k[2:4],epm[2:4,3]),0)
end
function t2()
	pho=Photon([0,0,0,1],1,[0,1,0,0],1)
	a=PRL(pho,false)
	s0=state()
	s1=a'*s0
	s5=a'^5*s0
	bs!(s5)
	N=a'*a
	assert("N",braket(s5,N*s5),5)
end
function t3()
	pho=Photon([0,0,0,1],1,[0,1,0,0],1)
	a=PRL(pho,false)
	s0=state()
	s1=a'*s0
	ar=zeros(Complex,100)
	for r in 1:100;X=[0,0,0,pi/30*r];ar[r]=wf(s1,X)[2];end
	using Gaston
	plot([real(ar) imag(ar)])
end
function t4()
	p=photon()
	pf=Amu(p)
	pfc=pimu(p)
	X=rand(4)
	pfd=der(pf,X)
	pfi=integrate(pf)
	assert("Integration",pfi[1],0)
	assert(pfi[2],0)
	assert("Conjugation",wf(pfc,X)[1],-pfd[1])
	assert(wf(pfc,X)[2],-pfd[2])
#	assert(integrate(fipHam),H)
#	com(amu,pimu)
end
function t5()
	p=photon()
	pf=Amu(p)
	X=rand(4)
	(pflap1,pflap2)=lap(pf,X)
	(pf_lap1,pf_lap2)=lap(pf,guv*X)
	hamdens1=-0.5sum(pflap1,pf_lap1)
end
function t6()
	p=photon()
	pf=Amu(p)
	X=rand(4)
	pm1=pimu(p)
	pm2=der(pf)

	assert(wf(pf,X)[1],wf(pf,X,1))
	assert(wf(pm1,X)[1],-wf(pm2,X,1))
end
function t7()
	pf1=Amu()
	pf2=pimu()
	pfs=pf1*pf2
	getexp(pfs,rand(4))
	integrate(pfs)
	pfs.operators
end

end
