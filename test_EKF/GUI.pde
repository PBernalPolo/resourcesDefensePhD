/*
 * Copyright (C) 2019 P.Bernal-Polo
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

/**
 *
 * @author P.Bernal-Polo
 */

import controlP5.*;  // the wonderful GUI library for processing


// this class contains all GUI elements and implements the methods to link them with external parameters
public class GUI {
  
  // VARIABLES
  // the ControlP5 object
  private ControlP5 cp5;
  
  // state variables
  private float mp;
  private float Qs;
  private float Rs;
  private boolean showEKF;
  private float Qekf;
  private float Rekf;
  private boolean showUKFllt;
  private float QukfLLT;
  private float RukfLLT;
  private float W0;
  private boolean showUKFldlt;
  private float QukfLDLT;
  private float RukfLDLT;
  private float D0;
  
  // GUI elements
  private Slider mpSlider;
  private Slider qsSlider;
  private Slider rsSlider;
  private Toggle showEKFtoggle;
  private Slider qEKFslider;
  private Slider rEKFslider;
  private Toggle showUKFlltToggle;
  private Slider W0slider;
  private Slider qUKFlltSlider;
  private Slider rUKFlltSlider;
  private Toggle showUKFldltToggle;
  private Slider D0slider;
  private Slider qUKFldltSlider;
  private Slider rUKFldltSlider;
  
  
  // CONSTRUCTORS
  
