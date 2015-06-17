//gcc trackball.c -c
//g++ frac3.cc trackball.o -o frac3 `pkg-config gtkglextmm-1.2 gtkmm-3.0 --cflags --libs` -lGL -lGLU -std=c++0x
//model spec is at line 432

#include <cmath>
#include <GL/gl.h>
#include <GL/glu.h>

#include <gtkmm.h>
#include <gtkglmm.h>

#include <iostream> 
#include <fstream>
#include <vector>
#include <complex>

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


namespace Shapes
{

  class Scene;

  //
  // View class.
  //

  class View : public sigc::trackable
  {
    friend class Scene;

  public:
    static const float NEAR_CLIP;
    static const float FAR_CLIP;

    static const float INIT_POS_X;
    static const float INIT_POS_Y;
    static const float INIT_POS_Z;

    static const float INIT_AXIS_X;
    static const float INIT_AXIS_Y;
    static const float INIT_AXIS_Z;
    static const float INIT_ANGLE;

    static const float INIT_SCALE;

    static const float SCALE_MAX;
    static const float SCALE_MIN;

    static const float ANIMATE_THRESHOLD;

  public:
    View();
    virtual ~View();

  public:
    void frustum(int w, int h);

    void xform();

    void reset();

    void set_pos(float x, float y, float z)
    { m_Pos[0] = x; m_Pos[1] = y; m_Pos[2] = z; }

    void set_quat(float q0, float q1, float q2, float q3)
    { m_Quat[0] = q0; m_Quat[1] = q1; m_Quat[2] = q2; m_Quat[3] = q3; }

    void set_scale(float scale)
    { m_Scale = scale; }

    void enable_animation();

    void disable_animation();

    bool is_animate() const
    { return m_Animate; }

  protected:
    // Signal handlers:
    virtual bool on_button_press_event(GdkEventButton* event, Scene* scene);
    virtual bool on_button_release_event(GdkEventButton* event, Scene* scene);
    virtual bool on_motion_notify_event(GdkEventMotion* event, Scene* scene);

  private:
    float m_Pos[3];
    float m_Quat[4];
    float m_Scale;

    float m_QuatDiff[4];
    float m_BeginX;
    float m_BeginY;
    float m_DX;
    float m_DY;

    bool m_Animate;

  };
  
  class Model
  {
    friend class Scene;

  public:
  Model();
    virtual ~Model();
    void square(double,int,Glib::RefPtr<Gdk::GL::Drawable>& gldrawable);
    void cube(Glib::RefPtr<Gdk::GL::Drawable>& gldrawable);
    std::vector<std::vector<std::complex<double> > > field;
    std::vector<std::vector<std::complex<double> > > field0;
    std::vector<std::vector<int > > fielditer;
    std::vector<std::vector<std::vector<std::complex<double> > > > field3;
    std::vector<std::vector<std::vector<double>  > > field3d;
    std::vector<std::vector<std::vector<std::complex<double> > > > field30;
    std::vector<std::vector<std::vector<double>  > > field3d0;
    std::vector<std::vector<std::vector<int > > > fielditer3;
    double rez;
    int numlayers;
    int num3layers;
    int maxiter;
    int curit;
    double radius;

  private:
    void init_gl(Glib::RefPtr<Gdk::GL::Drawable>& gldrawable);

  public:
    void draw(Glib::RefPtr<Gdk::GL::Drawable>& gldrawable);

    private:
    unsigned int m_ListBase;
    
	};


class Scene : public Gtk::GL::DrawingArea
  {
    friend class View;
    friend class Model;

  public:
    // OpenGL scene related constants:
    static const float CLEAR_COLOR[4];
    static const float CLEAR_DEPTH;

    static const float LIGHT0_POSITION[4];
    static const float LIGHT0_AMBIENT[4];
    static const float LIGHT0_DIFFUSE[4];

    static const float LIGHT_MODEL_AMBIENT[4];
    static const float LIGHT_MODEL_LOCAL_VIEWER[1];

