
// we import the serial library
import processing.serial.*;


boolean stateL = true;
boolean stateP = true;
boolean stateC = true;
boolean stateCal = true;
color bgColor = 0;

Graphic ga;
Graphic gw;
Graphic gm;
Graphic gt;
Graphic gp;
Graphic gtp;

CommunicationManager cm;


void setup() {
  //size( 1000 , 1000 , P3D );  // P2D is slow!!!
  fullScreen( P3D , SPAN );
  smooth( 8 );
  
  int dx = (int)(0.08*width);
  int dy = (int)(0.05*height);
  int Dx = width/3;
  int Dy = height/2;
  
  int alpha = 200;
  
  ga = new Graphic( dx , dy , Dx-0.5*dx , Dy-2*dy );
  ga.set_title( "Accelerometer" );
  ga.set_ylabel( "acceleration (g)" ); //( "acceleration (raw)" );
  ga.set_dxgrid( 2.0 );
  //ga.set_dygrid( 4.0 ); //( 1<<11 );
  ga.set_colors( new color[]{ color(255,0,0,alpha) , color(0,255,0,alpha) , color(0,0,255,alpha) , color(255,255,255,alpha) , color(255,0,0) , color(0,255,0) , color(0,0,255) , color(255,255,255) } );
  ga.set_visibleData( new boolean[]{ true , true , true , false , false , false , false , false } );
  
  gw = new Graphic( Dx+dx , dy , 2*Dx-0.5*dx , Dy-2*dy );
  gw.set_title( "Gyroscope" );
  gw.set_ylabel( "angular velocity (o/s)" ); //( "angular velocity (raw)" );
  gw.set_dxgrid( 2.0 );
  //gw.set_dygrid( 500.0 ); //( 1<<13 );
  gw.set_colors( new color[]{ color(255,0,0,alpha) , color(0,255,0,alpha) , color(0,0,255,alpha) , color(255,255,255,alpha) , color(255,0,0) , color(0,255,0) , color(0,0,255) , color(255,255,255) } );
  gw.set_visibleData( new boolean[]{ true , true , true , false , false , false , false , false } );
  
  gm = new Graphic( 2*Dx+dx , dy , 3*Dx-0.5*dx , Dy-2*dy );
  gm.set_title( "Magnetometer" );
  gm.set_ylabel( "magnetic field (G)" ); //( "magnetic field (raw)" );
  gm.set_dxgrid( 2.0 );
  //gm.set_dygrid( 4.0 );  //( 1<<7 );
  gm.set_colors( new color[]{ color(255,0,0,alpha) , color(0,255,0,alpha) , color(0,0,255,alpha) , color(255,255,255,alpha) , color(255,0,0) , color(0,255,0) , color(0,0,255) , color(255,255,255) } );
  gm.set_visibleData( new boolean[]{ true , true , true , false , false , false , false , false } );
  
  gt = new Graphic( dx , Dy+dy , Dx-0.5*dx , 2*Dy-2*dy );
  gt.set_title( "Temperature (A/G/M)" );
  gt.set_ylabel( "temperature (raw)" );
  gt.set_dxgrid( 2.0 );
  gt.set_dygrid( 1<<11 );
  gt.set_colors( new color[]{ color(255,140,0) } );
  
  gp = new Graphic( Dx+dx , Dy+dy , 2*Dx-0.5*dx , 2*Dy-2*dy );
  gp.set_title( "Barometer" );
  gp.set_ylabel( "pressure (raw)" );
  gp.set_dxgrid( 2.0 );
  //gp.set_dygrid( (1<<16) );
  gp.set_colors( new color[]{ color(255,69,0,alpha) , color(255,69,0) } );
  gp.set_visibleData( new boolean[]{ true , false } );
  
  gtp = new Graphic( 2*Dx+dx , Dy+dy , 3*Dx-0.5*dx , 2*Dy-2*dy );
  gtp.set_title( "Temperature (barometer)" );
  gtp.set_ylabel( "temperature (raw)" );
  gtp.set_dxgrid( 2.0 );
  gtp.set_dygrid( (1<<12) );
  gtp.set_colors( new color[]{ color(255,255,0) } );
  
  cm = new CommunicationManager( this , new Graphic[]{ ga , gw , gm , gt , gp , gtp } );
}


void draw() {
  background( bgColor );
  cm.fastUpdate_serialPortManagers();
  
//  double[] d = new double[N];
//  for(int i=0; i<N; i++){
//    d[i] = sin(frameCount*0.01*(i+1));
//  }
  
//  g.insert( frameCount , d );
//  g.set_xOffset( -frameCount );
  
  double t = System.nanoTime()*1.0e-9;
  
  ga.set_xOffset( -t );
  gw.set_xOffset( -t );
  gm.set_xOffset( -t );
  gt.set_xOffset( -t );
  gp.set_xOffset( -t );
  gtp.set_xOffset( -t );
  
  if( stateL ){
    ga.set_ylim( -16.0 , 16.0 ); //( -(1<<13) , (1<<13) );
    ga.set_drawLimY( false );
    gw.set_ylim( -2000.0 , 2000.0 ); //( -(1<<15) , (1<<15) );
    gw.set_drawLimY( false );
    gm.set_ylim( -8.0 , 8.0 ); //( -(1<<9) , (1<<9) );
    gm.set_drawLimY( false );
    gt.set_ylim( -(1<<13) , (1<<13) );
    gt.set_drawLimY( false );
    gp.set_ylim( (1<<18) , (1<<19) );
    gp.set_drawLimY( false );
    gtp.set_ylim( (1<<14) , (1<<15) );
    gtp.set_drawLimY( false );
    set_dygridsFull();
  }else{
    ga.set_ylimFit();
    ga.set_drawLimY( true );
    gw.set_ylimFit();
    gw.set_drawLimY( true );
    gm.set_ylimFit();
    gm.set_drawLimY( true );
    gt.set_ylimFit();
    gt.set_drawLimY( true );
    gp.set_ylimFit();
    gp.set_drawLimY( true );
    gtp.set_ylimFit();
    gtp.set_drawLimY( true );
    set_dygridsLim();
  }
  
  if( stateCal ){
    gp.set_ylabel( "pressure (raw)" );
    gp.set_dygrid( (1<<14) );
  }else{
    gp.set_ylabel( "pressure (Pa)" );
    gp.set_dygrid( 5000.0 );
  }
  
  ga.draw();
  gw.draw();
  gm.draw();
  gt.draw();
  gp.draw();
  gtp.draw();
  
//  println( frameRate );
}