  public GUI( PApplet thePApplet ){
    // GUI elements parameters
    float alphaGUI = 0.5*( width + height );
    float elementsSeparation = alphaGUI/15.0;  // distance from GUI elements to borders
    float slidersWidth = alphaGUI/50;
    float slidersHeight = 0.2*(height-elementsSeparation)-elementsSeparation;
    
    // we create the ControlP5 object
    this.cp5 = new ControlP5( thePApplet );
    
    this.mp = 1.0;
    this.Qs = 1.0e-1;
    this.Rs = 5.0e-1;
    this.showEKF = true;
    this.Qekf = 1.0e-1;
    this.Rekf = 5.0e-1;
    this.showUKFllt = false;
    this.QukfLLT = 1.0e-1;
    this.RukfLLT = 5.0e-1;
    this.W0 = 1.0/5.0;
    this.showUKFldlt = false;
    this.QukfLDLT = 1.0e-1;
    this.RukfLDLT = 5.0e-1;
    this.D0 = 1.0/5.0;
    
    // we create the sliders
    this.mpSlider = this.cp5.addSlider( "mpSlider" )
                            .setBroadcast(false)
                            .setLabel( "period" )
                            .setPosition( width-3*(elementsSeparation+slidersWidth) , elementsSeparation )
                            .setSize( (int)slidersWidth , (int)slidersHeight )
                            .setRange( 1.0e-1 , 1.0e1 )
                            .setValue( this.mp )
                            .setLock( false )
                            .plugTo( this , "set_mp" )
                            .setBroadcast(true)
                            ;
    this.mpSlider.getCaptionLabel().align( ControlP5.LEFT , ControlP5.BOTTOM_OUTSIDE );
    color foregroundColor = mpSlider.getColor().getForeground();
    color backgroundColor = mpSlider.getColor().getBackground();
    this.mpSlider.setColorLabel( backgroundColor )
                 .setColorValue( backgroundColor );
    
    this.qsSlider = this.cp5.addSlider( "qsSlider" )
                            .setBroadcast(false)
                            .setLabel( "Qs" )
                            .setColorLabel( backgroundColor )
                            .setColorValue( backgroundColor )
                            .setPosition( width-2*(elementsSeparation+slidersWidth) , elementsSeparation )
                            .setSize( (int)slidersWidth , (int)slidersHeight )
                            .setRange( 0.0 , 1.0e0 )
                            .setValue( this.Qs )
                            .setLock( false )
                            .plugTo( this , "set_Qs" )
                            .setBroadcast(true)
                            ;
    this.qsSlider.getCaptionLabel().align( ControlP5.LEFT , ControlP5.BOTTOM_OUTSIDE );
    
    this.rsSlider = cp5.addSlider( "rsSlider" )
                       .setBroadcast(false)
                       .setLabel( "Rs" )
                       .setColorLabel( backgroundColor )
                       .setColorValue( backgroundColor )
                       .setPosition( width-(elementsSeparation+slidersWidth) , elementsSeparation )
                       .setSize( (int)slidersWidth , (int)slidersHeight )
                       .setRange( 0.0 , 1.0e0 )
                       .setValue( this.Rs )
                       .plugTo( this , "set_Rs" )
                       .setBroadcast(true)
                       ;
    this.rsSlider.getCaptionLabel().align( ControlP5.LEFT , ControlP5.BOTTOM_OUTSIDE );
    
    this.showEKFtoggle = this.cp5.addToggle( "showEKFtoggle" )
                             .setLabel( "EKF" )
                             .setPosition( width-3*(elementsSeparation+slidersWidth) , 0.25*height+elementsSeparation )
                             .setSize( (int)slidersWidth , (int)slidersWidth )
                             .setValue( this.showEKF )
                             .plugTo( this , "set_showEKF" )
                             ;
    this.showEKFtoggle.getCaptionLabel().align( ControlP5.LEFT , ControlP5.BOTTOM_OUTSIDE );
    this.showEKFtoggle.setColorLabel( backgroundColor )
                      .setColorValue( backgroundColor );
    
    this.qEKFslider = this.cp5.addSlider( "qEKFslider" )
                            .setBroadcast(false)
                            .setLabel( "Q EKF" )
                            .setColorLabel( backgroundColor )
                            .setColorValue( backgroundColor )
                            .setPosition( width-2*(elementsSeparation+slidersWidth) , 0.25*height+elementsSeparation )
                            .setSize( (int)slidersWidth , (int)slidersHeight )
                            .setRange( 0.0 , 1.0e0 )
                            .setValue( this.Qekf )
                            .setLock( false )
                            .plugTo( this , "set_Qekf" )
                            .setBroadcast(true)
                            ;
    this.qEKFslider.getCaptionLabel().align( ControlP5.LEFT , ControlP5.BOTTOM_OUTSIDE );
    
    this.rEKFslider = cp5.addSlider( "rEKFslider" )
                       .setBroadcast(false)
                       .setLabel("R EKF")
                       .setColorLabel( backgroundColor )
                       .setColorValue( backgroundColor )
                       .setPosition( width-(elementsSeparation+slidersWidth) , 0.25*height+elementsSeparation )
                       .setSize( (int)slidersWidth , (int)slidersHeight )
                       .setRange( 0.0 , 1.0e0 )
                       .setValue( this.Rekf )
                       .plugTo( this , "set_Rekf" )
                       .setBroadcast(true)
                       ;
    this.rEKFslider.getCaptionLabel().align( ControlP5.LEFT , ControlP5.BOTTOM_OUTSIDE );
    
    this.showUKFlltToggle = this.cp5.addToggle( "showUKFlltToggle" )
                                .setLabel( "UKF LLT" )
                                .setPosition( width-3*(elementsSeparation+slidersWidth) , 0.5*height+elementsSeparation )
                                .setSize( (int)slidersWidth , (int)slidersWidth )
                                .setValue( this.showUKFllt )
                                .plugTo( this , "set_showUKFllt" )
                                ;
    this.showUKFlltToggle.getCaptionLabel().align( ControlP5.LEFT , ControlP5.BOTTOM_OUTSIDE );
    this.showUKFlltToggle.setColorLabel( backgroundColor )
                         .setColorValue( backgroundColor );
    
    this.W0slider = this.cp5.addSlider( "W0slider" )
                        .setBroadcast(false)
                        .setLabel( "W0" )
                        .setColorLabel( backgroundColor )
                        .setColorValue( backgroundColor )
                        .setPosition( width-3*(elementsSeparation+slidersWidth) , 0.5*height+0.7*slidersHeight+elementsSeparation )
                        .setSize( (int)slidersWidth , (int)(0.3*slidersHeight) )
                        .setRange( 0.0 , 1.0-1.0e-6 )
                        .setValue( this.W0 )
                        .setLock( false )
                        .plugTo( this , "set_W0" )
                        .setBroadcast(true)
                        ;
    this.W0slider.getCaptionLabel().align( ControlP5.LEFT , ControlP5.BOTTOM_OUTSIDE );
    
    this.qUKFlltSlider = this.cp5.addSlider( "qUKFlltSlider" )
                             .setBroadcast(false)
                             .setLabel( "Q UKF LLT" )
                             .setColorLabel( backgroundColor )
                             .setColorValue( backgroundColor )
                             .setPosition( width-2*(elementsSeparation+slidersWidth) , 0.5*height+elementsSeparation )
                             .setSize( (int)slidersWidth , (int)slidersHeight )
                             .setRange( 0.0 , 1.0e0 )
                             .setValue( this.QukfLLT )
                             .setLock( false )
                             .plugTo( this , "set_QukfLLT" )
                             .setBroadcast(true)
                             ;
    this.qUKFlltSlider.getCaptionLabel().align( ControlP5.LEFT , ControlP5.BOTTOM_OUTSIDE );
    
    this.rUKFlltSlider = cp5.addSlider( "rUKFlltSlider" )
                            .setBroadcast(false)
                            .setLabel("R UKF LLT")
                            .setColorLabel( backgroundColor )
                            .setColorValue( backgroundColor )
                            .setPosition( width-(elementsSeparation+slidersWidth) , 0.5*height+elementsSeparation )
                            .setSize( (int)slidersWidth , (int)slidersHeight )
                            .setRange( 0.0 , 1.0e0 )
                            .setValue( this.RukfLLT )
                            .plugTo( this , "set_RukfLLT" )
                            .setBroadcast(true)
                            ;
    this.rUKFlltSlider.getCaptionLabel().align( ControlP5.LEFT , ControlP5.BOTTOM_OUTSIDE );
    
    this.showUKFldltToggle = this.cp5.addToggle( "showUKFldltToggle" )
                                 .setLabel( "UKF LDLT" )
                                 .setPosition( width-3*(elementsSeparation+slidersWidth) , 0.75*height+elementsSeparation )
                                 .setSize( (int)slidersWidth , (int)slidersWidth )
                                 .setValue( this.showUKFldlt )
                                 .plugTo( this , "set_showUKFldlt" )
                                 ;
    this.showUKFldltToggle.getCaptionLabel().align( ControlP5.LEFT , ControlP5.BOTTOM_OUTSIDE );
    this.showUKFldltToggle.setColorLabel( backgroundColor )
                          .setColorValue( backgroundColor );
    
    this.D0slider = this.cp5.addSlider( "D0slider" )
                        .setBroadcast(false)
                        .setLabel( "D0" )
                        .setColorLabel( backgroundColor )
                        .setColorValue( backgroundColor )
                        .setPosition( width-3*(elementsSeparation+slidersWidth) , 0.75*height+0.7*slidersHeight+elementsSeparation )
                        .setSize( (int)slidersWidth , (int)(0.3*slidersHeight) )
                        .setRange( 0.0 , 1.0-1.0e-6 )
                        .setValue( this.D0 )
                        .setLock( false )
                        .plugTo( this , "set_D0" )
                        .setBroadcast(true)
                        ;
    this.D0slider.getCaptionLabel().align( ControlP5.LEFT , ControlP5.BOTTOM_OUTSIDE );
    
    this.qUKFldltSlider = this.cp5.addSlider( "qUKFldltSlider" )
                              .setBroadcast(false)
                              .setLabel( "Q UKF LDLT" )
                              .setColorLabel( backgroundColor )
                              .setColorValue( backgroundColor )
                              .setPosition( width-2*(elementsSeparation+slidersWidth) , 0.75*height+elementsSeparation )
                              .setSize( (int)slidersWidth , (int)slidersHeight )
                              .setRange( 0.0 , 1.0e0 )
                              .setValue( this.QukfLLT )
                              .setLock( false )
                              .plugTo( this , "set_QukfLLT" )
                              .setBroadcast(true)
                              ;
    this.qUKFldltSlider.getCaptionLabel().align( ControlP5.LEFT , ControlP5.BOTTOM_OUTSIDE );
    
    this.rUKFldltSlider = cp5.addSlider( "rUKFldltSlider" )
                             .setBroadcast(false)
                             .setLabel("R UKF LDLT")
                             .setColorLabel( backgroundColor )
                             .setColorValue( backgroundColor )
                             .setPosition( width-(elementsSeparation+slidersWidth) , 0.75*height+elementsSeparation )
                             .setSize( (int)slidersWidth , (int)slidersHeight )
                             .setRange( 0.0 , 1.0e0 )
                             .setValue( this.RukfLDLT )
                             .plugTo( this , "set_RukfLDLT" )
                             .setBroadcast(true)
                             ;
    this.rUKFldltSlider.getCaptionLabel().align( ControlP5.LEFT , ControlP5.BOTTOM_OUTSIDE );
    
  }
  
  
  // PUBLIC METHODS
  