  public:
    explicit Scene();
    virtual ~Scene();

  protected:
    // signal handlers:
    virtual void on_realize();
    virtual bool on_configure_event(GdkEventConfigure* event);
    virtual bool on_expose_event(GdkEventExpose* event);
    virtual bool on_button_press_event(GdkEventButton* event);
    virtual bool on_unmap_event(GdkEventAny* event);
    virtual bool on_visibility_notify_event(GdkEventVisibility* event);
    virtual bool on_idle();

  public:
    // Invalidate whole window.
    void invalidate() {
      get_window()->invalidate_rect(get_allocation(), false);
    }

    // Update window synchronously (fast).
    void update()
    { get_window()->process_updates(false); }

  protected:
    // idle signal connection:
    sigc::connection m_ConnectionIdle;

    void idle_add();
    void idle_remove();
    
    
    protected:
    // OpenGL scene related objects:
    View m_View;
    Model m_Model;

  };
  
  class Application : public Gtk::Window
  {
  public:
    static const Glib::ustring APP_NAME;

  public:
    Application();
    virtual ~Application();

  protected:
    // signal handlers:
    virtual void on_button_quit_clicked();
	virtual void on_button_click_clicked();
    virtual bool on_key_press_event(GdkEventKey* event);

  protected:
    // member widgets:
    Gtk::VBox m_VBox;
    Scene m_Scene;
    Gtk::Button m_ButtonQuit;
    Gtk::Button m_ButtonClick;
  };

} // namespace Shapes

namespace Trackball {
  extern "C" {
    #include "trackball.h"
  }
}

#define DIG_2_RAD (G_PI / 180.0)
#define RAD_2_DIG (180.0 / G_PI)

namespace Shapes
{

  //
  // View class implementation.
  //

  const float View::NEAR_CLIP   = 5.0;
  const float View::FAR_CLIP    = 60.0;

  const float View::INIT_POS_X  = 0.0;
  const float View::INIT_POS_Y  = 0.0;
  const float View::INIT_POS_Z  = -10.0;

  const float View::INIT_AXIS_X = 1.0;
  const float View::INIT_AXIS_Y = 0.0;
  const float View::INIT_AXIS_Z = 0.0;
  const float View::INIT_ANGLE  = 0.0;

  const float View::INIT_SCALE  = 1.0;

  const float View::SCALE_MAX   = 300.0;
  const float View::SCALE_MIN   = 0.05;

  const float View::ANIMATE_THRESHOLD = 1.0;

  View::View()
    : m_Scale(INIT_SCALE),
      m_BeginX(0.0), m_BeginY(0.0),
      m_DX(0.0), m_DY(0.0),
      m_Animate(false)
  {
    reset();
  }

  View::~View()
  {
  }

  void View::frustum(int w, int h)
  {
    glViewport(0, 0, w, h);

    glMatrixMode(GL_PROJECTION);
//    glPushMatrix();
    glLoadIdentity();
    

    if (w > h) {
      float aspect = static_cast<float>(w) / static_cast<float>(h);
      glFrustum(-aspect, aspect, -1.0, 1.0, NEAR_CLIP, FAR_CLIP);
    } else {
      float aspect = static_cast<float>(h) / static_cast<float>(w);
      glFrustum(-1.0, 1.0, -aspect, aspect, NEAR_CLIP, FAR_CLIP);
    }
//	glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
  }

  void View::xform()
  {
    glTranslatef(m_Pos[0], m_Pos[1], m_Pos[2]);

    glScalef(m_Scale, m_Scale, m_Scale);

    float m[4][4];
    Trackball::add_quats(m_QuatDiff, m_Quat, m_Quat);
    Trackball::build_rotmatrix(m, m_Quat);
    glMultMatrixf(&m[0][0]);
  }

