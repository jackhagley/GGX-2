
class DataColumn
{
  String label;
  color c;

  DataColumn(String label_, color c_)
  {
    this.label = label_;
    this.c = c_;
  }
}


class MAP_Graph_Corbyn extends Graph
{
  String x_metric = "not assigned";
  String y_metric = "not assigned";

  boolean showXGrid = true;
  boolean showYGrid = true;

  ArrayList<DataColumn>dataColumns;

  MAP_Graph_Corbyn(Page p_, int x_, int y_, int w_, int h_)
  {
    super(p_, x_, y_, w_, h_);
    type = "MAP_Graph_Corbyn";
    dataColumns = new ArrayList<DataColumn>();
  }




  void drawElement(PGraphics g)
  {

    g.beginDraw();
    g.pushMatrix();
    g.translate(xx, yy);

    if (data!=null) 
    {
      if (assigned(x_metric) && assigned(y_metric))
      {
        xStep = ww/getXRange();
        yStep = hh/getYRange();

        ///GRID LINES
        if (showXGrid || showYGrid)
        {
          g.stroke(0);
          g.strokeWeight(.5);
        }

        if (showXGrid)
        {
          for (int x1 = 0; x1<=getXRange(); x1++)
          {
            g.line(x1*xStep, 0, x1*xStep, hh);
          }
        }
        if (showYGrid)
        {
          for (int y1 = 0; y1<=getYRange(); y1++)
          {
            g.line(0, y1*yStep, ww, y1*yStep);
          }
        }

        ///////If there are data columns assigned, then plot them here
      }///x & y assigned
    }
    /////STAYS AT BOTTOM
    g.popMatrix();
    g.endDraw();
  }

  void addDataColumn(String label, color c)
  {
    dataColumns.add(new DataColumn(label, c));
  }

  void assignX(String xmet_)
  {
    ///find the min and max
    if (data!=null) 
    {
      this.x_metric = xmet_;
      FloatList column_data = data.getFloatList(x_metric);
      ///set xMax, xMin
      xMax = column_data.max();
      xMin = column_data.min();
    } else
    {
      println("data is null, cannot assign");
    }
  }

  void assignY(String ymet_)
  {
    ///find the min and max
    if (data!=null) 
    {
      this.y_metric = ymet_;
      FloatList column_data = data.getFloatList(y_metric);
      ///set xMax, xMin
      yMax = column_data.max();
      yMin = column_data.min();
    } else
    {
      println("data is null, cannot assign");
    }
  }

  boolean assigned(String input)
  {
    return !input.equals("not assigned");
  }
}////MAP Graph
