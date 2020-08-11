
public class IPM_MPU6050_HMC5883L
  extends IPM_MARG {
  
  ///////////////////////////////////////////////////////////////////////////////////////
  // CONSTRUCTORS
  ///////////////////////////////////////////////////////////////////////////////////////
  
  public IPM_MPU6050_HMC5883L( byte ID ) {
    this.b = new byte[NON_MEASUREMENT_BYTES+20];  // 10*int16
    this.b[0] = 1;  // information packet ID
    this.b[1] = ID;  // sensor ID
  }
  
  
  ///////////////////////////////////////////////////////////////////////////////////////
  // PUBLIC METHODS
  ///////////////////////////////////////////////////////////////////////////////////////
  
  public void set_a( short ax , short ay , short az ) {
    IPM.encode_int16( ax , this.b , 2 );
    IPM.encode_int16( ay , this.b , 4 );
    IPM.encode_int16( az , this.b , 6 );
  }
  
  public void set_w( short wx , short wy , short wz ) {
    IPM.encode_int16( wx , this.b , 8 );
    IPM.encode_int16( wy , this.b , 10 );
    IPM.encode_int16( wz , this.b , 12 );
  }
  
  public void set_T( short T ) {
    IPM.encode_int16( T , this.b , 14 );
  }
  
  public void set_m( short mx , short my , short mz ) {
    IPM.encode_int16( mx , this.b , 16 );
    IPM.encode_int16( my , this.b , 18 );
    IPM.encode_int16( mz , this.b , 20 );
  }
  
  // IPM_MARG implementation
  
  public double[] get_a() {
    double[] am = new double[3];
    am[0] = IPM.decode_int16( this.b , 2 );
    am[1] = IPM.decode_int16( this.b , 4 );
    am[2] = IPM.decode_int16( this.b , 6 );
    return am;
  }
  
  public double get_Ta() {
    return IPM.decode_int16( this.b , 14 );
  }
  
  public double[] get_w() {
    double[] wm = new double[3];
    wm[0] = IPM.decode_int16( this.b , 8 );
    wm[1] = IPM.decode_int16( this.b , 10 );
    wm[2] = IPM.decode_int16( this.b , 12 );
    return wm;
  }
  
  public double get_Tw() {
    return IPM.decode_int16( this.b , 14 );
  }
  
  public double[] get_m() {
    double[] mm = new double[3];
    mm[0] = IPM.decode_int16( this.b , 16 );
    mm[1] = IPM.decode_int16( this.b , 18 );
    mm[2] = IPM.decode_int16( this.b , 20 );
    return mm;
  }
  
  public double get_Tm() {
    return IPM.decode_int16( this.b , 14 );
  }
  
  // toString
  
  public String toString() {
    double[] am = this.get_a();
    double[] wm = this.get_w();
    double[] mm = this.get_m();
    return String.format( "%6d %6d %6d  %6d %6d %6d  %6d  %6d %6d %6d" ,
                          (int)am[0] , (int)am[1] , (int)am[2] ,
                          (int)wm[0] , (int)wm[1] , (int)wm[2] ,
                          (int)this.get_Ta() ,
                          (int)mm[0] , (int)mm[1] , (int)mm[2] );
  }
  
}