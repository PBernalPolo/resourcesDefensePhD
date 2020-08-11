

// we import the serial library
import processing.serial.*;


// class that manages connected serial devices
public class CommunicationManager implements Runnable {
  
  // PARAMETERS
  private String[] dontOpen = new String[]{ "/dev/rfcomm0" , "/dev/ttyAMA0" , "/dev/serial1" ,
//                                            "/dev/serial" , "/dev/ttyUSB0" , "/dev/ttyUSB1" , "/dev/ttyUSB2"  // only if we want to read from the xsense and the crossbow
                                          };
  
  // PRIVATE VARIABLES
  private PApplet thePApplet;
  private boolean running;  // true while the thread is running
  private boolean wait;  // true if we want to pause the thread
  private boolean waiting;  // true if we are waiting for activity
  private int stateN;  // state of the finite-state machine that manages the network
  private int NSPM;  // Number of Serial Port Managers in the last update (in the list; not all will be available)
  private int NASPM;  // Number of Available Serial Port Managers in the last update (only those that can be opened; those that do not throw an exception when you try to open them)
  private SerialPortManager[] SPM;
  private Graphic g[];
  private IPM[] m;
  private TriaxialCalibration[] atcd, atco;
  private TriaxialCalibration[] wtcd, wtco;
  private TriaxialCalibration[] mtcd, mtco;
  
  
  // CONSTRUCTORS
  