  void View::reset()
  {
    m_Pos[0] = INIT_POS_X;
    m_Pos[1] = INIT_POS_Y;
    m_Pos[2] = INIT_POS_Z;

    float sine = sin(0.5 * INIT_ANGLE * DIG_2_RAD);
    m_Quat[0] = INIT_AXIS_X * sine;
    m_Quat[1] = INIT_AXIS_Y * sine;
    m_Quat[2] = INIT_AXIS_Z * sine;
    m_Quat[3] = cos(0.5 * INIT_ANGLE * DIG_2_RAD);

    m_Scale = INIT_SCALE;

    m_QuatDiff[0] = 0.0;
    m_QuatDiff[1] = 0.0;
    m_QuatDiff[2] = 0.0;
    m_QuatDiff[3] = 1.0;
  }

  void View::enable_animation()
  {
    m_Animate = true;
  }

  void View::disable_animation()
  {
    m_Animate = false;

    m_QuatDiff[0] = 0.0;
    m_QuatDiff[1] = 0.0;
    m_QuatDiff[2] = 0.0;
    m_QuatDiff[3] = 1.0;
  }

  bool View::on_button_press_event(GdkEventButton* event,
                                   Scene* scene)
  {
    if (is_animate()) {
      if (event->button == 1) {
        disable_animation();
        scene->idle_remove();
        scene->invalidate();
      }
    } else {
      m_QuatDiff[0] = 0.0;
      m_QuatDiff[1] = 0.0;
      m_QuatDiff[2] = 0.0;
      m_QuatDiff[3] = 1.0;
    }

    m_BeginX = event->x;
    m_BeginY = event->y;

    // don't block
    return false;
  }

  bool View::on_button_release_event(GdkEventButton* event,
                                     Scene* scene)
  {
    if (!is_animate()) {
      if (event->button == 1 &&
          ((m_DX*m_DX + m_DY*m_DY) > ANIMATE_THRESHOLD)) {
        enable_animation();
        scene->idle_add();
      }
    }

    m_DX = 0.0;
    m_DY = 0.0;

    // don't block
    return false;
  }

  bool View::on_motion_notify_event(GdkEventMotion* event,
                                    Scene* scene)
  {
    float w = scene->get_width();
    float h = scene->get_height();
    float x = event->x;
    float y = event->y;
    bool redraw = false;

    // Rotation.
    if (event->state & GDK_BUTTON1_MASK) {
      Trackball::trackball(m_QuatDiff,
                           (2.0 * m_BeginX - w) / w,
                           (h - 2.0 * m_BeginY) / h,
                           (2.0 * x - w) / w,
                           (h - 2.0 * y) / h);

      m_DX = x - m_BeginX;
      m_DY = y - m_BeginY;

      redraw = true;
    }

    // Scaling.
    if (event->state & GDK_BUTTON2_MASK) {
      m_Scale = m_Scale * (1.0 + (y - m_BeginY) / h);
      if (m_Scale > SCALE_MAX)
        m_Scale = SCALE_MAX;
      else if (m_Scale < SCALE_MIN)
        m_Scale = SCALE_MIN;

      redraw = true;
    }

    m_BeginX = x;
    m_BeginY = y;

    if (redraw)
      scene->invalidate();

    // don't block
    return false;
  }
  
