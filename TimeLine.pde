class Timeline extends Graph
{
  ArrayList<Event>events;

  Event firstEvent;
  Event lastEvent;


  Timeline(Page p_, int x_, int y_, int w_, int h_)
  {
    super(p_, x_, y_, w_, h_);
    type = "Timeline";
    events = new ArrayList<Event>();
  }

  void addData(String filename)
  {
    data = loadTable(filename, "header");

    for (int r = 0; r<data.getRowCount(); r++)
    {
      events.add(new Event(r));
    }

    //assumes chronological
    firstEvent = events.get(0);
    lastEvent = events.get(events.size()-1);


    for (Event e : events)
    {
      ///find the earliest event
      if (e.start<firstEvent.start)
      {
        firstEvent = e;
      }


      ///find the last event
      if (e.max_end>lastEvent.max_end)
      {
        lastEvent = e;
      }
    }
    //println("First event is "+firstEvent.title+" in "+firstEvent.end);
    //println("Last event is "+lastEvent.title+" in "+lastEvent.end);



    ///find xStep
    xStep = ww / ( ( abs(lastEvent.max_end) - abs (firstEvent.start) ) + 2) ;
  }//addData

  void drawElement(PGraphics g)
  {
    if (data!=null) 
    {
      g.beginDraw();
      g.pushMatrix();
      g.translate(xx, yy);

      g.translate(xStep, hh/2);

      //MAIN LINE
      g.strokeWeight(5);
      g.line(0, 0, ww-(xStep*2), 0);


      g.strokeWeight(1);
      g.textAlign(CENTER);
      g.fill(0);
      for (Event e : events)
      {
        float e_x = (e.start-firstEvent.start)*xStep;

        g.line(e_x, -75, e_x, 0);

        g.text(e.title, e_x, -80);
      }


      g.endDraw();
      g.popMatrix();
    }
  }


  class Event {

    String title;

    float start;
    float end;
    float yearSet;
    
    float max_end;

    StringList themes;
    StringDict people;




    Event(int r)
    {
      title = data.getString(r, "title");
      start = data.getFloat(r, "year began (or released)");
      yearSet = data.getFloat(r, "year set");
      //println(start);


      end = data.getFloat(r, "year finished (optional)");

      if (Float.isNaN(end))
      {
        end = start;
        
      }

      if (Float.isNaN(yearSet))
      {
        yearSet = -1;
      } 
      
      max_end = end;
      
      if(yearSet>end)
      {
       max_end = yearSet; 
      }
      

      themes = new StringList(data.getString(r, "themes").split(","));

      ///people isn’t working yet…
      //String [] people_names = data.getString(r,"people").split("/(?<=:)(.*?)(?=\s*,)/)");
    }
  }//event
}
