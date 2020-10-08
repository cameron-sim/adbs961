boolean ct_decrese_scale;
boolean ct_increase_scale;
boolean ct_decrease_x;
boolean ct_decrease_y;
boolean ct_increase_x;
boolean ct_increase_y;
boolean ct_increase_iterations;
boolean ct_decrease_iterations;
boolean ct_increase_escape;
boolean ct_decrease_escape;
boolean ct_sprint;
boolean ct_decrease_px_x;
boolean ct_decrease_px_y;
boolean ct_increase_px_x;
boolean ct_increase_px_y;

FadeMessage msg_escape;
FadeMessage msg_iterations;

void keyPressed()
{
  switch (Character.toString(key).toLowerCase().charAt(0))
  {
  case 'e':
    ct_decrese_scale = true;
    break;
  case 'q':
    ct_increase_scale = true;
    break;
  case 'w':
    ct_increase_x = true;
    break;
  case 's':
    ct_decrease_x = true;
    break;
  case 'a':
    ct_increase_y = true;
    break;
  case 'd':
    ct_decrease_y = true;
    break;
  case 'c':
    colour_mode++;
    colour_mode %= 3;
    break;
  case 'v':
    colour_sin++;
    colour_sin %= 2;
    break;
  case 'b':
    colour_smooth++;
    colour_smooth %= 2;
    break;
  case 'x':
    use_shader = !use_shader;
    
    if (use_shader)
    {
      fade_messages.add(new FadeMessage("GPU RENDERER", color(0, 255, 0)));
    }
    else
    {
      fade_messages.add(new FadeMessage("CPU RENDERER", color(255, 255, 0)));
    }
    
    break;
  case 'z':
    antialias++;
    antialias %= 3;
    
    if (antialias == 0)
    {
      fade_messages.add(new FadeMessage("AA: OFF", color(0, 255, 0)));
    }
    else if (antialias == 1)
    {
      framebuffer = createGraphics(width * 2, height * 2, P2D);
      fade_messages.add(new FadeMessage("AA: SuperSampling x2", color(0, 255, 0)));
    }
    else if (antialias == 2)
    {
      framebuffer = createGraphics(width, height, P2D);
      fade_messages.add(new FadeMessage("AA: FXAA", color(0, 255, 0)));
    }
    break;
  case 't':
    show_message = !show_message;
    break;
  case '\n':
    saveFrame("######.png");
    break;
  case 'f':
    show_fps = !show_fps;
    break;
  case 'i':
    ct_increase_px_y = true;
    break;
  case 'k':
    ct_decrease_px_y = true;
    break;
  case 'l':
    ct_increase_px_x = true;
    break;
  case 'j':
    ct_decrease_px_x = true;
    break;
  case CODED:
    switch (keyCode)
    {
    case UP:
      fade_messages.add(new FadeMessage(String.format("ITERATIONS %d", iterations), color(0, 255, 0)));
      msg_iterations = fade_messages.get(fade_messages.size() - 1);
      ct_increase_iterations = true;
      break;
    case DOWN:
      fade_messages.add(new FadeMessage(String.format("ITERATIONS %d", iterations), color(0, 255, 0)));
      msg_iterations = fade_messages.get(fade_messages.size() - 1);
      ct_decrease_iterations = true;
      break;
    case LEFT:
      fade_messages.add(new FadeMessage(String.format("ESCAPE %.2f", escape), color(0, 255, 0)));
      msg_escape = fade_messages.get(fade_messages.size() - 1);
      ct_decrease_escape = true;
      break;
    case RIGHT:
      fade_messages.add(new FadeMessage(String.format("ESCAPE %.2f", escape), color(0, 255, 0)));
      msg_escape = fade_messages.get(fade_messages.size() - 1);
      ct_increase_escape = true;
      break;
    case SHIFT:
      ct_sprint = true;
      break;
    }
    break;
  }
}

void keyReleased()
{
  switch (Character.toString(key).toLowerCase().charAt(0))
  {
  case 'e':
    ct_decrese_scale = false;
    break;
  case 'q':
    ct_increase_scale = false;
    break;
  case 'w':
    ct_increase_x = false;
    break;
  case 's':
    ct_decrease_x = false;
    break;
  case 'a':
    ct_increase_y = false;
    break;
  case 'd':
    ct_decrease_y = false;
    break;
  case 'i':
    ct_increase_px_y = false;
    break;
  case 'k':
    ct_decrease_px_y = false;
    break;
  case 'l':
    ct_increase_px_x = false;
    break;
  case 'j':
    ct_decrease_px_x = false;
    break;
  case CODED:
    switch (keyCode)
    {
    case UP:
      ct_increase_iterations = false;
      println(iterations);
      break;
    case DOWN:
      ct_decrease_iterations = false;
      println(iterations);
      break;
    case LEFT:
      ct_decrease_escape = false;
      break;
    case RIGHT:
      ct_increase_escape = false;
      break;
    case SHIFT:
      ct_sprint = false;
      break;
    }
    break;
  }
  
  println("x=" + centerX + " y=" + centerY);
}