  public CommunicationManager( PApplet aPApplet , Graphic[] graphs ) {
    this.thePApplet = aPApplet;
    this.running = true;
    this.wait = false;
    this.waiting = false;
    this.stateN = 0;
    this.NSPM = 0;
    this.NASPM = 0;
    this.g = graphs;
    this.m = new IPM[7];
    this.m[0] = new IPM_BMP085( (byte)101 );
    this.m[1] = new IPM_MPU6050_HMC5883L( (byte)11 );
    this.m[2] = new IPM_MPU6050( (byte)12 );
    this.m[3] = new IPM_MPU6050( (byte)13 );
    this.m[4] = new IPM_MPU6050( (byte)14 );
    this.m[5] = new IPM_MPU6050( (byte)15 );
    this.m[6] = new IPM_AdafruitIMU9dof( (byte)16 );
    this.atcd = new TriaxialCalibration[7];
    this.atco = new TriaxialCalibration[7];
    this.wtcd = new TriaxialCalibration[7];
    this.wtco = new TriaxialCalibration[7];
    this.mtcd = new TriaxialCalibration[7];
    this.mtco = new TriaxialCalibration[7];
    for(int i=0; i<7; i++){
      this.atcd[i] = new TriaxialCalibration( 0 );
      this.atco[i] = new TriaxialCalibration( 0 );
      this.wtcd[i] = new TriaxialCalibration( 0 );
      this.wtco[i] = new TriaxialCalibration( 0 );
      this.mtcd[i] = new TriaxialCalibration( 0 );
      this.mtco[i] = new TriaxialCalibration( 0 );
    }
    this.atcd[1].set_calibration( 1.0/2048.0 ); //( 9.8*1.0/2048.0 );
    this.wtcd[1].set_calibration( 1.0/16.4 ); //( Math.PI/180.0*1.0/16.4 );
    this.mtcd[1].set_calibration( 1.0/(0.5*(230+1370)) );
    this.atcd[2].set_calibration( 1.0/2048.0 ); //( 9.8*1.0/2048.0 );
    this.wtcd[2].set_calibration( 1.0/16.4 ); //( Math.PI/180.0*1.0/16.4 );
    this.mtcd[2].set_calibration( 0.001465 );
    this.atcd[3].set_calibration( 1.0/2048.0 ); //( 9.8*1.0/2048.0 );
    this.wtcd[3].set_calibration( 1.0/16.4 ); //( Math.PI/180.0*1.0/16.4 );
    this.atcd[4].set_calibration( 1.0/2048.0 ); //( 9.8*1.0/2048.0 );
    this.wtcd[4].set_calibration( 1.0/16.4 ); //( Math.PI/180.0*1.0/16.4 );
    this.atcd[5].set_calibration( 1.0/2048.0 ); //( 9.8*1.0/2048.0 );
    this.wtcd[5].set_calibration( 1.0/16.4 ); //( Math.PI/180.0*1.0/16.4 );
    this.atcd[6].set_calibration( 1.0e-3 ); //( 9.8*1.0/2048.0 );
    this.wtcd[6].set_calibration( 70.0e-3 ); //( Math.PI/180.0*1.0/16.4 );
    this.mtcd[6].set_calibration( 1.0/(0.5*(230+205)) );
    this.atco[1].set_calibration( sketchPath()+"/calibrations/11a.cal" );
    //this.atco[1].change_calibrationUnits( 9.8 );
    this.wtco[1].set_calibration( sketchPath()+"/calibrations/11w.cal" );
    //this.wtco[1].change_calibrationUnits( Math.PI/180.0 );
    this.mtco[1].set_calibration( sketchPath()+"/calibrations/11m.cal" );
    this.atco[2].set_calibration( sketchPath()+"/calibrations/12a.cal" );
    //this.atco[2].change_calibrationUnits( 9.8 );
    this.wtco[2].set_calibration( sketchPath()+"/calibrations/12w.cal" );
    //this.wtco[2].change_calibrationUnits( Math.PI/180.0 );
    this.mtco[2].set_calibration( sketchPath()+"/calibrations/12m.cal" );
    this.atco[3].set_calibration( sketchPath()+"/calibrations/13a.cal" );
    //this.atco[3].change_calibrationUnits( 9.8 );
    this.wtco[3].set_calibration( sketchPath()+"/calibrations/13w.cal" );
    //this.wtco[3].change_calibrationUnits( Math.PI/180.0 );
    this.atco[4].set_calibration( sketchPath()+"/calibrations/14a.cal" );
    //this.atco[4].change_calibrationUnits( 9.8 );
    this.wtco[4].set_calibration( sketchPath()+"/calibrations/14w.cal" );
    //this.wtco[4].change_calibrationUnits( Math.PI/180.0 );
    this.atco[5].set_calibration( sketchPath()+"/calibrations/15a.cal" );
    //this.atco[5].change_calibrationUnits( 9.8 );
    this.wtco[5].set_calibration( sketchPath()+"/calibrations/15w.cal" );
    //this.wtco[5].change_calibrationUnits( Math.PI/180.0 );
    this.atco[6].set_calibration( sketchPath()+"/calibrations/16a.cal" );
    //this.atco[6].change_calibrationUnits( 9.8 );
    this.wtco[6].set_calibration( sketchPath()+"/calibrations/16w.cal" );
    //this.wtco[6].change_calibrationUnits( Math.PI/180.0 );
    this.mtco[6].set_calibration( sketchPath()+"/calibrations/16m.cal" );
    ( new Thread( this ) ).start();
  }
  
  
  // PUBLIC METHODS
  
  public void fastUpdate_serialPortManagers() {
    // first, we check if the number of serial ports has changed
    if( this.NSPM != Serial.list().length ){
      // we wait a bit for the system to update the serial ports
      delay(1000);
      this.update_serialPortManagers();
    }
  }
  
  public synchronized void update_serialPortManagers() {
    // if the number has changed, we redefine the serial ports
    int newNSPM = Serial.list().length;
    SerialPortManager[] auxSPM = new SerialPortManager[newNSPM];
    int newNASPM = 0;
    for(int j=0; j<newNSPM; j++){
      String theName = Serial.list()[j];
      // we check that the serial port is not prohibited (we do not want to mess with the bluetooth)
      if( !this.canWeOpen( theName ) ) continue;
      // we check if the j-th serial port is already opened
      boolean opened = false;
      for(int i=0; i<this.NASPM; i++){
        if( this.SPM[i].is_thisSerialPort( theName ) ){  // if its name is in the list of available serial ports, then it is opened
          auxSPM[newNASPM] = this.SPM[i];
          newNASPM++;
          opened = true;
          break;
        }
      }
      // if it has not been opened, we try to open it (here is where the objects are created)
      if( !opened ){
        try{
          auxSPM[newNASPM] = new SerialPortManager( this.thePApplet , theName );
          newNASPM++;
        }catch( Exception exc ){
        }
      }
    }
    // then, we close the non-used serial ports
    for(int i=0; i<this.NASPM; i++){
      boolean used = false;
      for(int j=0; j<newNASPM; j++){
        if( this.SPM[i].is_thisSerialPort( auxSPM[j].serialPortName ) ){
          used = true;
          break;
        }
      }
      if( !used ){
        //this.SPM[i].stop();  // it will work if we do not stop it
      }
    }
    // finally, we perform the redefinition
    this.SPM = new SerialPortManager[newNASPM];
    for(int i=0; i<newNASPM; i++){
      this.SPM[i] = auxSPM[i];
      System.out.println( this.SPM[i].serialPortName );
    }
    System.out.println();
    this.NASPM = newNASPM;
    this.NSPM = newNSPM;
  }  // end update_serialPorts
  
