function fade(r,r0=1) #r is distance, r0 is distance from mike to soundsource.
	10log(10,(r0/r)^2)
end

function delay(r)
	r/350 #350 meters away the sound is delayed 1 second.
end

type Source
	x
	y
	file	
end
sources=Source[Source(35,52,"sound1.wav"),Source(78,91,"sound2.wav"),Source(12,3,"sound3.wav")]

function process(sources,loc)
	fades=Float64[]
	delays=Float64[]
	for source in sources
		r=sqrt((loc[1]-source.x)^2+(loc[2]-source.y)^2)
		push!(fades,fade(r))
		push!(delays,delay(r))
	end
	return fades,delays
end