	Model::Model(): m_ListBase(0){
		rez=25;
		numlayers=rez*2;
		num3layers=numlayers;
		maxiter=5;//rez/10;
		curit=0;
		radius=1/rez;
		for (int hl=0;hl<numlayers;++hl){
			field.push_back(*(new std::vector<std::complex<double> >));
			fielditer.push_back(*(new std::vector<int>));
			for (int vl=0;vl<numlayers;++vl){
				double rp=-1+2*(double)vl/numlayers;
				double ip=1-2*(double)hl/numlayers;
				std::complex<double> cloc(rp,ip);
				//if(hl==rez){std::cout<<"pre:"<<cloc<<" ";}
				field[hl].push_back(cloc);
				fielditer[hl].push_back(0);
			}
		}
		field0=field;
		for (int dl=0;dl<num3layers;++dl){
			field3.push_back(*(new std::vector<std::vector<std::complex<double> > >));
			field30.push_back(*(new std::vector<std::vector<std::complex<double> > >));
			field3d.push_back(*(new std::vector<std::vector<double > >));
			field3d0.push_back(*(new std::vector<std::vector<double > >));
			fielditer3.push_back(*(new std::vector<std::vector<int> >));
			for (int hl=0;hl<numlayers;++hl){
				field3[dl].push_back(*(new std::vector<std::complex<double> >));
				field30[dl].push_back(*(new std::vector<std::complex<double> >));
				field3d[dl].push_back(*(new std::vector<double>));
				field3d0[dl].push_back(*(new std::vector<double>));
				fielditer3[dl].push_back(*(new std::vector<int>));
				for (int vl=0;vl<numlayers;++vl){
					double rp=-2+4*(double)vl/numlayers;
					double ip=2-4*(double)hl/numlayers;
					double rp2=-2+4*(double)dl/num3layers;
					std::complex<double> cloc(rp,ip);
					field3[dl][hl].push_back(cloc);
					field30[dl][hl].push_back(cloc);
					field3d[dl][hl].push_back(rp2);
					field3d0[dl][hl].push_back(rp2);
					fielditer3[dl][hl].push_back(0);
				}
			}
		}
	}
	

  Model::~Model(){
  }
	void Model::square(double radius,int layers,Glib::RefPtr<Gdk::GL::Drawable>& gldrawable){

		for (int hl=0;hl<layers;++hl){
			for (int vl=0;vl<layers;++vl){
				if (fielditer[hl][vl]>-1){	
					field[hl][vl]=pow(field[hl][vl],2)+field0[hl][vl];
					++fielditer[hl][vl];
					if(hl==rez){std::cout<<"tr:"<<field[hl][vl]<<" ";}
					if (abs(field[hl][vl])>3){
						glPushMatrix();
							glTranslatef(2*radius*vl, 0.0, 0.0);
							glTranslatef(0.0, 2*radius*hl, 0.0);
							glColor3f(1.0f-((double)fielditer[hl][vl]/maxiter)*1.0f,((double)fielditer[hl][vl]/maxiter)*0.0f,1.0f);
							//gldrawable->draw_sphere(true, radius, 30, 30);
							glScalef(radius,radius,radius);
							gldrawable->draw_tetrahedron(true);
						glPopMatrix();
						fielditer[hl][vl]=-fielditer[hl][vl];
					}
				}
			}
		}
	}
	void Model::cube(Glib::RefPtr<Gdk::GL::Drawable>& gldrawable){
		for (int dl=0;dl<num3layers;++dl){
			for (int hl=0;hl<numlayers;++hl){
				for (int vl=0;vl<numlayers;++vl){
					if (fielditer3[dl][hl][vl]>-1){	
						std::complex<double> c0(0,3*field3d0[dl][hl][vl]);
						std::complex<double> c1(0,3*field3d[dl][hl][vl]);
						field3[dl][hl][vl]=pow(pow(field3[dl][hl][vl],2)+field30[dl][hl][vl]+pow(c1,2)+c0,-1);
						field3d[dl][hl][vl]=pow(field3d[dl][hl][vl],2)+field3d0[dl][hl][vl];
						++fielditer3[dl][hl][vl];
						//if(hl==rez){std::cout<<"tr:"<<field3[hl][vl]<<" ";}
						if (abs(field3[dl][hl][vl]+field3[dl][hl][vl])>3){
							glPushMatrix();
								glTranslatef(2*radius*vl, 0.0, 0.0);
								glTranslatef(0.0, 2*radius*hl, 0.0);
								glTranslatef(0.0, 0.0, 2*radius*dl);
								glColor3f(1.0f-((double)fielditer3[dl][hl][vl]/maxiter)*1.0f,((double)dl/num3layers)*0.0f,1.0f);
								//gldrawable->draw_sphere(true, radius, 30, 30);
								//glScalef(radius,radius,radius);
								//gldrawable->draw_tetrahedron(true);
								gldrawable->draw_cube(true,2*radius);
							glPopMatrix();
							fielditer3[dl][hl][vl]=-fielditer3[dl][hl][vl];
						}
					}
				}
			}
		}
	}
  void Model::init_gl(Glib::RefPtr<Gdk::GL::Drawable>& gldrawable){
	glEnable(GL_COLOR_MATERIAL);
	m_ListBase = glGenLists(1);
	//glLoadIdentity();
	//glMatrixMode(GL_PROJECTION);
	//glLoadIdentity();
	//gluPerspective (60.0, 1, 0.1, 100.0);
	//glMatrixMode(GL_MODELVIEW);
	//glLoadIdentity();
	
	glNewList(m_ListBase, GL_COMPILE);
		glPushMatrix();
			//glLoadIdentity();
			//glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			//glMatrixMode(GL_MODELVIEW); 
			glTranslatef(-1.5,-1.5,0.0);
			cube(gldrawable);
		glPopMatrix();	
	glEndList();
  }

