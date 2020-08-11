
public class EKF {
  
  // VARIABLES
  private long tLastPredict;
  private Matrix x;
  private Matrix P;
  private GUI gui;
  
  
  // CONSTRUCTORS
  
  public EKF( double  L , long time , GUI theGUI ) {
    this.tLastPredict = time;
    this.x = Matrix.vector2( 0.5*L , 0.5*L );
    this.P = Matrix.identity(2,2).multiply( 1.0e1 );
    this.gui = theGUI;
  }
  
  
  // PUBLIC METHODS
  
  public void predict( long time ) {
    double dt = ( time - this.tLastPredict )*1.0e-9;
    this.tLastPredict = time;
    Matrix Q = Matrix.identity(2,2).multiply( this.gui.get_Qekf()*dt );
    this.P.add( Q );
  }
  
  public void update( Node nod ) {
    // we predict the measurement
    Matrix dif = Matrix.subtraction( this.x , nod.x );
    Matrix d = Matrix.product( dif.transposed() , dif );
    d.e[0][0] = Math.sqrt( d.e[0][0] );
    Matrix H = dif.transposed().multiply( 1.0/d.e[0][0] );
    Matrix R = Matrix.identity(1,1).multiply( this.gui.get_Rekf() );
    Matrix S = Matrix.sum( Matrix.product_Cholesky( H , this.P ) , R );
    // and we update the state
    double sf = 1.0/S.get_maxValue();
    sf = ( sf > 0.0 )? sf : 1.0;
    S.scale( sf );
    Matrix.Cholesky( S );
    Matrix K = Matrix.product( this.P , H.transposed() );
    K.scale( sf );
    Matrix.solve_Cholesky( S , K );
    Matrix dz = Matrix.zeros(1,1);
    dz.e[0][0] = nod.d - d.e[0][0];
    this.x.add( Matrix.product( K , dz ) );
    Matrix IKH = Matrix.identity( this.P.Nrows , this.P.Nrows );
    IKH.subtract( Matrix.product( K , H ) );
    this.P = Matrix.sum( Matrix.product_Cholesky( IKH , this.P ) , Matrix.product_Cholesky( K , R ) );
  }
  
  public void draw( float s , float r ) {
    noFill();
    stroke( 155 , 255 , 155 );
    ellipse( (float)(this.x.e[0][0]*s) , (float)(this.x.e[1][0]*s) , 2*r , 2*r );
  }
  
  public void draw_covariance( float s , float r ) {
    int Npoints = 40;
    double da = TWO_PI/Npoints;
    Matrix L = this.P.copy();
    Matrix.Cholesky( L );
    double dx = 4.0/N_SIGMAS;
    for(double x=4.0; x>0.0; x-=dx){
      double val = 127.0*Math.exp(-x*x);
      fill( 0 , 255 , 0 , (float)val );
      noStroke();
      beginShape();
      for(double a=0.0; a<TWO_PI; a+=da){
        Matrix xp = Matrix.sum( this.x , Matrix.product( L , Matrix.vector2( Math.cos(a) , Math.sin(a) ) ).multiply( x ) );
        vertex( (float)(xp.e[0][0]*s) , (float)(xp.e[1][0]*s) );
      }
      endShape(CLOSE);
    }
  }
  
}