  public void set_mp( float theValue ) {
    this.mp = theValue;
  }
  
  public void set_Qs( float theValue ) {
    this.Qs = theValue;
  }
  
  public void set_Rs( float theValue ) {
    this.Rs = theValue;
  }
  
  public void set_showEKF( boolean theValue ) {
    this.showEKF = theValue;
  }
  
  public void set_Qekf( float theValue ) {
    this.Qekf = theValue;
  }
  
  public void set_Rekf( float theValue ) {
    this.Rekf = theValue;
  }
  
  public void set_showUKFllt( boolean theValue ) {
    this.showUKFllt = theValue;
  }
  
  public void set_W0( float theValue ) {
    this.W0 = theValue;
  }
  
  public void set_QukfLLT( float theValue ) {
    this.QukfLLT = theValue;
  }
  
  public void set_RukfLLT( float theValue ) {
    this.RukfLLT = theValue;
  }
  
  public void set_showUKFldlt( boolean theValue ) {
    this.showUKFldlt = theValue;
  }
  
  public void set_D0( float theValue ) {
    this.D0 = theValue;
  }
  
  public void set_QukfLDLT( float theValue ) {
    this.QukfLDLT = theValue;
  }
  
  public void set_RukfLDLT( float theValue ) {
    this.RukfLDLT = theValue;
  }
  
  public double get_mp() {
    return this.mp;
  }
  
  public double get_Qs() {
    return this.Qs;
  }
  
  public double get_Rs() {
    return this.Rs;
  }
  
  public boolean get_showEKF() {
    return this.showEKF;
  }
  
  public double get_Qekf() {
    return this.Qekf;
  }
  
  public double get_Rekf() {
    return this.Rekf;
  }
  
  public boolean get_showUKFllt() {
    return this.showUKFllt;
  }
  
  public double get_W0() {
    return this.W0;
  }
  
  public double get_QukfLLT() {
    return this.QukfLLT;
  }
  
  public double get_RukfLLT() {
    return this.RukfLLT;
  }
  
  public boolean get_showUKFldlt() {
    return this.showUKFldlt;
  }
  
  public double get_D0() {
    return this.D0;
  }
  
  public double get_QukfLDLT() {
    return this.QukfLDLT;
  }
  
  public double get_RukfLDLT() {
    return this.RukfLDLT;
  }
  
}
