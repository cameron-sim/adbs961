ArrayList<FadeMessage> fade_messages = new ArrayList<FadeMessage>();

class FadeMessage
{
  public String str;
  public color col;
  public double stamp;
  
  public FadeMessage(String _s, color _c)
  {
    str = _s;
    col = _c;
    stamp = draw_time_last;
  }
}
