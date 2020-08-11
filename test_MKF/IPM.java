
// implemented Information Packets:
// information packet ID - name
// 0 - IPM_MPU6050
// 1 - IPM_MPU6050_HMC5883L
// 2 - IPM_BMP085
// 3 - IPM_AdafruitIMU9dof
// 4 - IPM_t_MPU6050_HMC5883L
// 5 - IPM_t_BMP085


public class IPM {
  
  ///////////////////////////////////////////////////////////////////////////////////////
  // PARAMETERS
  ///////////////////////////////////////////////////////////////////////////////////////
  protected static final int NON_MEASUREMENT_BYTES = 2;  // information packet ID + sensor ID
  
  ///////////////////////////////////////////////////////////////////////////////////////
  // VARIABLES
  ///////////////////////////////////////////////////////////////////////////////////////
  protected byte[] b;
  
  
  ///////////////////////////////////////////////////////////////////////////////////////
  // PUBLIC METHODS
  ///////////////////////////////////////////////////////////////////////////////////////
  
  public void set_bytes( byte[] bytePointer ) {
    this.b = bytePointer;
  }
  
  public byte[] get_bytes() {
    return this.b;
  }
  
  public int get_IPID() {
    return this.b[0];
  }
  
  public int get_SID() {
    return this.b[1];
  }
  
  public String toString() {
    String s = "";
    for(int i=0; i<this.b.length; i++){
      s += " " + b[i];
    }
    return s;
  }
  
  
  ///////////////////////////////////////////////////////////////////////////////////////
  // PUBLIC STATIC METHODS
  ///////////////////////////////////////////////////////////////////////////////////////
  
  public static void encode_int8( byte value , byte[] b , int index ) {
    b[index] = value;
  }
  
  public static byte decode_int8( byte[] b , int index ) {
    return b[index];
  }
  
  public static void encode_int16( short value , byte[] b , int index ) {
    b[index] = (byte)value;
    b[index+1] = (byte)( value >> 8 );
  }
  
  public static short decode_int16( byte[] b , int index ) {
    return (short)( ( b[index+1] << 8 ) | (b[index] & 0xFF) );
  }
  
  public static void encode_int32( int value , byte[] b , int index ) {
    b[index] = (byte)value;
    b[index+1] = (byte)( value >> 8 );
    b[index+2] = (byte)( value >> 16 );
    b[index+3] = (byte)( value >> 24 );
  }
  
  public static int decode_int32( byte[] b , int index ) {
    return ( ( b[index+3] << 24 ) | ( (b[index+2] & 0xFF) << 16 ) | ( (b[index+1] & 0xFF) << 8 ) | (b[index] & 0xFF) );
  }
  
  public static void encode_int64( long value , byte[] b , int index ) {
    b[index] = (byte)value;
    b[index+1] = (byte)( value >> 8 );
    b[index+2] = (byte)( value >> 16 );
    b[index+3] = (byte)( value >> 24 );
    b[index+4] = (byte)( value >> 32 );
    b[index+5] = (byte)( value >> 40 );
    b[index+6] = (byte)( value >> 48 );
    b[index+7] = (byte)( value >> 56 );
  }
  
  public static long decode_int64( byte[] b , int index ) {
    return ( ( (b[index+7] & 0xFFL) << 56 ) | ( (b[index+6] & 0xFFL) << 48 ) | ( (b[index+5] & 0xFFL) << 40 ) | ( (b[index+4] & 0xFFL) << 32 ) | ( (b[index+3] & 0xFFL) << 24 ) | ( (b[index+2] & 0xFFL) << 16 ) | ( (b[index+1] & 0xFFL) << 8 ) | (b[index] & 0xFFL) );
  }
  
  public static void encode_float( float value , byte[] b , int index ) {
    int theBits = Float.floatToIntBits( value );
    b[index] = (byte)theBits;
    b[index+1] = (byte)( theBits >> 8 );
    b[index+2] = (byte)( theBits >> 16 );
    b[index+3] = (byte)( theBits >> 24 );
  }
  
  public static float decode_float( byte[] b , int index ) {
    return Float.intBitsToFloat( ( (b[index+3] & 0xFF) << 24 ) | ( (b[index+2] & 0xFF) << 16 ) | ( (b[index+1] & 0xFF) << 8 ) | (b[index] & 0xFF) );
  }
  
}
