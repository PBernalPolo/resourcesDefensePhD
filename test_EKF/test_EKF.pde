
// PARAMETERS
static final int N = 6;  // number of nodes
static final int L = 10;  // size of the room
static final int N_SIGMAS = 50;  // number of sigmas drawn (resolution of the pdf)
static final double MEASUREMENT_TIME_VARIANCE = 0.1;  // variance of the measurement period
static final float MEASUREMENT_STROKE_DAMPING = 0.9;

// VARIABLES
int state;
long tPause;
long pausedTime;
long tLastUpdate;
double x;
double y;
//int cnod;
Node[] nodes;
Node nextNode;
EKF ekf;
UKF_LLT ukfLLT;
UKF_LDLT ukfLDLT;
GUI gui;

void setup() {
  //size( 700 , 500 );
  fullScreen( P2D , SPAN );  // to EXIT fullScreen mode, press ESC
  
  // first, we create the GUI
  gui = new GUI( this );
  
  reset();
  
  ellipseMode(RADIUS);
}


void draw() {
  long time = System.nanoTime() - pausedTime;
  // UPDATES
  if( state != 1 ){  // if we are not paused
  // we update the state of the vehicle
  double dt = ( time - tLastUpdate )*1.0e-9;
  tLastUpdate = time;
  double Q = gui.get_Qs();
  x += randomGaussian()*Math.sqrt( Q*dt );
  y += randomGaussian()*Math.sqrt( Q*dt );
  // we predict the state
  ekf.predict( time );
  ukfLLT.predict( time );
  ukfLDLT.predict( time );
  // if the node has produced a measurement
  if( time > nextNode.tNextMeasurement ){
    // we update
    nextNode.update( time , x , y );
    ekf.update( nextNode );
    ukfLLT.update( nextNode );
    ukfLDLT.update( nextNode );
    // we find the node that will produce the next measurement
    nextNode = get_nextNode( nodes );
    // and we set the state
    if( state == 0 ){
      tPause = System.nanoTime();
      state = 1;
    }
  }
  }
  // DRAWINGS
  float sw = 0.002*width;
  float r = 0.003*width;
  float s = height/L;
  background(255);
  // we draw the covariance matrix
  if( gui.get_showEKF() ) ekf.draw_covariance( s , r );
  if( gui.get_showUKFllt() ) ukfLLT.draw_covariance( s , r );
  if( gui.get_showUKFldlt() ) ukfLDLT.draw_covariance( s , r );
  // we draw the nodes
  strokeWeight( sw );
  for(int n=0; n<this.nodes.length; n++){
    nodes[n].draw( time , s , r , state );
  }
  // we draw the state of the vehicle
  noFill();
  stroke( 0 );
  ellipse( (float)(x*s) , (float)(y*s) , 2*r , 2*r );
  // we draw the state
  if( gui.get_showEKF() ) ekf.draw( s , r );
  if( gui.get_showUKFllt() ) ukfLLT.draw( s , r );
  if( gui.get_showUKFldlt() ) ukfLDLT.draw( s , r );
}

void keyPressed() {
  switch( state ){
    case 0:  // running until measurement
      break;
    case 1:  // paused until keypressed
      if( key == ' ' ){
        pausedTime += System.nanoTime()-tPause;
        state = 0;
      }else if(  key == 'p'  ||  key == 'P'  ){
        pausedTime += System.nanoTime()-tPause;
        state = 2;
      }
      break;
    case 2:  // running until keypressed
      if( key == ' ' ){
        state = 0;
      }else if( key == 'p'  ||  key == 'P'  ){
        state = 2;
      }
    default:
      state = 0;
      break;
  }
  if(  key == 'r'  ||  key == 'R'  ){
    reset();
  }
}

void reset() {
  state = 0;
  pausedTime = 0;
  tLastUpdate = System.nanoTime();
  x = 0.5*L;
  y = 0.5*L;
  nodes = new Node[N];
  for(int n=0; n<N; n++){
    double x = Math.random()*L;
    double y = Math.random()*L;
    long rT = (long)(Math.random()*1.0e9);
    nodes[n] = new Node( System.nanoTime()+rT , x , y , gui );
  }
  nextNode = get_nextNode( nodes );
  ekf = new EKF( L , System.nanoTime() , gui );
  ukfLLT = new UKF_LLT( L , System.nanoTime() , gui );
  ukfLDLT = new UKF_LDLT( L , System.nanoTime() , gui );
}

Node get_nextNode( Node[] node ) {
  Node theNode = node[0];
  for(int n=1; n<node.length; n++){
    if( node[n].tNextMeasurement < theNode.tNextMeasurement ){
      theNode = node[n];
    }
  }
  return theNode;
}