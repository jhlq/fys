//g++ sfrac3.cc -o sfrac3 `pkg-config gtkglextmm-1.2 gtkmm-3.0 --cflags --libs` -lGL -lGLU -std=c++0x

#include <ctime>
#include <iostream>
#include <cstdlib>
#include <vector>
#include <complex>
#include <fstream>
#include <string>

#include <gtkmm.h>

#include <gtkglmm.h>

#include <GL/gl.h>
#include <GL/glu.h>

typedef struct {
	int width;
	int height;
	uint8_t *data;
	size_t size;
} ppm_image;

size_t ppm_save(ppm_image *img, FILE *outfile) {
    size_t n = 0;
    n += fprintf(outfile, "P6\n# THIS IS A COMMENT\n%d %d\n%d\n", 
                 img->width, img->height, 0xFF);
    n += fwrite(img->data, 1, img->width * img->height * 3, outfile);
    return n;
}

struct stuff{
	int rez;
	int numlayers;
	int numzlayers;
	int maxiter;
	int curit;
	int curclick;
	int numclicks;
	double radius;
	bool save;
	double deg;
	
    std::vector<std::vector<std::vector<std::complex<double> > > > field3;
    std::vector<std::vector<std::vector<double>  > > field3d;
    std::vector<std::vector<std::vector<std::complex<double> > > > field30;
    std::vector<std::vector<std::vector<double>  > > field3d0;
    std::vector<std::vector<std::vector<int > > > fielditer3;
};

stuff chest;

void initchest(){
	chest.numclicks=360;
	chest.deg=360.0/(chest.numclicks*3);
	chest.save=false;
	chest.curclick=0;
	chest.rez=25;
	chest.numlayers=chest.rez*3;
	chest.numzlayers=chest.numlayers*3;
	chest.maxiter=5;//rez/10;
	chest.curit=0;
	chest.radius=1.0/chest.rez;
	for (int dl=0;dl<chest.numzlayers;++dl){
		chest.field3.push_back(*(new std::vector<std::vector<std::complex<double> > >));
		chest.field30.push_back(*(new std::vector<std::vector<std::complex<double> > >));
		chest.field3d.push_back(*(new std::vector<std::vector<double > >));
		chest.field3d0.push_back(*(new std::vector<std::vector<double > >));
		chest.fielditer3.push_back(*(new std::vector<std::vector<int> >));
		for (int hl=0;hl<chest.numlayers;++hl){
			chest.field3[dl].push_back(*(new std::vector<std::complex<double> >));
			chest.field30[dl].push_back(*(new std::vector<std::complex<double> >));
			chest.field3d[dl].push_back(*(new std::vector<double>));
			chest.field3d0[dl].push_back(*(new std::vector<double>));
			chest.fielditer3[dl].push_back(*(new std::vector<int>));
			for (int vl=0;vl<chest.numlayers;++vl){
				double rp=-6+12*(double)vl/chest.numlayers;
				double ip=6-12*(double)hl/chest.numlayers;
				double rp2=3*(double)dl/chest.numzlayers;
				std::complex<double> cloc(rp,ip);
				chest.field3[dl][hl].push_back(cloc);
				chest.field30[dl][hl].push_back(cloc);
				chest.field3d[dl][hl].push_back(rp2);
				chest.field3d0[dl][hl].push_back(rp2);
				chest.fielditer3[dl][hl].push_back(0);
			}
		}
	}
}

void cube(Glib::RefPtr<Gdk::GL::Drawable>& gldrawable){
	//gldrawable->draw_cube(true,1.5);
	for (int dl=0;dl<chest.numzlayers;++dl){
		for (int hl=0;hl<chest.numlayers;++hl){
			for (int vl=0;vl<chest.numlayers;++vl){
				if (chest.fielditer3[dl][hl][vl]>-1){	
					std::complex<double> c0(0,3*chest.field3d0[dl][hl][vl]);
					std::complex<double> c1(0,3*chest.field3d[dl][hl][vl]);
					chest.field3[dl][hl][vl]=pow(pow(chest.field3[dl][hl][vl],2)+chest.field30[dl][hl][vl]+pow(c1,2)+c0,-1);
					chest.field3d[dl][hl][vl]=pow(chest.field3d[dl][hl][vl],2)+chest.field3d0[dl][hl][vl];
					++chest.fielditer3[dl][hl][vl];
					//if(hl==rez){std::cout<<"tr:"<<field3[hl][vl]<<" ";}
					if (abs(chest.field3[dl][hl][vl]+chest.field3[dl][hl][vl])>3){
						glPushMatrix();
							glTranslatef(2*chest.radius*vl, 0.0, 0.0);
							
							glTranslatef(0.0, 2*chest.radius*hl, 0.0);
							
							glTranslatef(0.0, 0.0, 2*chest.radius*dl);
							glColor3f(1.0f-((double)chest.fielditer3[dl][hl][vl]/chest.maxiter)*1.0f,((double)dl/chest.numzlayers)*0.0f,1.0f);

							gldrawable->draw_cube(true,2*chest.radius);
						glPopMatrix();
						chest.fielditer3[dl][hl][vl]=-chest.fielditer3[dl][hl][vl];
					}
				}
			}
		}
	}
}



