
public class Graphic {
  
  // PRIVATE VARIABLES
  // booleans
  private boolean drawAxis;
  private boolean drawGrid;
  private boolean drawLabels;
  private boolean drawLimY;
  // axis positions
  private float xi;  // x left
  private float yi;  // y bottom
  private float xf;  // x right
  private float yf;  // y top
  // values limits
  private double xli;  // x min
  private double xlf;  // x max
  private double yli;  // y min
  private double ylf;  // y max
  // transformation variables ( xm  =  a*x + b )
  private double ax;
  private double bx;
  private double ay;
  private double by;
  // offsets
  private double xOffset;
  private double yOffset;
  // grid jumps
  private double dxgrid;
  private double dygrid;
  private float dygridWidth;  // width of the y labels
  // data variables
  private int n;  // number of data packets included until now
  private int c;  // counter
  private double[] datx;
  private double[][] daty;
  private boolean[] datV;  // visibility of each variable
  // colors
  private color axisColor;
  private color gridColor;
  private color[] datcol;
  // strokeWeights
  private float axisSW;
  private float gridSW;
  private float dataSW;
  // labels
  private String title;
  private String xlabel;
  private String ylabel;
  
  
  // CONSTRUCTORS
  
  public Graphic( float xi0 , float yi0 , float xf0 , float yf0 ) {
    this.xi = xi0;
    this.yi = yi0;
    this.xf = xf0;
    this.yf = yf0;
    this.datx = new double[0];
    this.daty = new double[0][0];
    this.datcol = new color[0];
    this.datV = new boolean[0];
    this.set_defaultConfig();
  }
  
  
  // PUBLIC METHODS
  
  public void set_position( float xi0 , float yi0 , float xf0 , float yf0 ) {
    this.xi = xi0;
    this.yi = yi0;
    this.xf = xf0;
    this.yf = yf0;
  }
  
  public void set_dataStorageLimit( int N ) {
    this.change_dataDimension( this.daty.length , N );
  }
  
  public void set_dxgrid( double d ) {
    if( d > 0.0 ){
      this.dxgrid = d;
    }else{
      System.out.println( "[Graphic] set_xgridJump: jump must be greater than 0." );
    }
  }
  
  public void set_dygrid( double d ) {
    if( d > 0.0 ){
      this.dygrid = d;
      this.dygridWidth = 1.5*textWidth( String.format( "%.1f" , this.dygrid ) );
    }else{
      System.out.println( "[Graphic] set_ygridJump: jump must be greater than 0." );
    }
  }
  
  public void set_title( String t ) {
    this.title = t;
  }
  
  public void set_xlabel( String l ) {
    this.xlabel = "\n" + l;
  }
  
  public void set_ylabel( String l ) {
    this.ylabel = l;
  }
  
  public void set_axisColor( color c ) {
    this.axisColor = c;
  }
  
  public void set_gridColor( color c ) {
    this.gridColor = c;
  }
  
  public void set_visibleAxis( boolean v ) {
    this.drawAxis = v;
  }
  
  public void set_visibleGrid( boolean v ) {
    this.drawGrid = v;
  }
  
  public void set_visibleLabels( boolean v ) {
    this.drawLabels = v;
  }
  
  public void set_visibleData( boolean[] v ) {
    this.datV = v;
  }
  
  public boolean[] get_visibleData() {
    return this.datV;
  }
  
  public void set_colors( color[] c ) {
    this.datcol = c;
  }
  
  public color[] get_colors() {
    return this.datcol;
  }
  
  public void set_axisStrokeWeight( float sw ) {
    this.axisSW = sw;
  }
  
  public void set_gridStrokeWeight( float sw ) {
    this.gridSW = sw;
  }
  
  public void set_dataStrokeWeight( float sw ) {
    this.dataSW = sw;
  }
  
  public float get_dataStrokeWeight() {
    return this.dataSW;
  }
  
  public void set_xlim( double xli0 , double xlf0 ) {
    this.xli = xli0;
    this.xlf = xlf0;
    this.set_xmap();
  }
  
  public void set_ylim( double yli0 , double ylf0 ) {
    this.yli = yli0;
    this.ylf = ylf0;
    this.set_ymap();
  }
  
