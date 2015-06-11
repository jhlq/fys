type Storage
	A::Number
	t::Number
	E::Number
	k::Number
	points::Array
	psi::Function
	xrot::Number
	yrot::Number
	zrot::Number

	rlen::Int64
	qlen::Float64
	room::Array{Float64,3}
	rval::Array{Complex,3}
	psi3d::Function
end
sto=Storage(1.0,0,1.0,1,Array(Float64,(45,45,3)),x->0,15,0,0,0,0,Array(Float64,1,1,1),Array(Complex,1,1,1),x->0)
sto.psi=(x,y)->sto.A*exp(im*(sto.k*(x+y)-sto.E*sto.t/10))

sto.rlen=9
sto.qlen=0.5
sto.room=Array(Float64,sto.rlen,sto.rlen,sto.rlen)
sto.rval=Array(Complex,sto.rlen,sto.rlen,sto.rlen)
sto.psi3d=(x,y,z)->sto.A*exp(im*(sto.k*(x+y+z)-sto.E*sto.t/10))

function setroom()
	l=sto.rlen
	for x=1:l
		for y=1:l
			for z=1:l
				sto.rval[x,y,z]=sto.psi3d(x,y,z)
			end
		end
	end
end
setroom()

function setpoints()
	for x=1:45
		for y=1:45
		sto.points[x,y,1] = x/5-4.5
		sto.points[x,y,2] = y/5-4.5
		sto.points[x,y,3] = real(sto.psi(x/5,y/5)) # sin((((x/5)*40)/360)*2*pi)+sin((((x/5)*40)/360)*5*pi)+cos((((y/5)*40)/360)*3*pi)
		end
	end
end
setpoints()
function mag(nitude::Float64,color::Array{Float64,1},size::Float64=0.5)
	glColor3f(color[1],color[2],color[3])
	glBegin(GL_POLYGON)
		glVertex(0.0,0.0,0.0)
		glVertex(size,0.0,0.0)
		glColor3f(color[1]*1.5,color[2]*1.5,color[3]*1.5)
		glVertex(size*0.5,size*0.25,nitude)
	glEnd()
	glColor3f(color[1],color[2],color[3])
	glBegin(GL_POLYGON)
		glVertex(0.0,0.0,0.0)
		glVertex(size*0.5,size*sqrt(0.75),0.0)
		glColor3f(color[1]*1.5,color[2]*1.5,color[3]*1.5)
		glVertex(size*0.5,size*0.25,nitude)
	glEnd()
	glColor3f(color[1],color[2],color[3])
	glBegin(GL_POLYGON)
		glVertex(size,0.0,0.0)
		glVertex(size*0.5,size*sqrt(0.75),0.0)
		glColor3f(color[1]*1.5,color[2]*1.5,color[3]*1.5)
		glVertex(size*0.5,size*0.25,nitude)
	glEnd()
end

# load necessary GLUT/OpenGL routines

global OpenGLver="1.0"
using OpenGL
using GLUT

# initialize variables

global window

#=
global xrot = 0
global yrot = 0

global box	= 0
global top	= 0

boxcol		= [1.0 0.0 0.0;
				 1.0 0.5 0.0;
				 1.0 1.0 0.0;
				 0.0 1.0 0.0;
				 0.0 1.0 1.0]

topcol		= [0.5 0.0	0.0;
				 0.5 0.25 0.0;
				 0.5 0.5	0.0;
				 0.0 0.5	0.0;
				 0.0 0.5	0.5]
=#
width		 = 640
height		= 480

global LightAmbient  = [0.5f0, 0.5f0, 0.5f0, 1.0f0]
global LightDiffuse  = [1.0f0, 1.0f0, 1.0f0, 1.0f0]
global LightPosition = [0.0f0, 0.0f0, 2.0f0, 1.0f0]

# function to init OpenGL context
function initGL(w::Integer,h::Integer)
	glViewport(0,0,w,h)
	glClearColor(0.0, 0.0, 0.0, 0.0)
	glClearDepth(1.0)			 
	glDepthFunc(GL_LEQUAL)	 
	glEnable(GL_DEPTH_TEST)
	glEnable(GL_COLOR)
	glShadeModel(GL_SMOOTH)
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)

#=	# initialize lights
	glLightfv(GL_LIGHT1, GL_AMBIENT, LightAmbient)
	glLightfv(GL_LIGHT1, GL_DIFFUSE, LightDiffuse)
	glLightfv(GL_LIGHT1, GL_POSITION, LightPosition)

	glEnable(GL_LIGHT1)
	glEnable(GL_LIGHTING)

	glEnable(GL_COLOR_MATERIAL)
=#
	# enable Polygon filling

