module P
include("common.jl")
import Base.ctranspose,Base.isless
export polmat,guv,cmu,PRL,wf,Photon,PhotonState,state,photon,braket,braket_fock, bs!

#d_ada, d_a=[d0,-d1,-d2,-d3], da=[d0,d1,d2,d3]
#d_ada*StateP=0

function polmat(k)
	ep0=[1,0,0,0]
	ep1=zeros(4)
	ep2=zeros(4)
	ep3=k./norm(k)
	k3=k[2:4]
	k3p=zeros(3)
	if k[1:3]==k3p
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
end
photon()=Photon([0,0,0,1],1,[0,1,0,0],1)
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
			tot+=photon.existance/sqrt(2V*norm(photon.k))*epm[:,r]*photon.polarity[r]*exp(im*dot(photon.k,X))
		end
	end
	return tot
end
function state(dim::Integer=4)
	range=[-pi,1pi]
	for d in 2:dim
		range=hcat(range,[-pi,1pi])
	end
	PhotonState([],1,range)
end
type Aµ<:Field
	p::Photon
end
Amu=Aµ
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

end