void set_dygridsFull() {
  ga.set_dygrid( 4.0 ); //( 1<<11 );
  gw.set_dygrid( 500.0 ); //( 1<<13 );
  gm.set_dygrid( 4.0 );  //( 1<<7 );
  if( stateCal ){
    gp.set_ylim( (1<<15) , (1<<17) );
  }else{
    gp.set_ylim( 97000.0 , 130000.0 );
  }
}


void set_dygridsLim() {
  ga.set_dygrid( 0.2 ); //( 1<<11 );
  gw.set_dygrid( 100.0 ); //( 1<<13 );
  gm.set_dygrid( 0.1 );  //( 1<<7 );
}


void keyPressed() {
  switch( key ) {
    case 'p':
      if( stateP ){
        noLoop();
      }else{
        loop();
      }
      stateP = !stateP;
      break;
    case 'l':
      stateL = !stateL;
      break;
    case 't':
      ga.set_axisColor( bgColor );
      gw.set_axisColor( bgColor );
      gm.set_axisColor( bgColor );
      gt.set_axisColor( bgColor );
      gp.set_axisColor( bgColor );
      gtp.set_axisColor( bgColor );
      color[] dc = ga.get_colors();
      dc[3] = bgColor;
      ga.set_colors( dc );
      gw.set_colors( dc );
      gm.set_colors( dc );
      if( stateC ){
        bgColor = color( 255 , 255 , 255 );
        color gridColor = color( 200 , 200 , 200 );
        ga.set_gridColor( gridColor );
        gw.set_gridColor( gridColor );
        gm.set_gridColor( gridColor );
        gt.set_gridColor( gridColor );
        gp.set_gridColor( gridColor );
        gtp.set_gridColor( gridColor );
      }else{
        bgColor = color( 0 , 0 , 0 );
        color gridColor = color( 100 , 100 , 100 );
        ga.set_gridColor( gridColor );
        gw.set_gridColor( gridColor );
        gm.set_gridColor( gridColor );
        gt.set_gridColor( gridColor );
        gp.set_gridColor( gridColor );
        gtp.set_gridColor( gridColor );
      }
      stateC = !stateC;
      break;
    case '+':
      ga.set_dataStrokeWeight( ga.get_dataStrokeWeight()+0.3 );
      gw.set_dataStrokeWeight( gw.get_dataStrokeWeight()+0.3 );
      gm.set_dataStrokeWeight( gm.get_dataStrokeWeight()+0.3 );
      gt.set_dataStrokeWeight( gt.get_dataStrokeWeight()+0.3 );
      gp.set_dataStrokeWeight( gp.get_dataStrokeWeight()+0.3 );
      gtp.set_dataStrokeWeight( gtp.get_dataStrokeWeight()+0.3 );
      break;
    case '-':
      ga.set_dataStrokeWeight( ga.get_dataStrokeWeight()-0.3 );
      gw.set_dataStrokeWeight( gw.get_dataStrokeWeight()-0.3 );
      gm.set_dataStrokeWeight( gm.get_dataStrokeWeight()-0.3 );
      gt.set_dataStrokeWeight( gt.get_dataStrokeWeight()-0.3 );
      gp.set_dataStrokeWeight( gp.get_dataStrokeWeight()-0.3 );
      gtp.set_dataStrokeWeight( gtp.get_dataStrokeWeight()-0.3 );
      break;
    case 'c':{
      boolean[] vd = ga.get_visibleData();
      boolean[] vd2 = new boolean[8];
      for(int i=0; i<4; i++){
        vd2[i] = vd[i+4];
        vd2[i+4] = vd[i];
      }
      ga.set_visibleData( vd2 );
      gw.set_visibleData( vd2 );
      gm.set_visibleData( vd2 );
      vd = gp.get_visibleData();
      vd[0] = !vd[0];
      vd[1] = !vd[1];
      gp.set_visibleData( vd );
      stateCal = !stateCal;
      }break;
    case 'v':{
      boolean[] vd = ga.get_visibleData();
      if( stateCal ){
        for(int i=0; i<3; i++){
          vd[i] = !vd[i];
        }
      }else{
        for(int i=4; i<7; i++){
          vd[i] = !vd[i];
        }
      }
      ga.set_visibleData( vd );
      gw.set_visibleData( vd );
      gm.set_visibleData( vd );
      }break;
    case 'm':{
      boolean[] vd = ga.get_visibleData();
      if( stateCal ){
        vd[3] = !vd[3];
      }else{
        vd[7] = !vd[7];
      }
      ga.set_visibleData( vd );
      gw.set_visibleData( vd );
      gm.set_visibleData( vd );
      }break;
    default:
      break;
  }
}




void serialEvent( Serial p ) { 
  cm.notify_activity();
}


void exit() {
  if( cm != null ){
    cm.stop();
  }
  super.exit();
}
