boolean use_shader = true;

// All of these variables are of type double because of the precision
// benifits over single precision floats. The GLSL version only uses
// single precision because the version of GL ES that Processing uses
// does not support the fp64 extension.

double pxX = 0; // Pixel offset x
double pxY = 0; // Pixel offset y
double centerX = -.8;   // 'real' center value
double centerY = .156; // 'unreal' center value
double scale = 1.17;  // zoom factor
double escape = 16.0; // 'escape' value (R)

int iterations = 150;
int colour_mode = 0;
int colour_sin = 0;    // 0 = half sin, 1 = full sin
int colour_smooth = 1; // https://www.iquilezles.org/www/articles/mset_smooth/mset_smooth.htm
int antialias = 0;     // 0 = No AA, 1 = internal framebuffer scaled x2, 2 = FXAA

// FXAA implementation from https://github.com/mattdesl/glsl-fxaa
// (c) 2011 by Armin Ronacher.
// MIT license
// (see fxaa.glsl)

boolean show_message = true;
boolean show_fps = false;

color text_colour;
float text_opacity;
int font_size = 24;

float screen_ratio = 0.f;

Thread threads[] = new Thread[4];

PShader shader;
PShader fxaa;
PGraphics framebuffer;
PFont font;

int lastW, lastH;

void setup()
{
  size(1280, 720, P2D);
  screen_ratio = (float)width / (float)height;
  
  fxaa = loadShader("fxaa.glsl");
  shader = loadShader("fractal.glsl");
  
  framebuffer = createGraphics(width, height, P2D);
  font = createFont("Courier", font_size);
  textFont(font);
  noStroke();
  
  surface.setResizable(true);
  lastW = width;
  lastH = height;
}

void showControls()
{
  text_opacity = 1.f;
  text_colour = color(255);
  textAlign(CENTER);
  fill(200);
  int textY = height / 2 - 250;
  textOutlined("Fractal viewer by Cameron Sim.", width / 2, textY += font_size);
  textAlign(LEFT);
  int x = width / 2 - 350;
  textOutlined("       W/S: Increase/Decrease real number.", x, textY += font_size * 4);
  textOutlined("       A/D: Increase/Decrease unreal number.", x, textY += font_size);
  textOutlined("       E/Q: Zoom in/out.", x, textY += font_size);
  textOutlined("         Z: Change antialiasing mode (GPU mode only).", x, textY += font_size);
  textOutlined("         X: Toggle CPU/GPU mode.", x, textY += font_size);
  textOutlined("         C: Change colour mode (red/green/blue).", x, textY += font_size);
  textOutlined("         V: Change colour mode (half sin/sin).", x, textY += font_size);
  textOutlined("   UP/DOWN: Increase/Decrease iteration count.", x, textY += font_size);
  textOutlined("RIGHT/LEFT: Increase/Decrease escape condition.", x, textY += font_size);
  textOutlined("         T: Toggle this message.", x, textY += font_size);
  textOutlined("         F: Toggle FPS counter.", x, textY += font_size);
  textOutlined("     ENTER: Take screenshot.", x, textY += font_size);
  textOutlined("     SHIFT: Increase speed.", x, textY += font_size);
  textOutlined("   I/J/K/L: Translate fractal.", x, textY += font_size);
  textOutlined("         B: Toggle smoothing (GPU only).", x, textY += font_size);
}

double draw_time_last = 0;

