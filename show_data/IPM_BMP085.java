
public class IPM_BMP085
  extends IPM_Barometer {
  
  ///////////////////////////////////////////////////////////////////////////////////////
  // CONSTRUCTORS
  ///////////////////////////////////////////////////////////////////////////////////////
  
  public IPM_BMP085( byte ID ) {
    this.b = new byte[NON_MEASUREMENT_BYTES+6];  // 1*int32 + 1*int16
    this.b[0] = 2;  // information packet ID
    this.b[1] = ID;  // sensor ID
  }
  
  
  ///////////////////////////////////////////////////////////////////////////////////////
  // PUBLIC METHODS
  ///////////////////////////////////////////////////////////////////////////////////////
  
  public void set_p( int p ) {
    IPM.encode_int32( p , this.b , 2 );
  }
  
  public void set_T( short T ) {
    IPM.encode_int16( T , this.b , 6 );
  }
  
  // IMP_Barometer implementation
  
  public double get_p() {
    return IPM.decode_int32( this.b , 2 );
  }
  
  public double get_Tp() {
    return IPM.decode_int16( this.b , 6 );
  }
  
  // toString
  
  public String toString() {
    return String.format( "%11d  %6d" ,
                          (int)this.get_p() ,
                          (int)this.get_Tp() );
  }
  
}