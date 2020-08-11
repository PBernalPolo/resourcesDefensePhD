
public class UKF_LDLT {
  
  // VARIABLES
  private long tLastPredict;
  private Matrix x;
  private Matrix P;
  private GUI gui;
  
  Matrix[] sp;
  
  
  // CONSTRUCTORS
  
  public UKF_LDLT( double  L , long time , GUI theGUI ) {
    this.tLastPredict = time;
    this.x = Matrix.vector2( 0.5*L , 0.5*L );
    this.P = Matrix.identity(2,2).multiply( 1.0e1 );
    this.gui = theGUI;
    
    this.sp = new Matrix[2*this.P.Nrows+1];
  }
  
  
  // PUBLIC METHODS
  
  public void predict( long time ) {
    double dt = ( time - this.tLastPredict )*1.0e-9;
    this.tLastPredict = time;
    Matrix Q = Matrix.identity(2,2).multiply( this.gui.get_QukfLDLT()*dt );
    this.P.add( Q );
  }
  
  public void update( Node nod ) {
    // first, we generate the sigma points
    this.sp[0] = this.x.copy();
    Matrix L = this.P.copy();
    Matrix.LDLT( L );
    double W0 = this.gui.get_D0();
    double[] W = new double[this.sp.length];
    W[0] = W0;
    double trD = W0;
    for(int i=0; i<this.P.Nrows; i++){
      W[i+1] = L.e[i][i];
      W[i+1+this.P.Nrows] = L.e[i][i];
      trD += W[i+1];
      L.e[i][i] = 1.0;
    }
    W[0] /= trD;
    for(int i=1; i<=this.P.Nrows; i++){
      W[i] /= 2.0*trD;
      W[i+this.P.Nrows] /= 2.0*trD;
    }
    L.scale( Math.sqrt( trD ) );
    for(int n=0; n<this.P.Nrows; n++){
      this.sp[n+1] = Matrix.sum( this.x , L.get_submatrixColumns( n , 1 ) );
      this.sp[n+1+this.P.Nrows] = Matrix.subtraction( this.x , L.get_submatrixColumns( n , 1 ) );
    }
    // now we apply the non-linearity
    Matrix[] d = new Matrix[this.sp.length];
    for(int n=0; n<this.sp.length; n++){
      Matrix dif = Matrix.subtraction( this.sp[n] , nod.x );
      d[n] = Matrix.product( dif.transposed() , dif );
      d[n].e[0][0] = Math.sqrt( d[n].e[0][0] );
    }
    // we compute the mean
    Matrix dp = Matrix.zeros( 1 , 1 );
    for(int n=0; n<this.sp.length; n++){
      dp.add( d[n].multiply( W[n] ) );
    }
    // and the covariance matrices
    Matrix K = Matrix.zeros( 2 , 1 );  // this is actually Pxy, but then will be K
    Matrix S = Matrix.identity(1,1).multiply( this.gui.get_RukfLDLT() );
    for(int n=0; n<this.sp.length; n++){
      Matrix dx = Matrix.subtraction( this.sp[n] , this.x );
      Matrix dz = Matrix.subtraction( d[n] , dp );
      K.add( Matrix.product( dx , dz.transposed() ).multiply( W[n] ) );
      S.add( Matrix.product( dz , dz.transposed() ).multiply( W[n] ) );
    }
    // and we update the state
    double sf = 1.0;//S.get_maxValue();
    sf = ( sf > 0.0 )? sf : 1.0;
    S.scale( sf );
    Matrix.Cholesky( S );
    K.scale( sf );
    Matrix.solve_Cholesky( S , K );
    Matrix dz = Matrix.zeros(1,1);
    dz.e[0][0] = nod.d - dp.e[0][0];
    this.x.add( Matrix.product( K , dz ) );
    this.P = Matrix.subtraction( this.P , Matrix.product_Cholesky( K , S ) );
  }
  
  public void draw( float s , float r ) {
    noFill();
    stroke( 155 , 155 , 255 );
    ellipse( (float)(this.x.e[0][0]*s) , (float)(this.x.e[1][0]*s) , 2*r , 2*r );
  }
  
  public void draw_covariance( float s , float r ) {
    int Npoints = 50;
    double da = TWO_PI/Npoints;
    Matrix L = this.P.copy();
    Matrix.Cholesky( L );
    double dx = 4.0/N_SIGMAS;
    for(double x=4.0; x>0.0; x-=dx){
      double val = 127.0*Math.exp(-x*x);
      fill( 0 , 0 , 255 , (float)val );
      noStroke();
      beginShape();
      for(double a=0.0; a<TWO_PI; a+=da){
        Matrix xp = Matrix.sum( this.x , Matrix.product( L , Matrix.vector2( Math.cos(a) , Math.sin(a) ) ).multiply( x ) );
        vertex( (float)(xp.e[0][0]*s) , (float)(xp.e[1][0]*s) );
      }
      endShape(CLOSE);
    }
    // now we draw the sigma points
    noFill();
    stroke( 255 , 0 , 0 );
    for(int n=0; n<this.sp.length; n++){
      if( sp[n] != null ){
        ellipse( (float)(this.sp[n].e[0][0]*s) , (float)(this.sp[n].e[1][0]*s) , r , r );
      }
    }
  }
  
}