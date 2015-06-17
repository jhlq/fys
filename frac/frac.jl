#to do 10 iterations:
#julia -L frac
#dig(10)

#to display fractals:
#view(x,y,zoom)
#view(records[end,:]) 
#view(maptree[3,:]) 

#to run indefinitely with two threads:
#julia -p 2
#require("frac.jl")
#dig() 

const useGPU=false #currently limited to single precision 
const viewEnabled=true
const verbose=false
if useGPU==true
	import OpenCL
	const cl = OpenCL
	cld=1 #check cl.devices() and specify which device to use
end
if viewEnabled==true
	using PyPlot
	cm="prism"
	get_cmap(cm)
end

const maxiter=3000-1 #if this number is changed the map and records become invalid.
const prunedmap=9000 #when the map is sorted it is also pruned to this many entries.
const dim=1000
const maplim=1.95e6 
function addtomap(x,y,z,inq)
	fh=open("map.csv","a")
	write(fh,"$x,$y,$z,$inq\n")
	close(fh)
end
function addrecord(x,y,z,inq)
	fh=open("records.csv","a")
	write(fh,"$x,$y,$z,$inq\n")
	close(fh)
end
if ispath("records.csv")
	records=readdlm("records.csv",',')
else 
	addrecord(0,0,1,1.9467973333332038e6)
end
if !ispath("map.csv")
	addtomap(-2,-1,1,1.956610666666484e6)
	addtomap(-2,0,1,1.956610666666484e6)
	addtomap(0,0,1,1.9467973333332038e6)
	addtomap(0,-1,1,1.9467973333332038e6)
end
maptree=readdlm("map.csv",',')
#record=records[end,4]
function mandel(z)
	c = z 
	for n = 1:maxiter
		if abs2(z) > 4.0
			return n-1
		end
		z = z*z + c
	end
	return maxiter
end
function ordinary_mandel(q)
	(h, w) = size(q)
	m  = Array(Uint16, (h, w));
	for i in 1:w
		for j in 1:h
			@inbounds v = q[j, i]
			@inbounds m[j, i] = mandel(v)
		end
	end
	return m
end
function mandel_cpu(x::Float64,y::Float64,z::Float64,w::Int64=dim,h::Int64=dim)
	q = [complex(r,i) for i=linspace(y,y+1/z,h), r=linspace(x,x+1/z,w)];
	m  = Array(Uint16, (h, w));
	for i in 1:w
		for j in 1:h
			@inbounds v = q[j, i]
			@inbounds m[j, i] = mandel(v)
		end
	end
	return m
end
function getq(x::Float64,y::Float64,z::Float64,w::Int64=dim,h::Int64=dim)
       	q = [complex(r,i) for i=linspace(y,y+1/z,h), r=linspace(x,x+1/z,w)]
end
mandel_cpu(x::Real,y::Real,z::Real)=mandel_cpu(float(x),float(y),float(z))
mandel_cpu(a::Array)=mandel_cpu(a[1],a[2],a[3])
function inequality(m::Array)
	itspace=zeros(Int64,maxiter+1)
	d,w=size(m)
	for p1 in 1:d
		for p2 in 1:w
			itspace[int(m[p1,p2])+1]+=1
		end
	end
	ism=mean(itspace)
	sco=0
	for it in itspace
		sco+=abs(it-ism)
	end
	return sco
end
function inequality_t(m::Array)
	step=(maxiter+1)/100
	itspace=zeros(Int64,100)
	d,w=size(m)
	#nm=zeros(d,w)
	for p1 in 1:d
		for p2 in 1:w
			ind=floor(int(m[p1,p2])/step+1)
			itspace[ind]+=1
		#	nm[p1,p2]=ind
		end
	end
	ism=mean(itspace)
	sco=0
	for it in itspace
		sco+=abs(it-ism)
	end
	return sco#,nm
