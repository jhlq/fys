type Storage
	A::Number
	t::Number
	E::Number
	k::Number
	xrot::Number
	yrot::Number
	zrot::Number

	rlen::Int64
	qlen::Float64
	room::Array{Float64,3}
	rval::Array{Complex,3}
	psi3d::Function
end
sto=Storage(0.3,0,1.0,1,0,0,0,0,0.0,Array(Float64,1,1,1),Array(Complex,1,1,1),x->0)

sto.rlen=18
sto.qlen=0.5
sto.room=Array(Float64,sto.rlen,sto.rlen,sto.rlen)
sto.rval=Array(Complex,sto.rlen,sto.rlen,sto.rlen)

m=1.11
using Calculus
function p̂(psi::Function)
	x->-im*hbarn*psi'(x)
end
function â(psi::Function,omega=1,par=-1)
	x->sqrt(m*omega/2hbarn)*x*psi(x)-im*p̂(psi)(x)/sqrt(2*m*omega)
end

hbarn=1.0546
om1=1
om2=1
om3=2

#d=sqrt(hbarn/(m*om))
d=3
p3dgs=(x1,x2,x3)->sqrt(2)/(pi^(3/4)*d^(3/2))*exp(-(x1^2+x2^2+4*x3^2)/2d^2)
p01=x->(m*om1/(pi*hbarn))^(1/4)*exp(-m*om1/(2*hbarn*d)*(x)^2)
p11=x->real(â(p01,om1)(x))
p02=x->(m*om2/(pi*hbarn))^(1/4)*exp(-m*om2/(2*hbarn*d)*(x)^2)
p12=x->real(â(p02,om2)(x))
p03=x->(m*om3/(pi*hbarn))^(1/4)*exp(-m*om3/(2*hbarn*d)*(x)^2)
p13=x->real(â(p03,om3)(x))
p3du=(x1,x2,x3)->sto.A*p01(x1)*p02(x2)*p03(x3)
p3du1a=(x1,x2,x3)->sto.A*p11(x1)*p02(x2)*p03(x3) #odd
p3du1b=(x1,x2,x3)->sto.A*p01(x1)*p02(x2)*p13(x3)
p3du2a=(x1,x2,x3)->sto.A*p11(x1)*p02(x2)*p13(x3) #even
p3du2b=(x1,x2,x3)->sto.A*p11(x1)*p12(x2)*p03(x3) #even
p3du3a=(x1,x2,x3)->sto.A*â(p01)(x1)*â(p02)(x2)*â(â(p03))(x3)

sto.psi3d=p3du3a

#(x,y,z)->sto.A*exp(im*(sto.k*(x+y+z)-sto.E*sto.t/10))

function setroom()
	l=sto.rlen
	s=9.000001
	for x=1:l
		for y=1:l
			for z=1:l
				sto.rval[x,y,z]=sto.psi3d(x-s,y-s,z-s)
			end
		end
	end
end
setroom()

function mag(nitude::Float64)
	c=[0.0,1.0,0.0]
	if nitude<0
		c[1]=1.0
		c[2]=0.0
		glColor3f(1.0,0.0,0.0)
		nitude=abs(nitude)
	end
	if nitude>1
		nitude=1
		c[3]=1.0
	end
	glColor3f(c[1],c[2],c[3])

	glBegin(GL_POLYGON)
		glVertex(0.0,0.0,0.0)
		glVertex(0.0,nitude,0.0)
		glVertex(nitude,nitude*0.5,0.0)
	glEnd()
	glBegin(GL_POLYGON)
		glVertex(0.0,0.0,0.0)
		glVertex(0.0,nitude,0.0)
		glVertex(nitude*0.5,nitude*0.5,nitude)
	glEnd()
	glBegin(GL_POLYGON)
		glVertex(0.0,nitude,0.0)
		glVertex(nitude,nitude/2,0.0)
		glVertex(nitude*0.5,nitude*0.5,nitude)
	glEnd()
end

# load necessary GLUT/OpenGL routines

global OpenGLver="1.0"
using OpenGL
using GLUT

# initialize variables

global window

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

	setroom()
	l=sto.rlen
	q=sto.qlen
	glPushMatrix()
		sf=-l*q/2
		glTranslate(sf,sf,sf)
		for x=1:l
			for y=1:l
				for z=1:l
					glPushMatrix()
						glTranslate(x*q,y*q,z*q)
						#glRotate(-90.0,0.0,0.0,1.0)
						mag(real(sto.rval[x,y,z]))
					glPopMatrix()
				end
			end
		end
	glPopMatrix()
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

	return nothing 
end

_keyPressed = cfunction(keyPressed, Void, (Char, Int32, Int32))

function specialKeyPressed(the_key::Int32,x::Int32,y::Int32)
	if the_key == GLUT_KEY_UP
		sto.xrot -=1.5
	elseif the_key == GLUT_KEY_DOWN
		sto.xrot +=1.5
	elseif the_key == GLUT_KEY_LEFT
		sto.zrot -=1.5
	elseif the_key == GLUT_KEY_RIGHT
		sto.zrot +=1.5
	end

	return nothing 
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