  void Model::draw(Glib::RefPtr<Gdk::GL::Drawable>& gldrawable)
  {
    // Init GL context.
    static bool initialized = false;
    if (!initialized) {
      init_gl(gldrawable);
      initialized = true;
    }
	
    // Render shape
   /* glMaterialfv(GL_FRONT, GL_AMBIENT, m_CurrentMat->ambient);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, m_CurrentMat->diffuse);
    glMaterialfv(GL_FRONT, GL_SPECULAR, m_CurrentMat->specular);
    glMaterialf(GL_FRONT, GL_SHININESS, m_CurrentMat->shininess * 128.0);*/
    glPushMatrix();
    //gluPerspective (60.0, 1, 0.1, 100.0);
	//glMatrixMode(GL_MODELVIEW);
    //glLoadIdentity();
	//gluPerspective (60.0, 1, 0.1, 100.0);
    for (int i=0;i<=curit;++i){
		glCallList(m_ListBase+i);
	} 
	glPopMatrix();
    if (curit<maxiter){
		++curit;
		glNewList(m_ListBase+curit, GL_COMPILE);
			glPushMatrix();
				glTranslatef(-1.5,-1.5,0.0);
				//square(radius,numlayers,gldrawable);
				cube(gldrawable);
			glPopMatrix();	
		glEndList();
	}
    /*glPushMatrix();
		glTranslatef(-1.5,-1.5,0.0);
		square(radius,numlayers,gldrawable);
	glPopMatrix();*/
  }

const float Scene::CLEAR_COLOR[4] = { 0., 0.01, 0., 1.0 };
  const float Scene::CLEAR_DEPTH    = 1.0;

  const float Scene::LIGHT0_POSITION[4] = { 0.0, 3.0, 3.0, 0.0 };
  const float Scene::LIGHT0_AMBIENT[4]  = { 0.0, 0.0, 0.0, 1.0 };
  const float Scene::LIGHT0_DIFFUSE[4]  = { 1.0, 1.0, 1.0, 1.0 };

  const float Scene::LIGHT_MODEL_AMBIENT[4]       = { 0.2, 0.2, 0.2, 1.0 };
  const float Scene::LIGHT_MODEL_LOCAL_VIEWER[1]  = { 0.0 };

