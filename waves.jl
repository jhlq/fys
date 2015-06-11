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
end
sto=Storage(1.0,0,1.0,1,Array(Float64,(45,45,3)),x->0,15,0,0)
sto.psi=(x,y)->sto.A*exp(im*(sto.k*(x+y)-sto.E*sto.t/10))

#global points = Array(Float64,(45,45,3))

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

# load necessary GLUT/OpenGL routines

global OpenGLver="1.0"
using OpenGL
using GLUT

# initialize variables

global window

global xrot = 0
global yrot = 0

global box  = 0
global top  = 0

boxcol	  = [1.0 0.0 0.0;
			   1.0 0.5 0.0;
			   1.0 1.0 0.0;
			   0.0 1.0 0.0;
			   0.0 1.0 1.0]

topcol	  = [0.5 0.0  0.0;
			   0.5 0.25 0.0;
			   0.5 0.5  0.0;
			   0.0 0.5  0.0;
			   0.0 0.5  0.5]

global tex  = Array(Uint32,1) # generating 1 texture

width	   = 640
height	  = 480

# load textures from images

function LoadGLTextures()
	global tex

	img, w, h = glimread(expanduser("~/.julia/GLUT/Examples/NeHe/tut12/cube.bmp"))

	glGenTextures(1,tex)
	glBindTexture(GL_TEXTURE_2D,tex[1])
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_NEAREST)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
	glTexImage2D(GL_TEXTURE_2D, 0, 3, w, h, 0, GL_RGB, GL_UNSIGNED_BYTE, img)
	gluBuild2DMipmaps(GL_TEXTURE_2D, 3, w, h, GL_RGB, GL_UNSIGNED_BYTE, img)
end

# function to init OpenGL context
function initGL(w::Integer,h::Integer)
    glViewport(0,0,w,h)
#    LoadGLTextures()
    glClearColor(0.0, 0.0, 0.0, 0.0)
    glClearDepth(1.0)			 
    glDepthFunc(GL_LEQUAL)	 
    glEnable(GL_DEPTH_TEST)
    glShadeModel(GL_SMOOTH)
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)

    # enable Polygon filling

    glPolygonMode(GL_BACK, GL_FILL)
    glPolygonMode(GL_FRONT, GL_LINE)

    # enable texture mapping
    glEnable(GL_TEXTURE_2D)

    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()

    gluPerspective(45.0,w/h,0.1,100.0)

    glMatrixMode(GL_MODELVIEW)
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
#=
    global tex
    global xrot
    global yrot
    global zrot
    global points
    global wiggle_count
=#
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glLoadIdentity()

    glTranslate(0.0, 0.0, -12.0)

    glRotate(sto.xrot,1.0,0.0,0.0)
    glRotate(sto.yrot,0.0,1.0,0.0)
    glRotate(sto.zrot,0.0,0.0,1.0)

#    glBindTexture(GL_TEXTURE_2D,tex[1])

    glBegin(GL_QUADS)
        for x=1:44
            for y=1:44
                tex_x  = x/45
                tex_y  = y/45
                tex_xb = (x+1)/45
                tex_yb = (y+1)/45

#                glTexCoord(tex_x, tex_y)
                glVertex(sto.points[x,y,1],sto.points[x,y,2],sto.points[x,y,3])
 #               glTexCoord(tex_x, tex_yb)
                glVertex(sto.points[x,y+1,1],sto.points[x,y+1,2],sto.points[x,y+1,3])
  #              glTexCoord(tex_xb, tex_yb)
                glVertex(sto.points[x+1,y+1,1],sto.points[x+1,y+1,2],sto.points[x+1,y+1,3])
   #             glTexCoord(tex_xb, tex_y)
                glVertex(sto.points[x+1,y,1],sto.points[x+1,y,2],sto.points[x+1,y,3])
            end
        end
    glEnd()

setpoints()

#=    if wiggle_count == 2
        for y=1:45
		
            hold = points[1,y,3]
            for x=1:44
		#holdx = points[x,1,3]
                points[x,y,3] = points[x+1,y,3]
		#points[x,45,3] = holdx
            end
		
            points[45,y,3] = hold
        end
#=#
        wiggle_count = 0
    end

    wiggle_count +=1

    xrot +=0.3
    yrot +=0.2
    zrot +=0.4
=#
    glutSwapBuffers()
   
    return nothing
end
#=
function DrawGLScene()
	global tex
	global xrot
	global yrot
	global box
	global top

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

	glBindTexture(GL_TEXTURE_2D, tex[1])

	for yloop = 1:5
		  for xloop = 1:yloop
			glLoadIdentity()

			glTranslate(1.4+2.8xloop-1.4yloop, ((6.0-yloop)*2.4)-7.0, -20.0)

			glRotate(45.0-(2.0yloop)+xrot, 1.0, 0.0, 0.0)
			glRotate(45.0+yrot, 0.0, 1.0, 0.0)

			glColor(boxcol[yloop,:])
			glCallList(box)
			
			glColor(topcol[yloop,:])
			glCallList(top)
		end
	end

	glutSwapBuffers()
   
	return nothing
end
=#
   
_DrawGLScene = cfunction(DrawGLScene, Void, ())

function keyPressed(the_key::Char,x::Int32,y::Int32)
	if the_key == int('q')
		glutDestroyWindow(window)
	elseif the_key==int('T')
		sto.t+=1
	elseif the_key==int('K')
		sto.k+=1
	elseif the_key==int('k')
		sto.k-=1
	end

	return nothing # keyPressed returns "void" in C. this is a workaround for Julia's "automatically return the value of the last expression in a function" behavior.
end

_keyPressed = cfunction(keyPressed, Void, (Char, Int32, Int32))

function specialKeyPressed(the_key::Int32,x::Int32,y::Int32)
#	global xrot
#	global yrot

	if the_key == GLUT_KEY_UP
		sto.xrot -=0.5
	elseif the_key == GLUT_KEY_DOWN
		sto.xrot +=0.5
	elseif the_key == GLUT_KEY_LEFT
		sto.zrot -=0.5
	elseif the_key == GLUT_KEY_RIGHT
		sto.zrot +=0.5
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
