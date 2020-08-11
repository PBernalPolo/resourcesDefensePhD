
public class Point {
  
  // PRIVATE STATIC VARIABLES
  //private static float u;  // unit measure
  
  // PRIVATE VARIABLES
  private float x;  // x-position
  private float y;  // y-position
  private float d;  // point diameter
  private color c;  // color
  
  
  // PUBLIC CONSTRUCTORS
  
  public Point( float px , float py ) {
    this.x = px;
    this.y = py;
    this.d = 0.02*R;
    float min = 0.5;
    float a = (1.0-min)/R;
    this.c = color( (-a*py+min)*255 , (a*py+min)*255 , -px/R*255 );
  }
  
  
  // PUBLIC METHODS
  
  public void draw() {
    fill( this.c );
    ellipse( this.x , this.y , this.d , this.d );
  }
  
  
  // PUBLIC STATIC METHODS
  
  public void draw_line( Point p ) {
    stroke( this.c );
    line( this.x , this.y , p.x , p.y );
  }
  
  //public static void set_unit( float unit ) {
  //  Point.u = unit;
  //}
  
}