  Scene::Scene() {  
	  Glib::RefPtr<Gdk::GL::Config> glconfig;

    // Try double-buffered visual
    glconfig = Gdk::GL::Config::create(Gdk::GL::MODE_RGB    |
                                       Gdk::GL::MODE_DEPTH  |
                                       Gdk::GL::MODE_DOUBLE);
    if (!glconfig) {
      /*std::cerr << "*** Cannot find the double-buffered visual.\n"
                << "*** Trying single-buffered visual.\n";*/

      // Try single-buffered visual
      glconfig = Gdk::GL::Config::create(Gdk::GL::MODE_RGB   |
                                         Gdk::GL::MODE_DEPTH);
      if (!glconfig) {
        //std::cerr << "*** Cannot find any OpenGL-capable visual.\n";
        std::exit(1);
      }
    }
    set_gl_capability(glconfig);

    //
    // Add events.
    //
    add_events(Gdk::BUTTON1_MOTION_MASK    |
               Gdk::BUTTON2_MOTION_MASK    |
               Gdk::BUTTON_PRESS_MASK      |
               Gdk::BUTTON_RELEASE_MASK    |
               Gdk::VISIBILITY_NOTIFY_MASK);

    // View transformation signals.
    signal_button_press_event().connect(
      sigc::bind(sigc::mem_fun(m_View, &View::on_button_press_event), this));
    signal_button_release_event().connect(
      sigc::bind(sigc::mem_fun(m_View, &View::on_button_release_event), this));
    signal_motion_notify_event().connect(
      sigc::bind(sigc::mem_fun(m_View, &View::on_motion_notify_event), this));

   }
   
   Scene::~Scene()
  {
  }

  void Scene::on_realize()
  {
    // We need to call the base on_realize()
    Gtk::DrawingArea::on_realize();

    //
    // Get GL::Drawable.
    //

    Glib::RefPtr<Gdk::GL::Drawable> gldrawable = get_gl_drawable();

    //
    // GL calls.
    //

    // *** OpenGL BEGIN ***
    if (!gldrawable->gl_begin(get_gl_context()))
      return;

    glClearColor(CLEAR_COLOR[0], CLEAR_COLOR[1], CLEAR_COLOR[2], CLEAR_COLOR[3]);
    glClearDepth(CLEAR_DEPTH);

    glLightfv(GL_LIGHT0, GL_POSITION, LIGHT0_POSITION);
    glLightfv(GL_LIGHT0, GL_AMBIENT,  LIGHT0_AMBIENT);
    glLightfv(GL_LIGHT0, GL_DIFFUSE,  LIGHT0_DIFFUSE);
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, LIGHT_MODEL_AMBIENT);
    glLightModelfv(GL_LIGHT_MODEL_LOCAL_VIEWER, LIGHT_MODEL_LOCAL_VIEWER);

