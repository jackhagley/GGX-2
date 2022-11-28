import java.util.Iterator;

class ConvexHull extends Graph
{
  float x_slots_needed;
  float y_slots_needed;

  boolean displayAll = true;
  StringList displayItems;

  ConvexHull(Page p_, int x_, int y_, int w_, int h_)
  {
    super(p_, x_, y_, w_, h_);
    type = "ForceBubbles2";
    displayItems = new StringList();
  }

  void addDisplayItem(String input)
  {
    displayAll  = false;
    displayItems.append(input);
  }

  void drawElement(PGraphics g)
  {
    if (data!=null) 
    {


      g.beginDraw();
      g.textMode(MODEL);

      //g.textAlign(LEFT);

      g.textAlign(CENTER);
      g.textFont(big_label_font);
      g.textLeading(5);
      g.pushMatrix();
      g.translate(xx, yy);

      g.translate(ww/2, hh); 

      g.stroke(0);
      g.strokeWeight(1);
      g.line(0, 0, 0, -hh);

      g.translate(0, hacked_y_offset); 

      //float biggest_col = 0;
      //float biggest_pos = 0;
      //float biggest_circle = getCircleDiameterFromValue(yMax*scale);


      xStep =  ww / x_slots_needed;
      yStep =  (-hh/ y_slots_needed)*y_scalar;
      
      
      g.translate(- x_axis_offset* xStep,0);

      for (int ys = 0; ys< int(y_slots_needed); ys++)
      {
        // g.line(0-ww/2,ys*yStep,ww/2,ys*yStep);
      }


      //for (int c = 9; c<data.getColumnCount(); c++)    
      //{
      //  for (int r = 0; r<data.getRowCount(); r++)
      //  {
      //    float col_value = abs(data.getFloat(r, c));
      //    float pos_value = abs(data.getFloat(r, "pro/con (n)"));

      //    if (col_value+pos_value>biggest_col+biggest_pos)
      //    {
      //      biggest_col = col_value;
      //      biggest_pos = pos_value;
      //    }
      //  }


      HashMap pointMap = new HashMap<String, ArrayList<PVector>>();



      for (int r = 0; r<data.getRowCount(); r++)
      {

        //color THIS_COLOUR = color(10, 10, 10);
        String country = data.getString(r, country_column);

        if (displayAll || displayItems.hasValue(country))
        {



          String this_name = data.getString(r, big_label_column);

          //        if (!isNullOrBlank(affiliation_column))
          //        {
          //          party = data.getString(r, affiliation_column);
          //        } else
          //        {
          //          has_party = true;
          //        }


          float influence = data.getFloat(r, y_axis);
          float procon = -data.getFloat(r, x_axis);

          //if (!isNullOrBlank(title))
          //{
          //  String title = data.getString(r, "Title");
          //}



          //String name = data.getString(r, name_column);

          //String party = data.getString(r, affiliation_column);



          float x_pos = xStep*procon;
          float y_pos = yStep*influence;

          if (isNullOrBlank(country))
          {
            println(this_name);
          }

          if (!pointMap.containsKey(country))
          {
            ArrayList<PVector> points = new ArrayList<PVector>();
            points.add(new PVector(x_pos, y_pos));
            pointMap.put(country, points);
            //println("adding "+country);
          } else
          {
            ArrayList<PVector> points = (ArrayList<PVector>) pointMap.get(country);
            points.add(new PVector(x_pos, y_pos));
            //println("adding "+country);
            //println(points.size());
          }
        }
      }


      ///process all the point arrays into convex hulls


      Iterator it = pointMap.keySet().iterator();
      while (it.hasNext())
      {
        String item = (String)it.next();
        if (isNullOrBlank(item))
        {
          println("convex generator has found null or blank item");
        }
        color c = color(random(100, 200), random(100, 200), random(100, 200));
        ArrayList<PVector> points = (ArrayList<PVector>) pointMap.get(item);

        PVector label_loc = meanVector(points);

        for (PVector pv : points)
        {
          g.stroke(c);
          g.strokeWeight(1);
          //g.line(pv.x, pv.y, label_loc.x, label_loc.y);
        }

        g.fill(c);
        g.text(item, label_loc.x, label_loc.y);


        if (points.size()<3)
        {
          println(item);
        }




        ArrayList<PVector> hull_points = quickHull(points);
        g.fill(c, 100);
        g.noStroke();
        g.beginShape();
        for (PVector pv : hull_points)
        {
          g.vertex(pv.x, pv.y);
        }
        g.endShape(CLOSE);

        //  System.out.println(pair.getKey() + " = " + pair.getValue());
        it.remove(); // avoids a ConcurrentModificationException
      }


      g.popMatrix();
      g.endDraw();
    }///datanull
  }
}