  public void notify_activity() {
    this.wait = false;
    if( this.waiting ){
      synchronized( this ){
        this.notify();
      }
    }
  }
  
  public void run() {
    while( this.running ){
      //
      switch( this.stateN ){
        case 0:  // we do not have a server running
          try{
            this.wait = false;  // we do not want it to stop in this state
            this.stateN = 1;
          }catch( Exception e ){
            e.printStackTrace();
          }
          break;
        case 1:  // we have a server running
          // first, we manage the serial ports
          this.manage_serial();
          break;
        default:
          this.stateN = 0;
          break;
      }
      //
      if( this.wait ){
        synchronized( this ){
          this.waiting = true;
          try{
            this.wait(1000);  // we wait at most 1 second
          }catch( Exception e ){
            e.printStackTrace();
          }
          this.waiting = false;
        }
      }else{
        this.wait = true;
      }
    }  // end while( this.running )
  }  // end public void run()
  
  void stop(){
    this.running = false;
    this.notify_activity();
  }
  
  
  // PRIVATE METHODS
  
  private double mod( double[] v ) {
    return Math.sqrt( v[0]*v[0] + v[1]*v[1] + v[2]*v[2] );
  }
  
  private void manage_serial() {
    for(int i=0; i<this.NASPM; i++){
      while( this.SPM[i].available() > 0 ){
        byte[] data = this.SPM[i].read();
        if( data != null ){
          double t = System.nanoTime()*1.0e-9;
          switch( data[1] ){
            case 11:
              this.insert_gy88measurement( t , data , 1 );
              break;
            case 101:
              this.insert_gy88measurementP( t , data );
              break;
            case 12:
              switch( data[0] ){
                case 0:  // IPM_MPU6050
                  this.insert_mpu6050measurement( t , data , 2 );
                  break;
                case 1:  // IPM_MPU6050_HMC5883L
                  this.insert_gy88measurement( t , data , 2 );
                  break;
                default:
                  break;
              }
              break;
            case 13:
              this.insert_mpu6050measurement( t , data , 3 );
              break;
            case 14:
              this.insert_mpu6050measurement( t , data , 4 );
              break;
            case 15:
              this.insert_mpu6050measurement( t , data , 5 );
              break;
            case 16:
              this.insert_adafruitIMU9dofMeasurement( t , data );
              break;
            default:
              break;
          }
        }
      }
    }
  }
  
  private void insert_gy88measurement( double t , byte[] data , int index ) {
    this.m[1].set_bytes( data );
    double[] am = ((IPM_MARG)this.m[1]).get_a();
    double[] wm = ((IPM_MARG)this.m[1]).get_w();
    double T = ((IPM_MARG)this.m[1]).get_Ta();
    double[] mm = ((IPM_MARG)this.m[1]).get_m();
    double[] acd = this.atcd[index].get_calibratedMeasurements( am , T );
    double[] wcd = this.wtcd[index].get_calibratedMeasurements( wm , T );
    double[] mcd = this.mtcd[index].get_calibratedMeasurements( mm , T );
    double[] aco = this.atco[index].get_calibratedMeasurements( am , T );
    double[] wco = this.wtco[index].get_calibratedMeasurements( wm , T );
    double[] mco = this.mtco[index].get_calibratedMeasurements( mm , T );
    this.g[0].insert( t , new double[]{ acd[0] , acd[1] , acd[2] , mod(acd) , aco[0] , aco[1] , aco[2] , mod(aco) } );
    this.g[1].insert( t , new double[]{ wcd[0] , wcd[1] , wcd[2] , mod(wcd) , wco[0] , wco[1] , wco[2] , mod(wco) } );
    this.g[2].insert( t , new double[]{ mcd[0] , mcd[1] , mcd[2] , mod(mcd) , mco[0] , mco[1] , mco[2] , mod(mco) } );
    this.g[3].insert( t , new double[]{ T } );
  }
  