#	glPolygonMode(GL_BACK, GL_FILL)
#	glPolygonMode(GL_FRONT, GL_LINE)

	glMatrixMode(GL_PROJECTION)
	glLoadIdentity()

	gluPerspective(45.0,w/h,0.1,100.0)

	glMatrixMode(GL_MODELVIEW)

	glColor3f(1.0,0,0)
end

# prepare Julia equivalents of C callbacks that are typically used in GLUT code

function ReSizeGLScene(w::Int32,h::Int32)
	if h == 0
		h = 1
	end

	glViewport(0,0,w,h)

	glMatrixMode(GL_PROJECTION)
	glLoadIdentity()

	gluPerspective(45.0,w/h,0.1,100.0)

	glMatrixMode(GL_MODELVIEW)
	 
	return nothing
end

_ReSizeGLScene = cfunction(ReSizeGLScene, Void, (Int32, Int32))

function DrawGLScene()
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
	glLoadIdentity()

	glTranslate(0.0, 0.0, -12.0)

	glRotate(sto.xrot,1.0,0.0,0.0)
	glRotate(sto.yrot,0.0,1.0,0.0)
	glRotate(sto.zrot,0.0,0.0,1.0)
#=
	mag(1.0,[0.5,0,0])
	glPushMatrix()
		glTranslate(1.0,0,0)
		mag(3.0,[0,0.5,0],0.3)
		glRotate(180.0,1.0,1.0,0.0)
		mag(1.0,[0.66,0,0.66],0.3)
	glPopMatrix()
=#
	setroom()
	l=sto.rlen
	q=sto.qlen
	glPushMatrix()
		sf=-l*q/2
		glTranslate(sf,sf,sf)
		for x=1:l
			for y=1:l
				for z=1:l
					#if z%2==1
						glPushMatrix()
							glTranslate(x*q,y*q,z*q)
							mag(real(sto.rval[x,y,z]),[0.66,0,0],q/1.5)
							glRotate(180.0,1.0,1.0,0.0)
							mag(imag(sto.rval[x,y,z]),[0,0,0.66],q/1.5)
						glPopMatrix()
					#end
				end
			end
		end
	glPopMatrix()
#=
	glBegin(GL_QUADS)
		for x=1:44
			for y=1:44
				tex_x	= x/45
				tex_y	= y/45
				tex_xb = (x+1)/45
				tex_yb = (y+1)/45

				glVertex(sto.points[x,y,1],sto.points[x,y,2],sto.points[x,y,3])
				glVertex(sto.points[x,y+1,1],sto.points[x,y+1,2],sto.points[x,y+1,3])
				glVertex(sto.points[x+1,y+1,1],sto.points[x+1,y+1,2],sto.points[x+1,y+1,3])
				glVertex(sto.points[x+1,y,1],sto.points[x+1,y,2],sto.points[x+1,y,3])
			end
		end
	glEnd()
=#

setpoints()

	glutSwapBuffers()
	 
	return nothing
end
 
_DrawGLScene = cfunction(DrawGLScene, Void, ())

function keyPressed(the_key::Char,x::Int32,y::Int32)
	if the_key == int('q')
		glutDestroyWindow(window)
	elseif the_key==int('T')
		sto.t+=1
	elseif the_key==int('t')
		sto.t-=1
	elseif the_key==int('K')
		sto.k+=1
	elseif the_key==int('k')
		sto.k-=1
	elseif the_key==int('A')
		sto.A+=0.1
	elseif the_key==int('a')
		sto.A-=0.1
	end

	return nothing # keyPressed returns "void" in C. this is a workaround for Julia's "automatically return the value of the last expression in a function" behavior.
end

_keyPressed = cfunction(keyPressed, Void, (Char, Int32, Int32))

function specialKeyPressed(the_key::Int32,x::Int32,y::Int32)
#	global xrot
#	global yrot

	if the_key == GLUT_KEY_UP
		sto.xrot -=1.5
	elseif the_key == GLUT_KEY_DOWN
		sto.xrot +=1.5
	elseif the_key == GLUT_KEY_LEFT
		sto.zrot -=1.5
	elseif the_key == GLUT_KEY_RIGHT
		sto.zrot +=1.5
	end

	return nothing # specialKeyPressed returns "void" in C-GLUT. this is a workaround for Julia's "automatically return the value of the last expression in a function" behavior.
end

_specialKeyPressed = cfunction(specialKeyPressed, Void, (Int32, Int32, Int32))

# run GLUT routines

glutInit()
glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_ALPHA | GLUT_DEPTH)
glutInitWindowSize(width, height)
glutInitWindowPosition(0, 0)

window = glutCreateWindow("Waves")

glutDisplayFunc(_DrawGLScene)
#glutFullScreen()

glutIdleFunc(_DrawGLScene)
glutReshapeFunc(_ReSizeGLScene)
glutKeyboardFunc(_keyPressed)
glutSpecialFunc(_specialKeyPressed)

initGL(width, height)

glutMainLoop()
