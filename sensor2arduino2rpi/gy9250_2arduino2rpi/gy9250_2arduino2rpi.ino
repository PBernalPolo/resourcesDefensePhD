/*
 * Copyright (C) 2017 P.Bernal-Polo
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// TO CHANGE THE OPTIMIZATION LEVEL, edit:
// /opt/arduino-1.8.5/hardware/arduino/avr/platform.txt
// and substitute:
// compiler.c.flags=-c -g -Os -w -ffunction-sections -fdata-sections -MMD
// compiler.cpp.flags=-c -g -Os -w -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -MMD
// by:
// compiler.c.flags=-c -g -O3 -w -ffunction-sections -fdata-sections -MMD
// compiler.cpp.flags=-c -g -O3 -w -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -MMD


//#define DEBUG_MODE
#define DEVICE_ID_AGM 12
#define LED_PIN 13


// SparkFunMPU9250-DMP must be installed as libraries, or else the .cpp/.h files
// for both classes must be in the include path of your project
#include <SparkFunMPU9250-DMP.h>
#include "IPM_MPU6050_HMC5883L.h"
#include "MessageManager.h"
#include <avr/wdt.h>  // Arduino watchdog to reset if it gets stuck


MPU9250_DMP agm;

IPM_MPU6050_HMC5883L mAGM( DEVICE_ID_AGM );
MessageManager MM( 2 );


void setup() {
  // first of all, we reset the watchdog, and we enable it
  wdt_reset();
  wdt_enable(WDTO_1S);

  // configure Arduino LED pin for output, and activate it during setup
  pinMode( LED_PIN , OUTPUT );
  digitalWrite( LED_PIN , true );
  
  // initialize serial communication
  Serial.begin(115200);
  while( !Serial );
  
  // Call imu.begin() to verify communication with and
  // initialize the MPU-9250 to it's default values.
  // Most functions return an error code - INV_SUCCESS (0)
  // indicates the IMU was present and successfully set up
  if( agm.begin() != INV_SUCCESS ){
    while( 1 ){
      Serial.println("Unable to communicate with MPU-9250");
      Serial.println("Check connections, and try again.");
      Serial.println();
      delay(2000);
    }
  }
  
  // Use setSensors to turn on or off MPU-9250 sensors.
  // Any of the following defines can be combined:
  // INV_XYZ_GYRO, INV_XYZ_ACCEL, INV_XYZ_COMPASS,
  // INV_X_GYRO, INV_Y_GYRO, or INV_Z_GYRO
  // Enable all sensors:
  agm.setSensors( INV_XYZ_GYRO | INV_XYZ_ACCEL | INV_XYZ_COMPASS );
  
  // Use setGyroFSR() and setAccelFSR() to configure the
  // gyroscope and accelerometer full scale ranges.
  // Gyro options are +/- 250, 500, 1000, or 2000 dps
  agm.setGyroFSR( 2000 );  // Set gyro to 2000 dps
  // Accel options are +/- 2, 4, 8, or 16 g
  agm.setAccelFSR( 16 );  // Set accel to +/-2g
  // Note: the MPU-9250's magnetometer FSR is set at 
  // +/- 4912 uT (micro-tesla's)
  
  // The sample rate of the accel/gyro can be set using
  // setSampleRate. Acceptable values range from 4Hz to 1kHz
  agm.setSampleRate( 1000 );  // Set sample rate to 10Hz
  
  // Likewise, the compass (magnetometer) sample rate can be
  // set using the setCompassSampleRate() function.
  // This value can range between: 1-100Hz
  agm.setCompassSampleRate( 100 );  // Set mag rate to 10Hz
  
  // we wait a little for the sensor to be configured
  delay( 300 );
  
  // test
  //test_measurementFrequency();
  
  // we deactivate the led before entering the loop
  digitalWrite( LED_PIN , false );
}


void loop() {
  // first, we reset the watchdog
  wdt_reset();
  
  // dataReady() checks to see if new accel/gyro data
  // is available. It will return a boolean true or false
  // (New magnetometer data cannot be checked, as the library
  //  runs that sensor in single-conversion mode.)
  if ( agm.dataReady() ){
    // Call update() to update the imu objects sensor data.
    // You can specify which sensors to update by combining
    // UPDATE_ACCEL, UPDATE_GYRO, UPDATE_COMPASS, and/or
    // UPDATE_TEMPERATURE.
    // (The update function defaults to accel, gyro, compass,
    //  so you don't have to specify these values.)
    agm.update( UPDATE_ACCEL | UPDATE_GYRO | UPDATE_TEMP | UPDATE_COMPASS );
  }
  
  // we set the information packet
  mAGM.set_a( agm.ax , agm.ay , agm.az );
  mAGM.set_w( agm.gx , agm.gy , agm.gz );
  mAGM.set_T( agm.temp );
  mAGM.set_m( agm.my , agm.mx , -agm.mz );  // according to the datasheet
  
#if defined DEBUG_MODE
  Serial.print( agm.ax );   Serial.print("\t");   Serial.print( agm.ay );   Serial.print("\t");   Serial.print( agm.az );   Serial.print("\t\t");
  Serial.print( agm.gx );   Serial.print("\t");   Serial.print( agm.gy );   Serial.print("\t");   Serial.print( agm.gz );   Serial.print("\t\t");
  Serial.print( agm.my );   Serial.print("\t");   Serial.print( agm.mx );   Serial.print("\t");   Serial.print( -agm.mz );   Serial.print("\t\t");
  Serial.print( agm.temperature );
  Serial.println();
#else
  // we prepare the message
  int8_t* toWrite = MM.prepare_message( mAGM.get_length() , mAGM.get_bytes() );
  // and we send it
  Serial.write( (byte*)toWrite , MM.get_messageOutLength() );
#endif*/
}


void test_measurementFrequency() {
  Serial.println( "Test started..." );
  int N = 1000;
  float dt0 = 0.0;
  float dt1 = 0.0;
  float dt2 = 0.0;
  float dt3 = 0.0;
  float dt4 = 0.0;
  float dt5 = 0.0;
  float dt6 = 0.0;
  for(int i=0; i<N; i++){
    unsigned long t0 = micros();
    agm.update( UPDATE_ACCEL );
    unsigned long t1 = micros();
    agm.update( UPDATE_GYRO );
    unsigned long t2 = micros();
    agm.update( UPDATE_COMPASS );
    unsigned long t3 = micros();
    agm.update( UPDATE_TEMP );
    unsigned long t4 = micros();
    agm.update( UPDATE_ACCEL | UPDATE_GYRO | UPDATE_TEMP | UPDATE_COMPASS );
    unsigned long t5 = micros();
    dt0 += t1-t0;
    dt1 += t2-t1;
    dt2 += t3-t2;
    dt3 += t4-t3;
    dt4 += t5-t4;
  }
  Serial.print( 1.0e6/(dt0/N) , 6 );
  Serial.print( " " );
  Serial.print( 1.0e6/(dt1/N) , 6 );
  Serial.print( " " );
  Serial.print( 1.0e6/(dt2/N) , 6 );
  Serial.print( " " );
  Serial.print( 1.0e6/(dt3/N) , 6 );
  Serial.print( " " );
  Serial.print( 1.0e6/(dt4/N) , 6 );
  Serial.println();
  Serial.println( "Test finished." );
}