  private void insert_gy88measurementP( double t , byte[] data ) {
    this.m[0].set_bytes( data );
    double P = ((IPM_Barometer)this.m[0]).get_p();
    double T = ((IPM_Barometer)this.m[0]).get_Tp();
    this.g[4].insert( t , new double[]{ P , this.get_calibratedPressure( P , T ) } );
    this.g[5].insert( t , new double[]{ T } );
  }
  
  private void insert_mpu6050measurement( double t , byte[] data , int index ) {
    this.m[index].set_bytes( data );
    double[] am = ((IPM_IMU)this.m[index]).get_a();
    double[] wm = ((IPM_IMU)this.m[index]).get_w();
    double T = ((IPM_IMU)this.m[index]).get_Ta();
    double[] acd = this.atcd[index].get_calibratedMeasurements( am , T );
    double[] wcd = this.wtcd[index].get_calibratedMeasurements( wm , T );
    double[] aco = this.atco[index].get_calibratedMeasurements( am , T );
    double[] wco = this.wtco[index].get_calibratedMeasurements( wm , T );
    this.g[0].insert( t , new double[]{ acd[0] , acd[1] , acd[2] , mod(acd) , aco[0] , aco[1] , aco[2] , mod(aco) } );
    this.g[1].insert( t , new double[]{ wcd[0] , wcd[1] , wcd[2] , mod(wcd) , wco[0] , wco[1] , wco[2] , mod(wco) } );
    this.g[3].insert( t , new double[]{ T } );
  }
  
  private void insert_adafruitIMU9dofMeasurement( double t , byte[] data ) {
    this.m[6].set_bytes( data );
    double[] am = ((IPM_MARG)this.m[6]).get_a();
    double[] mm = ((IPM_MARG)this.m[6]).get_m();
    double T = ((IPM_MARG)this.m[6]).get_Ta();
    double[] wm = ((IPM_MARG)this.m[6]).get_w();
    double Tw = ((IPM_MARG)this.m[6]).get_Tw();
    double[] acd = this.atcd[6].get_calibratedMeasurements( am , T );
    double[] mcd = this.mtcd[6].get_calibratedMeasurements( mm , T );
    double[] wcd = this.wtcd[6].get_calibratedMeasurements( wm , Tw );
    double[] aco = this.atco[6].get_calibratedMeasurements( am , T );
    double[] mco = this.mtco[6].get_calibratedMeasurements( mm , T );
    double[] wco = this.wtco[6].get_calibratedMeasurements( wm , Tw );
    this.g[0].insert( t , new double[]{ acd[0] , acd[1] , acd[2] , mod(acd) , aco[0] , aco[1] , aco[2] , mod(aco) } );
    this.g[1].insert( t , new double[]{ wcd[0] , wcd[1] , wcd[2] , mod(wcd) , wco[0] , wco[1] , wco[2] , mod(wco) } );
    this.g[2].insert( t , new double[]{ mcd[0] , mcd[1] , mcd[2] , mod(mcd) , mco[0] , mco[1] , mco[2] , mod(mco) } );
    this.g[3].insert( t , new double[]{ T } );
    this.g[5].insert( t , new double[]{ Tw } );
  }
  
  protected double get_calibratedPressure( double P , double T ) {
    return 0.06030297719749*P/Math.pow( T , -0.377558386849623 );
  }
  
  private boolean canWeOpen( String name ) {
    for(int i=0; i<this.dontOpen.length; i++){
      if( name.equals( this.dontOpen[i] ) ){
        return false;
      }
    }
    return true;
  }
  
}
