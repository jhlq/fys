using Gtk.ShortNames
import AudioIO
AudioIO.Pa_Initialize()

conserve_resources=true
playfun=AudioIO.play
if conserve_resources
	#function for playing sound without leaving the stream open
	#from https://github.com/ssfrr/AudioIO.jl/issues/44
	#will probably make it into the package in some form
	function playclose(sound::Vector,sampleRate::Real=44100)
		fac=div(length(sound),sampleRate);
		streamM=AudioIO.Pa_OpenDefaultStream(0,1,AudioIO.paFloat32,sampleRate,fac);
		AudioIO.Pa_StartStream(streamM);
		for i=1:fac
			AudioIO.Pa_WriteStream(streamM,convert(Array{Float32},sound[(i-1)*sampleRate+1:i*sampleRate]));
		end
		AudioIO.Pa_StopStream(streamM)
		AudioIO.Pa_CloseStream(streamM)
	end 
	playfun=playclose
end

bellfile=dirname(Base.source_path())*"/ZenTempleBell.wav"
if ispath(bellfile)
	import WAV
	bell=WAV.wavread(bellfile)[1][:,1]
#	bell = AudioIO.open(bellfile) do f	#this is noisy
#		read(f)
#	end
else
	samplerate=44100
	seconds=3
	x=linspace(2pi/samplerate,seconds*2pi,seconds*samplerate)
	amp=0.3
	d=linspace(1,0,seconds*samplerate)
	A=444
	r=(528/444)^(1/3)
	bell=cos(A.*x).*d.*amp.+cos(A*r^3.*x).*d.*amp.+cos(A*r^5.*x).*d.*amp
end
type Countdown
	active::Bool
	updated
	remaining
end
c=Countdown(true,time(),900)

#Widgets
w=@Window("Mindfulness", 600, 300)
frame=@Frame("Bell"); push!(w,frame)
bb=@Box(:v); push!(frame,bb)
b=@Button("Ring the bell"); push!(bb,b)
lcd=@Label("Countdown:"); push!(bb,lcd)
cd=@Label("$(c.remaining)"); push!(bb,cd)
setproperty!(cd,:tooltip_text,"Catch me if you can!")
resume=@Button("Resume"); push!(bb,resume)
pause=@Button("Pause"); push!(bb,pause)
reset=@Button("Reset"); push!(bb,reset)

hbox=@Box(:h); push!(bb,hbox)
len=@Label("Length:"); push!(hbox,len)
sb=@SpinButton(1:999999999); push!(hbox,sb)
setproperty!(sb,:value,c.remaining)
setproperty!(hbox,:expand,len,true)
setproperty!(hbox,:expand,sb,true)
setproperty!(hbox,:spacing,10)

hbox2=@Box(:h); push!(bb,hbox2)
vol=@Label("Volume:"); push!(hbox2,vol)
volume=@Scale(false,0:0.05:3); push!(hbox2,volume)
voladj = @Adjustment(volume)
setproperty!(voladj,:value,1)
setproperty!(hbox2,:expand,volume,true)
setproperty!(hbox2,:margin,30)
setproperty!(hbox2,:spacing,15)

showall(w)

signal_connect(b, "clicked") do widget
	playfun(getproperty(voladj,:value,Float64).*bell)
end

function downcount()
	c.remaining=c.remaining-(time()-c.updated)
	if c.remaining<=0
		playfun(getproperty(voladj,:value,Float64).*bell)
		c.remaining=getproperty(sb,:value,Int64)
	end
	setproperty!(cd,:label,"$(c.remaining)")
	c.updated=time()
	sleep(1)
end
signal_connect(resume, "clicked") do widget
	if !c.active
		c.updated=time()
		c.active=true
		@async while c.active;downcount();end
	end
end
signal_connect(pause, "clicked") do widget
	c.active=false
end
signal_connect(reset, "clicked") do widget
	c.remaining=getproperty(sb,:value,Int64)
	setproperty!(cd,:label,"$(c.remaining)")
end

@async while c.active;downcount();end
if !isinteractive() #this will evaluate to true even if the script is loaded with -L
	condition=Condition()
	signal_connect(w, :destroy) do widget
		notify(condition)
	end
	wait(condition)
	c.active=false
end