  public void set_ylimFit() {
    double min = Double.MAX_VALUE;
    double max = -Double.MAX_VALUE;
    for(int i=0; i<this.daty.length; i++){
      if( i >= this.datV.length ){
        this.generate_missingVisibles();
      }
      if( this.datV[i] ){
        for(int k=0; k<this.n; k++){
          float vx = this.get_xmapped( this.datx[k]+this.xOffset );
          if( is_xInside( vx ) ){
            double vy = this.daty[i][k];
            min = ( min < vy )? min : vy;
            max = ( max > vy )? max : vy;
          }
        }
      }
    }
    if( max < min ){
      min = 0.0;
      max = 0.0;
    }
    double extra = 0.01;
    this.yli = min - extra;
    this.ylf = max + extra;
    this.set_ymap();
  }
  
  public void set_xOffset( double o ) {
    this.xOffset = o;
  }
  
  public void set_yOffset( double o ) {
    this.yOffset = o;
  }
  
  public void set_drawLimY( boolean d ) {
    this.drawLimY = d;
  }
  
  public synchronized void insert( double x , double[] y ) {
    // we check if the dimension has changed
    if( y.length > this.daty.length ){
      this.change_dataDimension( y.length , this.datx.length );
    }
    // we take the next position
    int k = this.c + 1;
    k = ( k < this.datx.length )? k : 0;
    // we add the data
    this.datx[k] = x;
    for(int i=0; i<y.length; i++){
      this.daty[i][k] = y[i];
    }
    // we update the position of the next input
    this.c = k;
    // we update the number of inputs
    this.n++;
    this.n = ( this.n < this.daty[0].length )? this.n : this.daty[0].length-1;
  }
  
  public void draw() {
    // we draw the grid
    if( this.drawGrid ){
      this.draw_grid();
    }
    // we draw the data
    this.draw_data();
    // we draw the axis
    if( this.drawAxis ){
      this.draw_axis();
    }
    // we draw the labels
    if( this.drawLabels ){
      this.draw_labels();
    }
  }
  
  private void set_defaultConfig() {
    this.set_dataStorageLimit( 5000 );
    this.set_xlim( -12.0 , 0.0 );//( -1000 , 0 );
    this.set_ylim( -1 , 1 );
    this.set_dxgrid( 100.0 );
    this.set_dygrid( 1000.0 );  //( 0.1 );
    this.set_visibleGrid( true );
    this.set_visibleAxis( true );
    this.set_visibleLabels( true );
    this.set_gridStrokeWeight( 1.0 );
    this.set_axisStrokeWeight( 1.0 );
    this.set_dataStrokeWeight( 2.0 );
    this.set_axisColor( color(255,255,255) );
    this.set_gridColor( color( 100 , 100 , 100 ) );
    this.set_title( "title" );
    this.set_xlabel( "time (s)" );
    this.set_ylabel( "value" );
//    String[] pfl = PFont.list();
//    for(int i=0; i<pfl.length; i++){
//      print( pfl[i] + "   " );
//    }
    PFont f = createFont( "Helvetica" , 20 );
    textFont( f );
//    exit();
  }
  
  
  // PRIVATE METHODS
  
  public void set_xmap() {
    this.ax = (this.xf-this.xi)/(this.xlf-this.xli);
    this.bx = this.xf - this.xlf*this.ax;
  }
  
  public void set_ymap() {
    this.ay = (this.yi-this.yf)/(this.ylf-this.yli);
    this.by = this.yi - this.ylf*this.ay;
  }
  
  public float get_xmapped( double x ) {
    return (float)(this.ax*x+this.bx);
  }
  
  public float get_ymapped( double y ) {
    return (float)(this.ay*y+this.by);
  }
  
  public boolean is_xInside( float x ) {
    return (  this.xi < x  &&  x < this.xf  );
  }
  
  public boolean is_yInside( float y ) {
    return (  this.yi < y  &&  y < this.yf  );
  }
  
  private void change_dataDimension( int Ni , int Nj ) {
    double[] newdatx = new double[Nj];
    double[][] newdaty = new double[Ni][Nj];
    Ni = ( Ni < this.daty.length )? Ni : this.daty.length ;
    Nj = ( Nj < this.datx.length )? Nj : this.datx.length ;
    // first datx
//    println( Nj );
    for(int j=Nj-1, k=this.c; j>=0; j--){
      newdatx[j] = this.datx[k];
      k--;
      k = ( k < 0 )? this.datx.length-1 : k ;
    }
    // then, daty
    for(int i=0; i<Ni; i++){
      for(int j=Nj-1, k=this.c; j>=0; j--){
        newdaty[i][j] = this.daty[i][k];
        k--;
        k = ( k < 0 )? this.datx.length-1 : k ;
      }
    }
    this.datx = newdatx;
    this.daty = newdaty;
    this.c = ( Nj > 0 )? Nj-1 : 0 ;
  }
  