end
if useGPU==true
	mandel_source = "
	#pragma OPENCL EXTENSION cl_khr_byte_addressable_store : enable
	__kernel void mandelbrot(__global float2 *q,
						 __global ushort *output, 
						 ushort const maxiter)
	{
	 int gid = get_global_id(0);
	 float nreal, real = 0;
	 float imag = 0;
	 output[gid] = 0;
	 for(int curiter = 0; curiter < maxiter; curiter++) {
		 nreal = real*real - imag*imag + q[gid].x;
		 imag = 2* real*imag + q[gid].y;
		 real = nreal;

		 if (real*real + imag*imag > 4.0f)
		 output[gid] = curiter;
	  }
	}";

	function mandel_opencl(q::Array{Complex64}, maxiter::Int64)
		ctx   = cl.Context(cl.devices()[cld])
		queue = cl.CmdQueue(ctx)

		out = Array(Uint16, size(q))

		q_buff = cl.Buffer(Complex64, ctx, (:r, :copy), hostbuf=q)
		o_buff = cl.Buffer(Uint16, ctx, :w, length(out))

		prg = cl.Program(ctx, source=mandel_source) |> cl.build!
		
		k = cl.Kernel(prg, "mandelbrot")
		cl.call(queue, k, length(out), nothing, q_buff, o_buff, uint16(maxiter))
		cl.copy!(queue, out, o_buff)
		
		return out
	end
	function mandel_gpu(x::Float64,y::Float64,z::Float64,w::Int64=dim,h::Int64=dim)
		q = [complex64(r,i) for i=linspace(y,y+1/z,h), r=linspace(x,x+1/z,w)];
		m = mandel_opencl(q,maxiter)		
		return m
	end
	mandel_gpu(x::Real,y::Real,z::Real)=mandel_gpu(float(x),float(y),float(z))
	mandel_gpu(a::Array)=mandel_gpu(a[1],a[2],a[3])
end
if viewEnabled==true
	function view(x::Real,y::Real,z::Real)
		if useGPU==true
			m=mandel_gpu(x,y,z)
		else
			m=mandel_cpu(x,y,z)
		end
		imshow(m,cmap=cm)
		println(inequality(m))
	end
	view(a::Array)=view(a[1],a[2],a[3])
end
function dig(n::Int64)
	map=readdlm("map.csv",',')
	if size(map,1)>1.5*prunedmap
		prunemap(prunedmap)
	end
	records=readdlm("records.csv",',')
	record=records[end,4]
	m=0
	ns=0
	for it in 1:n
		loci=rand(1:size(map,1))
		(x,y,z,s)=(map[loci,1],map[loci,2],map[loci,3],map[loci,4])
		nx=x+rand()/z
		ny=y+rand()/z
		nz=10z
		if useGPU==true
			m=mandel_gpu(nx,ny,nz)
		else
			m=mandel_cpu(nx,ny,nz)
		end
		ns=inequality(m)
		prant=false
		if ns<maplim
			addtomap(nx,ny,nz,ns)
			println("New map entry: $nx $ny $nz $ns")
			prant=true
			map=cat(1,map,[nx ny nz ns])
		end
		if ns<record
			addrecord(nx,ny,nz,ns)
			println("New record!")
			records=cat(1,records,[nx ny nz ns])
			record=ns
		end
		if verbose==true && prant==false
			println(ns)
		elseif prant==false
			print(".")
		end
	end
	#return 1
end
function dig(a::Array{Bool,1}=[true],batchsize::Int64=1000)
	#by passing a named array @async dig can be terminated gracefully
	np=nprocs()
	if np>1
		@everywhere include("frac.jl")
	end
	while a[1]==true
		if np>1
			refs=Array(RemoteRef,np)
			for p in 1:np
				refs[p]=@spawn dig(batchsize)
			end
			for p in 1:np
				wait(refs[p])
			end
		else 
			dig(batchsize)
		end
	end
end
function prunemap(keep::Integer)
	map=readdlm("map.csv",',')
	order=sortperm(map[:,4])
	fh=open("map.csv","w")
	write(fh,"")
	close(fh)
	nme=length(order)
	#kk=(keep<nme)?keep:nme
	kk=0
	if keep<nme
		kk=keep
	else
		kk=nme
	end	
	fh=open("map.csv","a")
	for k in 1:kk
		write(fh,"$(map[order[k],1]),$(map[order[k],2]),$(map[order[k],3]),$(map[order[k],4])\n")
	end
	close(fh)
end
		
	
