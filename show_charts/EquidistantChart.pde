
public class EquidistantChart extends Chart {
  
  public void f( Point q , Point p ) {
    float norm = sqrt( q.x * q.x + q.y * q.y );
    p.x = norm*Math.signum(q.x)*atan2( abs(q.x) , q.y );
    p.y = R;
    if( abs(p.x) > d ){
      float angle = Math.signum(q.x)*d/R;
      float ca = cos(angle);
      float sa = sin(angle);
      p.x = ca * q.x - sa * q.y + Math.signum(q.x)*d;
      p.y = sa * q.x + ca * q.y;
    }
  }
  
}