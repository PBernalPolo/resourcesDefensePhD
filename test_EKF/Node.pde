
public class Node {
  
  // VARIABLES
  private Matrix x;
  private long tNextMeasurement;
  private double d;
  private GUI gui;
  private float alpha;
  
  
  // CONSTRUCTOR
  
  public Node( long time , double x , double y , GUI theGUI ) {
    this.tNextMeasurement = time;
    this.x = Matrix.vector2( x , y );
    this.d = 0.0;
    this.gui = theGUI;
  }
  
  
  // PUBLIC METHODS
  
  public void reset_time( long time ) {
    
  }
  
  public void update( long time , double x , double y ) {
    // we compute the measurement
    Matrix dif = Matrix.subtraction( Matrix.vector2(x,y) , this.x );
    this.d = Math.sqrt( Matrix.product( dif.transposed() , dif ).e[0][0] ) + Math.sqrt( this.gui.get_Rs() )*randomGaussian();
    this.d = ( this.d > 0.0 )? this.d : -this.d;
    // and we set the next measurement time
    while( time > this.tNextMeasurement ){
      this.tNextMeasurement = time + (long)( (this.gui.get_mp() + MEASUREMENT_TIME_VARIANCE*randomGaussian())*1.0e9 );
    }
    // we also reset the alpha
    this.alpha = 255.0;
  }
  
  public void draw( long time , double s , float r , int state ) {
    noFill();
    stroke( 0 , 0 , 255 );
    ellipse( (float)(this.x.e[0][0]*s) , (float)(this.x.e[1][0]*s) , r , r );
    stroke( 0 , 0 , 255 , alpha ); //(float)Math.exp( -5.0*(time-this.tLastMeasurement)*1.0e-9 ) );
    ellipse( (float)(this.x.e[0][0]*s) , (float)(this.x.e[1][0]*s) , (float)(d*s) , (float)(d*s) );
    if( state != 1 ){
      if( alpha == 255.0 ){
        alpha = 0.3*alpha;
      }
      this.alpha = MEASUREMENT_STROKE_DAMPING*this.alpha;
    }
  }
  
  
}