    glFrontFace(GL_CW);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_AUTO_NORMAL);
    glEnable(GL_NORMALIZE);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);

    gldrawable->gl_end();
    // *** OpenGL END ***
  }

  bool Scene::on_configure_event(GdkEventConfigure* event)
  {
    //
    // Get GL::Drawable.
    //

    Glib::RefPtr<Gdk::GL::Drawable> gldrawable = get_gl_drawable();

    //
    // GL calls.
    //

    // *** OpenGL BEGIN ***
    if (!gldrawable->gl_begin(get_gl_context()))
      return false;

    m_View.frustum(get_width(), get_height());

    gldrawable->gl_end();
    // *** OpenGL END ***

    return true;
  }

  bool Scene::on_expose_event(GdkEventExpose* event)
  {
    //
    // Get GL::Drawable.
    //

    Glib::RefPtr<Gdk::GL::Drawable> gldrawable = get_gl_drawable();

    //
    // GL calls.
    //

    // *** OpenGL BEGIN ***
    if (!gldrawable->gl_begin(get_gl_context()))
      return false;

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glLoadIdentity();

    // View transformation.
    m_View.xform();

    // Logo model.
    m_Model.draw(gldrawable);

    // Swap buffers.
    if (gldrawable->is_double_buffered())
      gldrawable->swap_buffers();
    else
      glFlush();

    gldrawable->gl_end();
    // *** OpenGL END ***

    return true;
  }

  bool Scene::on_button_press_event(GdkEventButton* event)
  {
    if (event->button == 3) {
      //m_Menu->popup(event->button, event->time);
      return true;
    }

    // don't block
    return false;
  }

  bool Scene::on_unmap_event(GdkEventAny* event)
  {
    idle_remove();

    return true;
  }

  bool Scene::on_visibility_notify_event(GdkEventVisibility* event)
  {
    if (m_View.is_animate()) {
      if (event->state == GDK_VISIBILITY_FULLY_OBSCURED)
        idle_remove();
      else
        idle_add();
    }

    return true;
  }

  bool Scene::on_idle()
  {
    // Invalidate whole window.
    invalidate();
    // Update window synchronously (fast).
    update();

    return true;
  }

  void Scene::idle_add()
  {
    if (!m_ConnectionIdle.connected())
      m_ConnectionIdle = Glib::signal_idle().connect(
        sigc::mem_fun(*this, &Scene::on_idle), GDK_PRIORITY_REDRAW);
  }

  void Scene::idle_remove()
  {
    if (m_ConnectionIdle.connected())
      m_ConnectionIdle.disconnect();
  }
  
  const Glib::ustring Application::APP_NAME = "Frac";

  Application::Application()
    : m_VBox(false, 0), m_ButtonQuit("Save"),
    m_ButtonClick("Click")
  {
    //
    // Top-level window.
    //

    set_title(APP_NAME);

    // Get automatically redrawn if any of their children changed allocation.
    set_reallocate_redraws(true);

    add(m_VBox);

    //
    // Scene.
    //

    m_Scene.set_size_request(500, 500);

    m_VBox.pack_start(m_Scene);

    //
    // Simple quit button.
    //

    m_ButtonQuit.signal_clicked().connect(
      sigc::mem_fun(*this, &Application::on_button_quit_clicked));
	m_ButtonClick.signal_clicked().connect(
      sigc::mem_fun(*this, &Application::on_button_click_clicked));

    m_VBox.pack_start(m_ButtonQuit, Gtk::PACK_SHRINK, 0);
	m_VBox.pack_start(m_ButtonClick, Gtk::PACK_SHRINK, 0);

    //
    // Show window.
    //

    show_all();
  }

  Application::~Application()
  {
  }

  void Application::on_button_quit_clicked()
  {
	  
	int h=m_Scene.get_height();
	int w=m_Scene.get_width();
    
	std::cout<<w<<h<<std::endl;

    //int w=m_Scene.get_parent_window()->get_width();
    //int h=m_Scene.get_parent_window()->get_height();

	//unsigned char pixels[5]={0};
	unsigned char pixels[3 * w * h];
	
	glPixelStorei(GL_PACK_ALIGNMENT,1);
	
	glReadBuffer(GL_BACK_LEFT);
	glReadPixels(0, 0, w, h, GL_RGB, GL_UNSIGNED_BYTE, &pixels);
	
	FILE* fptr = fopen("03.ppm","w");
	ppm_image im={w,h,(uint8_t*)&pixels,sizeof(pixels)};
	ppm_save(&im,fptr);
	fclose(fptr);

    //Gtk::Main::quit();
  }
	void Application::on_button_click_clicked(){
		//glLoadIdentity();
		glRotatef(60, 1, 1, 0);
		//glViewport(0, 0, 900, 900);
		
		//gluLookAt(300, 10, 100,0, 30, 0,100, 0, 0);
		m_Scene.invalidate();
	}

  bool Application::on_key_press_event(GdkEventKey* event)
  {
    switch (event->keyval) {
    case GDK_Escape:
      Gtk::Main::quit();
      break;
    default:
      return true;
    }

    m_Scene.invalidate();

    return true;
  }


} // namespace Shapes

int main(int argc, char** argv)
{
  Gtk::Main kit(argc, argv);
  

  //
  // Init gtkglextmm.
  //

  Gtk::GL::init(argc, argv);

  //
  // Query OpenGL extension version.
  //

  //int major, minor;
  //Gdk::GL::query_version(major, minor);
  //std::cout << "OpenGL extension version - "  << major << "." << minor << std::endl;

  //
  // Instantiate and run the application.
  //

  Shapes::Application application;

  kit.run(application);

  return 0;
}
