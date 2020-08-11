
float R;  // radius of the circle

int N = 99;  // number of points in the circle
Point[] q;  // points in the circle;
Point[] p;  // projected points

ProjectionChart pc;
EquidistantChart ec;
Chart c;

float h;  // height from where the projection is performed
float d;  // distance traveled by the wheel
boolean stateV;  // true if we want to see the other half of the sphere
boolean stateP;  // true if we want to draw the projections
boolean stateC;  // true if the background is black
color bgColor;  // color for the background
color lcColor;  // color for the line and the circle
color pColor;  // color for the projections

void setup() {
  //size(1000,1000,P2D);
  fullScreen( P2D , SPAN );
  smooth(8);
  
  R = 0.25*height;
  
  q = generate_points( N );
  p = generate_points( N );
  
  pc = new ProjectionChart();
  ec = new EquidistantChart();
  c = pc;
  
  h = 0.0;
  stateV = false;
  stateP = true;
  stateC = true;
  bgColor = 0;
  lcColor = 255;
  pColor = 150;
}

void draw() {
  background(bgColor);
  
  h = -2.5*mouseY;
  d = mouseX;
  
  pushMatrix();
  translate( 0.5*width , 0.5*height );
  scale( 1 , -1 );
  // first we draw the circle and the line
  stroke( lcColor );
  line( -0.5*width , R , 0.5*width , R );
  noFill();
  ellipse( 0 , 0 , R+R , R+R );
  // then we draw the projections
  if( stateP ){
    for(int i=0; i<p.length; i++){
      if(  stateV  ||  q[i].y > 0.0  ){
        c.f( q[i] , p[i] );
        stroke( pColor );
        line( 0 , h , p[i].x , p[i].y );
      }
    }
  }
  // then we draw the points
  for(int i=0; i<p.length; i++){
    if(  stateV  ||  q[i].y > 0.0  ){
      c.f( q[i] , p[i] );
      q[i].draw_line( p[i] );
      q[i].draw();
      p[i].draw();
    }
  }
  popMatrix();
  
}


public Point[] generate_points( int N ) {
  Point[] p = new Point[N];
  float alpha = 0.0;
  float da = TWO_PI/N;
  for(int i=0; i<N; i++){
    p[i] = new Point( R*sin(alpha) , R*cos(alpha) );
    alpha += da;
  }
  return p;
}


void keyPressed() {
  switch( key ){
    case 'h':  // show/hide projections of points in the other circle half
      stateV = !stateV;
      break;
    case 'r':  // show/hide rays
      stateP = !stateP;
      break;
    case 't':  // toggle colors
      if( stateC ){
        bgColor = 255;
        lcColor = 0;
        pColor = 105;
      }else{
        bgColor = 0;
        lcColor = 255;
        pColor = 150;
      }
      stateC = !stateC;
      break;
    case 'p':  // switch stereographic/equidistant projection
      if( c == pc ){
        c = ec;
      }else{
        c = pc;
      }
      break;
    default:
      break;
  }
}
