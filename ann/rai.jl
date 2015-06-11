#module d
using JSON
#using Requests
function rsample()
	start=1000*abs(rand(Int)%100)
	trades=JSON.parse(readall(`curl https://ripple.com/chart/BTC/XRP/trades.json?since=$start`))
	#trades=JSON.parse(get("https://ripple.com/chart/BTC/XRP/trades.json?since=$start").data)
	np=100
	peek=zeros(np,2)
	for t in 1:np
		peek[t,1]=float(trades[t]["price"])
		peek[t,2]=float(trades[t]["amount"])*(0.5+0.5*t/100)
	end
	ma=maximum(peek[:,1])
	mi=minimum(peek[:,1])
	niv=33
	bars=zeros(niv)
	intervall=(ma-mi)/niv
	for t in 1:np
		for iv in 1:niv
			if peek[t,1]<mi+intervall*iv
				bars[iv]+=peek[t,2]
				break
			end
		end
	end
	maxi=sortperm(bars,rev=true)
	bidiv1=maxi[1]*intervall+mi
	bidiv2=maxi[2]*intervall+mi

	bid1val=0
	bid2val=0
	barval=0
	for testi in 101:1000
		test=[float(trades[testi]["price"]),float(trades[testi]["amount"])]
		for iv in 1:niv
			if test[1]<bidiv1 && test[1]>bidiv1-intervall
				bid1val+=test[2]
				break
			elseif test[1]<bidiv2 && test[1]>bidiv2-intervall
				bid2val+=test[2]
				break
			end
		end
		if bid1val>1 && bid2val>1
			println(testi)
			barval=1-(testi-101)/900
			break
		end
	end
	return bars,barval
end
function makenet(nil,nml,nol)
	net=Array(Array,3)
	net[1]=zeros(nil,nml)+rand(nil,nml).-0.5
	net[2]=zeros(nml,nol)+rand(nml,nol).-0.5
	net[3]=[nil,nml,nol]#ones(3)+rand().-0.5
	return net
end
function mutate(net,amp=1.0)
	nnet=deepcopy(net)
	nl=length(net)-1
	for l in 1:nl
		for n in 1:net[end][l]
			for nn in 1:net[end][l+1]
				if randbool()
					nnet[l][n,nn]+=(rand()-0.5)*amp
				end
			end
		end
	end
	return nnet
end
function mutate(net,nm::Integer)
	nets=Array(Array,nm)
	for m in 1:nm
		nets[m]=mutate(net)
	end
	return nets
end

#function mutate(net,m::Mutator)
#	if isempty(m.pokesult)
#		
#	end
#end
		
function sigmoid(x)
	return x/(abs(x)+1)
end
function feed(net,d)
	(nil,nml,nol)=net[end][1],net[end][2],net[end][3]
	
	td=zeros(nml)
	for n in 1:nml
		td[n]=dot(net[1][:,n],d)
	end
	s=zeros(nol)
	for n in 1:nol
		s[n]=sigmoid(dot(net[2][:,n],td))
	end
	return s
end
function simil(v1,v2)
	1-abs((v1-v2))
end
function transpatinvari(d)
	dn=d/maximum(abs(d))
	nd=length(dn)
	if nd%2==0
		push!(dn,0)
		nd+=1
	end
	t=zeros(nd)
	for da in 1:nd
		for dat in 0:nd-da
			t[1+dat]+=dn[da]*simil(dn[da],dn[da+dat])
		end
	end
	return t
end
function score(net)
	(bars,bval)=rsample()
	tbars=transpatinvari(bars)
	pred=feed(net,tbars)
	return simil(sum(pred)/3,bval)
end
function score(nets,its)
	nn=length(nets)
	scores=zeros(nn)
	for it in 1:its
		(bars,bval)=rsample()
		tbars=transpatinvari(bars)
		for n in 1:nn
			pred=feed(nets[n],tbars)
			scores[n]+=simil(sum(pred)/3,bval)
			println(scores[n])
		end
	end
	return scores
end
function evolve(net=makenet(33,50,3),gens=3,its=9)
	nn=9
	m1=6
	nets=mutate(net,nn)
	tnets=nets
	scores=Array(Array,gens)
	for gen in 1:gens
		scores[gen]=score(nets,its)
		tops=sortperm(scores[gen],rev=true)
		tnets[1:m1]=mutate(nets[tops[1]],m1)
		tnets[m1+1:end]=mutate(nets[tops[2]],nn-m1)
		nets=tnets
	end
	return nets,scores
end
type Mutator
	pokesult::Array
	mutfac::Array
	scoreimps::Array
	ilmlol
	bestimprov
	net
	data
	target
end
function init(il=33,ml=50,ol=3)
	return makenet(il,ml,ol),Mutator(ones(Float64,il+ml),ones(Float64,il+ml),ones(Float64,il+ml),[il,ml,ol],0,0,0,0)
end
function netco(m::Mutator,i::Integer)
	(il,ml,ol)=m.ilmlol
	l=1
	n=1
	if i>il
		if i>il+ml
			l=3
			n=i-il-ml
			print_with_color(:red,"Too high index.")
		else
			l=2
			n=i-il
		end
	else
		n=i
	end
	return l,n
end
function poke!(net::Array,m::Mutator)
	(bars,bval)=rsample()
	tbars=transpatinvari(bars)
	pred=feed(net,tbars)
	score=simil(sum(pred)/3,bval)
	s=sum(m.scoreimps)
	r=abs(rand(Float64)*s)
	ri=1
	ts=0
	for i in 1:length(m.scoreimps)
		ts+=m.scoreimps[i]
		if ts>r
			ri=i
			break
		end
	end
	l,n=netco(m,ri)
	println("$ri,$l,$n")
	net[l][n]*=m.mutfac[ri]
	nscore=simil(sum(feed(net,tbars))/3,bval)
	if nscore>score
		m.pokesult[ri]+=1
		m.scoreimps[ri]=nscore-score
	else
		net[l][n]=net[l][n]/(-m.mutfac[ri])
		nscore=simil(sum(feed(net,tbars))/3,bval)
		if nscore>score
			m.pokesult[ri]+=1
			m.mutfac[ri]=-m.mutfac[ri]
			m.scoreimps[ri]=nscore-score
		else 
			net[l][n]*=m.mutfac[ri]*1.1
			nscore=simil(sum(feed(net,tbars))/3,bval)
			if nscore>score
				m.mutfac[ri]*=1.1
				m.scoreimps[ri]=nscore-score
			else 
				net[l][n]*=m.mutfac[ri]*0.9
				nscore=simil(sum(feed(net,tbars))/3,bval)
				if nscore>score
					m.mutfac[ri]*=0.9
					m.scoreimps[ri]=nscore-score
				else 
					m.mutfac[ri]*=rand()*6-3
					m.scoreimps[ri]=minimum(m.scoreimps)*0.5
				end
			end
		end
	end	
end
	
function evolve2(net=makenet(33,50,3),gens=3,its=9)
	scores=Array(Array,gens)
	for gen in 1:gens
		
	end
end
#end
