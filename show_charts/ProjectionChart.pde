
public class ProjectionChart extends Chart {
  
  // PUBLIC METHODS
  
  // xp/(R-h) = x/(y-h)
  public void f( Point q , Point p ) {
    p.x = (R-h)/(q.y-h)*q.x;
    p.y = R;
  }
  
  
  
}