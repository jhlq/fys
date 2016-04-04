using Gtk.ShortNames
type Countdown
	active::Bool
	updated
	remaining
end
c=Countdown(true,time(),90)

paceHzs=[0.5,0.3,0.2] 
popped=[false,false,false]
pvals=[1.0,1.0,1.0]

#Widgets
w=@Window("Rytm", 600, 300)
frame=@Frame("Swing it!"); push!(w,frame)
bb=@Box(:v); push!(frame,bb)
start=@Button("Begin a session"); push!(bb,start)
lcd=@Label("Countdown:"); push!(bb,lcd)
cd=@Label("$(c.remaining)"); push!(bb,cd)
#cd=@Entry(); push!(bb,cd)
#setproperty!(cd,:tooltip_text,"Catch me if you can!")
pause=@Button("Pause"); push!(bb,pause)
resume=@Button("Resume"); push!(bb,resume)
reset=@Button("Reset"); push!(bb,reset)

hbox=@Box(:h); push!(bb,hbox)
len=@Label("Length of session:"); push!(hbox,len)
sb=@SpinButton(1:999999999); push!(hbox,sb)
setproperty!(sb,:value,c.remaining)
setproperty!(hbox,:expand,len,true)
setproperty!(hbox,:expand,sb,true)
setproperty!(hbox,:spacing,10)

hzbox1=@Box(:h); push!(bb,hzbox1)
hzBl=@Label("Hz of B:"); push!(hzbox1,hzBl)
hzB=@SpinButton(0:0.001:999); push!(hzbox1,hzB)
setproperty!(hzB,:value,1)
setproperty!(hzbox1,:expand,hzBl,true)
setproperty!(hzbox1,:expand,hzB,true)
setproperty!(hzbox1,:spacing,10)

#hbox2=@Box(:h); push!(bb,hbox2)
#setproperty!(hbox2,:margin,30)
#setproperty!(hbox2,:spacing,15)
explanation=@Label("Hit the corresponding button when its value is as close as possible to 1."); push!(bb,explanation)
pace1=@Label("B: 1.0"); push!(bb,pace1)
pace2=@Label("N: 1.0"); push!(bb,pace2)
pace3=@Label("M: 1.0"); push!(bb,pace3)
score=@Label("Score: 0"); push!(bb,score)

showall(w)

function downcount()
	timepassed=(time()-c.updated)
	c.remaining=c.remaining-timepassed
	totaltimepassed=getproperty(sb,:value,Int64)-c.remaining
	if c.remaining<=0
		c.active=false
	end
	setproperty!(cd,:label,"$(c.remaining)")
	pvals[1]=abs(cos(totaltimepassed*paceHzs[1]*pi))
	setproperty!(pace1,:label,"B: $(round(pvals[1],1))")
	pvals[2]=abs(cos(totaltimepassed*paceHzs[2]*pi))
	setproperty!(pace2,:label,"N: $(round(pvals[2],1))")
	pvals[3]=abs(cos(totaltimepassed*paceHzs[3]*pi))
	setproperty!(pace3,:label,"M: $(round(pvals[3],1))")
	if !popped[1]
		
	end
	c.updated=time()
	sleep(0.03)
end

function start_cb(ptr::Ptr,cd)
	paceHzs[1]=getproperty(hzB,:value,AbstractFloat)
	c.remaining=getproperty(sb,:value,Int64)
	setproperty!(cd,:label,"$(c.remaining)")
	c.updated=time()
	c.active=true
	@async while c.active;downcount();end
	nothing
end
signal_connect(start_cb,start,"clicked",Void,(),false,cd)

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
	#c.remaining=getproperty(sb,:value,Int64)
	#setproperty!(cd,:label,"$(c.remaining)")
end

id = signal_connect(w, "key-press-event") do widget, event
	println("You pressed button ", event.keyval)
	println(typeof(event))
	@show typeof(event)
        @show event
end

function w_cb(ptr::Ptr,ptr2,score)
	println(typeof(ptr2))
	event=Gtk.unsafe_convert(Gtk.GdkEventKey,ptr2)
	println(typeof(event))
	#println("You pressed button ", event.keyval)
	nothing
end
signal_connect(w_cb,w,"key-press-event",Void,(Ptr{Gtk.GdkEventKey},),false,score)

