// https://en.wikipedia.org/wiki/Julia_set
// see fractal.glsl
// the CPU version does not include the smoothing algorithm.
int julia(double nx, double ny)
{
  double zx = screen_ratio * (nx - .5) * scale + pxX;
  double zy = (ny - .5) * scale + pxY;
  
  int it;
  for (it = 0; it < iterations; it++)
  {
    double x = (zx * zx - zy * zy) + centerX;
    double y = (zy * zx + zx * zy) + centerY;
    
    if ((x * x + y * y) > escape) break;
    zx = x;
    zy = y;
  }
  
  return it;
}

class Renderer implements Runnable
{
  int n;
  
  public Renderer(int _n) { n = _n; }
  
  public void run()
  {
    for (int i = n; i < width * height; i += threads.length)
    {
      double nx = (float)(i % width) / (float)width;
      double ny = (float)(i / width) / (float)height;
      
      float c = julia(nx, ny) / (float)iterations;
      
      switch(colour_sin)
      {
      case 0:
        c *= 3.14159265;
        break;
      case 1:
        c *= 1.57079632;
        break;
      }
      
      switch(colour_mode)
      {
      case 0:
        pixels[i] = color(pow(sin(c), .5) * 255, pow(sin(c), 3) * 255, pow(sin(c), 5) * 255);
        break;
      case 1:
        pixels[i] = color(pow(sin(c), 5) * 255, pow(sin(c), 3) * 255, pow(sin(c), .5) * 255);
        break;
      case 2:
        pixels[i] = color(pow(sin(c), 3) * 255, pow(sin(c), .5) * 255, pow(sin(c), 5) * 255);
        break;
      }
    }
  }
}