ArrayList<PVector> quickHull(ArrayList<PVector> input)
{

  ArrayList<PVector> points = new ArrayList<PVector>();

  for (PVector pv : input)

  {
    points.add(new PVector(pv.x, pv.y, pv.z));
  }



  ArrayList<PVector> convexHull = new ArrayList<PVector>();

  if (points.size() < 3)
  {
    return (ArrayList) points.clone();
  }



  int minPoint = 0, maxPoint = 0;

  float minX = Float.MAX_VALUE;

  float maxX = Float.MIN_VALUE;

  for (int i = 0; i < points.size(); i++)

  {

    if (points.get(i).x < minX)

    {

      minX = points.get(i).x;

      minPoint = i;
    }

    if (points.get(i).x > maxX)

    {

      maxX = points.get(i).x;

      maxPoint = i;
    }
  }

  PVector A = points.get(minPoint);

  PVector B = points.get(maxPoint);

  convexHull.add(A);

  convexHull.add(B);

  points.remove(A);

  points.remove(B);



  ArrayList<PVector> leftSet = new ArrayList<PVector>();

  ArrayList<PVector> rightSet = new ArrayList<PVector>();



  for (int i = 0; i < points.size(); i++)

  {

    PVector p = points.get(i);

    if (pointLocation(A, B, p) == -1)

      leftSet.add(p);

    else if (pointLocation(A, B, p) == 1)

      rightSet.add(p);
  }

  hullSet(A, B, rightSet, convexHull);

  hullSet(B, A, leftSet, convexHull);



  return convexHull;
}



public float distance(PVector A, PVector B, PVector C)

{

  float ABx = B.x - A.x;

  float ABy = B.y - A.y;

  float num = ABx * (A.y - C.y) - ABy * (A.x - C.x);

  if (num < 0)

    num = -num;

  return num;
}



public void hullSet(PVector A, PVector B, ArrayList<PVector> set, 

  ArrayList<PVector> hull)

{

  int insertPosition = hull.indexOf(B);

  if (set.size() == 0)

    return;

  if (set.size() == 1)

  {

    PVector p = set.get(0);

    set.remove(p);

    hull.add(insertPosition, p);

    return;
  }

  float dist = Float.MIN_VALUE;

  int furthestPoint = -1;

  for (int i = 0; i < set.size(); i++)

  {

    PVector p = set.get(i);

    float distance = distance(A, B, p);

    if (distance > dist)

    {

      dist = distance;

      furthestPoint = i;
    }
  }

  try
  {
    PVector P = set.get(furthestPoint);
    set.remove(furthestPoint);

    hull.add(insertPosition, P);






    // Determine who's to the left of AP

    ArrayList<PVector> leftSetAP = new ArrayList<PVector>();

  for (int i = 0; i < set.size(); i++)

  {

    PVector M = set.get(i);

    if (pointLocation(A, P, M) == 1)

    {

      leftSetAP.add(M);
    }
  }



  // Determine who's to the left of PB

  ArrayList<PVector> leftSetPB = new ArrayList<PVector>();

  for (int i = 0; i < set.size(); i++)

  {

    PVector M = set.get(i);

    if (pointLocation(P, B, M) == 1)

    {

      leftSetPB.add(M);
    }
  }

  hullSet(A, P, leftSetAP, hull);

  hullSet(P, B, leftSetPB, hull);
  
    }
  catch(Exception e)
  {
   println(e); 
    
  }
}



public int pointLocation(PVector A, PVector B, PVector P)

{

  float cp1 = (B.x - A.x) * (P.y - A.y) - (B.y - A.y) * (P.x - A.x);

  if (cp1 > 0)

    return 1;

  else if (cp1 == 0)

    return 0;

  else

    return -1;
}