//
// Simple OpenGL scene.
//

class FracScene : public Gtk::GL::DrawingArea
{
public:
  FracScene(const Glib::RefPtr<const Gdk::GL::Config>& config);
  virtual ~FracScene();

//protected:
  virtual void on_realize();
  virtual bool on_configure_event(GdkEventConfigure* event);
  virtual bool on_expose_event(GdkEventExpose* event);

};

FracScene::FracScene(const Glib::RefPtr<const Gdk::GL::Config>& config)
  : Gtk::GL::DrawingArea(config)
{
}

FracScene::~FracScene()
{
}

void FracScene::on_realize()
{
  // We need to call the base on_realize()
  Gtk::GL::DrawingArea::on_realize();

  //
  // Get GL::Window.
  //

  Glib::RefPtr<Gdk::GL::Window> glwindow = get_gl_window();

  //
  // GL calls.
  //

  // *** OpenGL BEGIN ***
  if (!glwindow->gl_begin(get_gl_context()))
    return;
    
    


GLuint index = glGenLists(1);

// compile the display list, store a triangle in it
glNewList(index, GL_COMPILE);
    /*glBegin(GL_TRIANGLES);
    glVertex3fv(0.0);
    glVertex3fv(1.0);
    glVertex3fv(2.0);
    glEnd();*/
    Glib::RefPtr<Gdk::GL::Drawable> gldrawable = get_gl_drawable();
    glPushMatrix();
		glTranslatef(-2.5,-1.5,0.0);

		for (int i=0;i<chest.maxiter;++i){
			cube(gldrawable);
			std::cout<<i;
		}
	glPopMatrix();	
glEndList();

  static GLfloat light_diffuse[] = {1.0, 1.0, 1.0, .50};
  static GLfloat light_position[] = {1.0, 0.0, 0.50, 0.0};
  glLightfv(GL_LIGHT0, GL_DIFFUSE, light_diffuse);
  glLightfv(GL_LIGHT0, GL_POSITION, light_position);
	//glShadeModel( GL_SMOOTH );
	glEnable(GL_COLOR_MATERIAL);
  glEnable(GL_LIGHTING);
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	//glEnable( GL_BLEND );
  glEnable(GL_LIGHT0);
  glEnable(GL_DEPTH_TEST);

  glClearColor(.0, .0, .0, .0);
  glClearDepth(1.0);

  glViewport(0, 0, get_width(), get_height());

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(40.0, 1.0, 0.1, 100);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  gluLookAt(0.0, 0.0, 9.0,
            0.0, 0.0, 0.0,
            0.0, 1.0, 0.0);
  glTranslatef(0.0, 0.0, -9.0);
  

  glwindow->gl_end();
  // *** OpenGL END ***
}

bool FracScene::on_configure_event(GdkEventConfigure* event)
{
  //
  // Get GL::Window.
  //

  Glib::RefPtr<Gdk::GL::Window> glwindow = get_gl_window();

  //
  // GL calls.
  //

  // *** OpenGL BEGIN ***
  if (!glwindow->gl_begin(get_gl_context()))
    return false;

  glViewport(0, 0, get_width(), get_height());

  glwindow->gl_end();
  // *** OpenGL END ***
  

  return true;
}

bool FracScene::on_expose_event(GdkEventExpose* event)
{
  //
  // Get GL::Window.
  //

  Glib::RefPtr<Gdk::GL::Window> glwindow = get_gl_window();

  //
  // GL calls.
  //

  // *** OpenGL BEGIN ***
  if (!glwindow->gl_begin(get_gl_context()))
    return false;

  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  glCallList(1);


  // Swap buffers.
  if (glwindow->is_double_buffered())
    glwindow->swap_buffers();
  else
    glFlush();

  glwindow->gl_end();
  // *** OpenGL END ***

  return true;
}


//
// The application class.
//

class Simple : public Gtk::Window
{
public:
  Simple(const Glib::RefPtr<const Gdk::GL::Config>& config);
  virtual ~Simple();

protected:
  // signal handlers:
  void on_button_click_clicked();

protected:
  // member widgets:
  Gtk::VBox m_VBox;
  FracScene m_FracScene;
  Gtk::Button m_ButtonClick;
};