  private void generate_missingVisibles() {
    boolean[] vis = new boolean[this.daty.length];
    for(int i2=0; i2<this.datV.length; i2++){
      vis[i2] = this.datV[i2];
    }
    for(int i2=this.datV.length; i2<this.daty.length; i2++){
      vis[i2] = true;
    }
    this.datV = vis;
  }
  
  private void generate_missingColors() {
    color[] col = new color[this.daty.length];
    for(int i2=0; i2<this.datcol.length; i2++){
      col[i2] = this.datcol[i2];
    }
    for(int i2=this.datcol.length; i2<this.daty.length; i2++){
      colorMode(HSB);
      col[i2] = color( random(255) , 255 , 255 );
      //col[i2] = color( (int)(Math.random()*255) , 255 , 255 );
      colorMode(RGB);
    }
    this.datcol = col;
  }
  
  private void draw_axis() {
    stroke( this.axisColor );
    strokeWeight( this.axisSW );
    line( this.xi , this.yi , this.xf , this.yi );
    line( this.xi , this.yf , this.xf , this.yf );
    line( this.xi , this.yi , this.xi , this.yf );
    line( this.xf , this.yi , this.xf , this.yf );
  }
  
  private void draw_grid() {
    stroke( this.gridColor );
    strokeWeight( this.gridSW );
    fill( this.axisColor );
    textAlign( CENTER , TOP );
    for(double x=0; x<this.xlf; x+=this.dxgrid){
      float xm = this.get_xmapped( x );
      line( xm , this.yi , xm , this.yf );
      text( String.format( "%.1f" , x ) , xm , this.yf );
      //text( Double.toString(x) , xm , this.yf );
    }
    for(double x=0; x>this.xli; x-=this.dxgrid){
      float xm = this.get_xmapped( x );
      line( xm , this.yi , xm , this.yf );
      text( String.format( "%.1f" , x ) , xm , this.yf );
      //text( Double.toString(x) , xm , this.yf );
    }
    textAlign( RIGHT , CENTER );
    for(double y=0; y<this.ylf; y+=this.dygrid){
      float ym = this.get_ymapped( y );
      if( is_yInside( ym ) ){
        line( this.xi , ym , this.xf , ym );
        text( String.format( "%.1f" , y ) , this.xi , ym );
        //text( Double.toString(y) , this.xi , ym );
      }
    }
    for(double y=0; y>this.yli; y-=this.dygrid){
      float ym = this.get_ymapped( y );
      if( is_yInside( ym ) ){
        line( this.xi , ym , this.xf , ym );
        text( String.format( "%.1f" , y ) , this.xi , ym );
        //text( Double.toString(y) , this.xi , ym );
      }
    }
    if( drawLimY ){
      float ymin = this.get_ymapped( this.yli );
      text( String.format( "%.2f" , this.yli ) , this.xi , ymin );
      float ymax = this.get_ymapped( this.ylf );
      text( String.format( "%.2f" , this.ylf ) , this.xi , ymax );
    }
  }
  
  private void draw_labels() {
    // title
    textAlign( CENTER , BOTTOM );
    text( this.title , 0.5*(this.xi+this.xf) , this.yi );
    // x axis
    textAlign( CENTER , TOP );
    text( this.xlabel , 0.5*(this.xi+this.xf) , this.yf );
    // y axis
    textAlign( CENTER , BOTTOM );
    pushMatrix();
    translate( this.xi-this.dygridWidth , 0.5*(this.yi+this.yf) );
    rotate( -HALF_PI );
    text( this.ylabel , 0 , 0 );
    popMatrix();
  }
  
  private synchronized void draw_data() {
    noFill();
    strokeWeight( this.dataSW );
    for(int i=0; i<this.daty.length; i++){
      if( i >= this.datV.length ){
        this.generate_missingVisibles();
      }
      if( i >= this.datcol.length ){
        this.generate_missingColors();
      }
      if( this.datV[i] ){
        stroke( this.datcol[i] );
        beginShape();
        for(int j=0, k=this.c; j<this.n; j++){
          float px = this.get_xmapped( this.datx[k]+this.xOffset );
          float py = this.get_ymapped( this.daty[i][k]+this.yOffset );
          if( is_xInside( px ) && is_yInside( py ) ){
            vertex( px , py );
          }
          k--;
          k = ( k < 0 )? this.n-1 : k;
        }
        endShape();
      }
    }
  }
  
}