void draw()
{
  if (width != lastW ||  height != lastH)
  {
    lastW = width;
    lastH = height;
    screen_ratio = (float)width / (float)height;
    
    if (antialias == 1)
    {
      framebuffer = createGraphics(width * 2, height * 2, P2D);
    }
    else
    {
      framebuffer = createGraphics(width, height, P2D);
    }
  }
  
  double time = (double)System.nanoTime() / 1000000000.f;
  float dt = (float)(time - draw_time_last);
  draw_time_last = time;
  float fps = 1.f / dt;
  
  text_opacity = 1.f;
  float rate = ct_sprint ? 2.f : .2f;
  
  // handle input (user holding down keys)
  if (ct_decrese_scale) scale *= ct_sprint ? .99 : .995;
  if (ct_increase_scale) scale *= ct_sprint ? 1.01 : 1.005;
  if (ct_increase_y) centerY += scale * dt * .1 * rate;
  if (ct_decrease_y) centerY -= scale * dt * .1 * rate;
  if (ct_increase_x) centerX += scale * dt * .1 * rate;
  if (ct_decrease_x) centerX -= scale * dt * .1 * rate;
  
  if (ct_increase_iterations)
  {
    iterations *= 1.1;
    msg_iterations.stamp = time;
    msg_iterations.str = String.format("ITERATIONS %d", iterations);
  }
  
  if (ct_decrease_iterations && iterations * .9 > 10)
  {
    iterations *= .9;
    msg_iterations.stamp = time;
    msg_iterations.str = String.format("ITERATIONS %d", iterations);
  }
  
  if (ct_increase_escape)
  {
    escape += .03;
    msg_escape.stamp = time;
    msg_escape.str = String.format("ESCAPE %.2f", escape);
  }
  
  if (ct_decrease_escape) 
  {
    escape -= .03;
    msg_escape.stamp = time;
    msg_escape.str = String.format("ESCAPE %.2f", escape);
  }
  
  if (ct_decrease_px_x) pxX -= scale * dt * .1 * rate;
  if (ct_increase_px_x) pxX += scale * dt * .1 * rate;
  if (ct_decrease_px_y) pxY += scale * dt * .1 * rate;
  if (ct_increase_px_y) pxY -= scale * dt * .1 * rate;
  // done handling input
  
  background(0);
  
  if (use_shader)
  {
    // set uniform values
    shader.set("pxX", (float)pxX);
    shader.set("pxY", (float)pxY);
    shader.set("centerX", (float)centerX);
    shader.set("centerY", (float)centerY);
    shader.set("scale", (float)scale);
    shader.set("screen_ratio", (float)screen_ratio);
    shader.set("iterations", iterations);
    shader.set("colour_mode", colour_mode);
    shader.set("colour_sin", colour_sin);
    shader.set("escape", (float)escape);
    shader.set("colour_smooth", colour_smooth);
    
    if (antialias == 0)
    {
      // No AA
      shader(shader);
      rect(0, 0, width, height);
      resetShader();
    }
    else
    {
      framebuffer.beginDraw();
      framebuffer.noStroke();
      framebuffer.shader(shader);
      framebuffer.rect(0, 0, framebuffer.width, framebuffer.height);
      framebuffer.resetShader();
      framebuffer.endDraw();
      
      if (antialias == 2)
      {
        // FXAA
        fxaa.set("framebuffer", framebuffer);
        fxaa.set("fb_width", (float)width);
        fxaa.set("fb_height", (float)height);
        shader(fxaa);
        rect(0, 0, width, height);
        resetShader();
      }
      else
      {
        // Scaled framebuffer
        image(framebuffer, 0, 0, width, height);
      }
    }
  }
  else
  {
    // multithreaded CPU mode (slow)
    loadPixels();
    
    // dispatch threads
    for (int i = 0; i < threads.length; i++)
    {
      threads[i] = new Thread(new Renderer(i));
      threads[i].start();
    }
    
    // wait for threads to finish
    for (int i = 0; i < threads.length; i++)
    {
      try
      {
        threads[i].join();
      }
      catch (Exception e) {}
    }
    
    updatePixels();
  }
  
  textAlign(RIGHT);
  int textY = 0;
  
  // remove any messages that have faded out
  for (int i = 0; i < fade_messages.size(); i++)
  {
    FadeMessage msg = fade_messages.get(i);
    
    if (time - msg.stamp > 2.5)
    {
      fade_messages.remove(msg);
      i--;
    }
  }
  
  // draw FadeMessages
  for (FadeMessage msg : fade_messages)
  {
    float span = (float)(time - msg.stamp);
    text_colour = msg.col;
    text_opacity = 1.f - pow(span / 2.5f, 2.f);
    textOutlined(msg.str, width - 10, textY += font_size * (1.f - pow(1.f - text_opacity, 4.f)));
  }
  
  if (show_fps)
  {
    text_colour = color(255);
    text_opacity = 1.f;
    textOutlined("fps=" + nf(fps, 2, 2), width - 10, textY += font_size);
  }
  
  // show 'welcome' message
  if (show_message) showControls();
}

void textOutlined(String t, int x, int y)
{
  // 'outline' the text by drawing it offset
  // and black behind the actual text.
  fill(0, (text_opacity * 255) / 4);
  text(t, x+1, y+1);
  text(t, x+1, y-1);
  text(t, x-1, y+1);
  text(t, x-1, y-1);
  fill(text_colour, text_opacity * 255);
  text(t, x, y);
}