Simple::Simple(const Glib::RefPtr<const Gdk::GL::Config>& config)
  : m_VBox(false, 0), m_FracScene(config), m_ButtonClick("Click")
{
  //
  // Top-level window.
  //

  set_title("Gtk::GL::Frac");

  // Get automatically redrawn if any of their children changed allocation.
  set_reallocate_redraws(true);

  add(m_VBox);

  //
  // Simple OpenGL scene.
  //

  m_FracScene.set_size_request(500, 500);

  m_VBox.pack_start(m_FracScene);

  //
  // Simple quit button.
  //

  m_ButtonClick.signal_clicked().connect(
    sigc::mem_fun(*this, &Simple::on_button_click_clicked));

  m_VBox.pack_start(m_ButtonClick, Gtk::PACK_SHRINK, 0);

  //
  // Show window.
  //

  show_all();
}

Simple::~Simple()
{}

void Simple::on_button_click_clicked()
{
	time_t begin;
	time(&begin);
	for (int click=0;click<chest.numclicks;++click){
		++chest.curclick;
		//glPushMatrix();
		//glTranslatef(0.,0.,9.0);
		
		glLoadIdentity();
		gluLookAt(0.0, 0.0, 9.0, 0.0, 0.0, 0.0,  0.0, 1.0, 0.0);
		glTranslatef(0.,0.,-9.0);
		glRotatef(chest.deg*chest.curclick,-0.7,0.0,0.30);
		
		//glPopMatrix();
		//glMatrixMode(GL_PROJECTION);
		//glLoadIdentity();
		//gluPerspective(40.0, 1.0, 0.1, 100);

		//glMatrixMode(GL_MODELVIEW);
  //glLoadIdentity();
		//gluLookAt(27.0, 18.0, 9.0, 0.0, 0.0, 0.0,  0.0, 1.0, 0.0);
		//glTranslatef(0.,0.,-9.0);
		//glTranslatef(-2.5,-1.5,-9.0);
		m_FracScene.on_expose_event((GdkEventExpose*)1);
		if (chest.save){
			int h=m_FracScene.get_height();
			int w=m_FracScene.get_width();
			
			//std::cout<<w<<h<<std::endl;

			unsigned char pixels[3 * w * h];
			
			glPixelStorei(GL_PACK_ALIGNMENT,1);
			
			glReadBuffer(GL_BACK_LEFT);
			glReadPixels(0, 0, w, h, GL_RGB, GL_UNSIGNED_BYTE, &pixels);
			std::string s1=std::to_string(chest.curclick+100);
			s1=s1+".ppm";
			FILE* fptr = fopen(s1.c_str(),"w");
			ppm_image im={w,h,(uint8_t*)&pixels,sizeof(pixels)};
			ppm_save(&im,fptr);
			fclose(fptr);
		}
	}
  //Gtk::Main::quit();
  
	time_t end;
	time(&end);
	std::cout<<" total time:"<<end-begin;
	std::cout<<" Angle:"<<chest.deg*chest.curclick<<" ";
}


//
// Main.
//

int main(int argc, char** argv)
{

	
  Gtk::Main kit(argc, argv);
	initchest();
	//std::cout<<chest.rez;
  //
  // Init gtkglextmm.
  //

  Gtk::GL::init(argc, argv);

  //
  // Query OpenGL extension version.
  //

  int major, minor;
  Gdk::GL::query_version(major, minor);
  std::cout << "OpenGL extension version - "
            << major << "." << minor << std::endl;

  //
  // Configure OpenGL-capable visual.
  //

  Glib::RefPtr<Gdk::GL::Config> glconfig;

  // Try double-buffered visual
  glconfig = Gdk::GL::Config::create(Gdk::GL::MODE_RGB    |
                                     Gdk::GL::MODE_DEPTH  |
                                     Gdk::GL::MODE_DOUBLE);
  if (!glconfig)
    {
      std::cerr << "*** Cannot find the double-buffered visual.\n"
                << "*** Trying single-buffered visual.\n";

      // Try single-buffered visual
      glconfig = Gdk::GL::Config::create(Gdk::GL::MODE_RGB   |
                                         Gdk::GL::MODE_DEPTH);
      if (!glconfig)
        {
          std::cerr << "*** Cannot find any OpenGL-capable visual.\n";
          std::exit(1);
        }
    }

  //
  // Instantiate and run the application.
  //

  Simple simple(glconfig);

  kit.run(simple);
  
	

  return 0;
}
