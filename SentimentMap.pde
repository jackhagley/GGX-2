//class MapLocation
//{
// ///subclass for labelling things that might be in the same location as each other

// color c

// MapLocation()
// {


// }

// void addLocation
// {

// }

// void drawToBuffer(PGraphics g)
// {


// }

//}


int arrow_columns_start_at = 0;
color[] hues; ///this is so that all of the entries are different colours



float main_label_text_size = 10;
float arrow_text_size = 8.5;
float arrow_spacing = 10;

int big_label_opacity = 250;
int description_label_opacity = 150;
int arrow_label_opacity = 125;
int year_label_opacity = 210;
int arrow_fill_opacity = 200;

float x_axis_offset = 5; /// to change from 0<>10 to -5<>+5


class SentimentMap extends Graph
{
  float border = 100;
  float bubble_max;
  float bubble_min;
  float scale = 100;
  float spacing = 6;
  float shaft_length = 40;

  float x_slots_needed;
  float y_slots_needed;


  boolean display_arrows = false;

  SentimentMap(Page p_, int x_, int y_, int w_, int h_)
  {
    super(p_, x_, y_, w_, h_);
    type = "SentimentMap";
  }

  void displayArrows()
  {
    display_arrows = true;
  }

  void drawElement(PGraphics g)
  {
    if (data!=null) 
    {
      //println(data.getString(0,0));

      //for (int r = 0; r<data.getRowCount(); r++)
      //{
      //  println("  "+data.getString(r, "Name "));
      //}


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

      xStep =  ww/ x_slots_needed;
      yStep =  (-hh/ y_slots_needed)*y_scalar;


      for (int r = 0; r<data.getRowCount(); r++)
      {
        boolean has_assigned_colour = false;
        color assigned_colour;
        //color THIS_COLOUR = color(10, 10, 10);

        
        String description_label = "";
        String year_label = "";

        float bubble_size = 0;


        StringList  labels = new StringList();
        ;

        for (int i = 0; i<label_columns.length; i++)
        {
          labels.append(data.getString(r, label_columns[i]));
        }


        if (!isNullOrBlank(assigned_colour_column))
        {
          try{
          assigned_colour = assigned_colours.get( data.getString(r, assigned_colour_column) );
          has_assigned_colour = true;
          }
          catch(Exception e)
          {
            println("you don’t have a colour for "+data.getString(r, assigned_colour_column)+"in assigned_colours" );
          }
          ////this is kind of not that important, as you can generate each category on a different page then put them together. 
          ////if they have a unique colour it makes them easier to work with anyway
        }

        float y_axis_value = data.getFloat(r, y_axis);
        float x_axis_value = -data.getFloat(r, x_axis) - x_axis_offset;
        
        
        String big_label = data.getString(r, big_label_column);

        if (!isNullOrBlank(description_column))
        {
          description_label= data.getString(r, description_column).toUpperCase();
        }

        if (!isNullOrBlank(year_column))
        {
          year_label= data.getString(r, year_column);
        }



        float circle_size = getCircleDiameterFromValue(y_axis_value*scale);

        if (!isNullOrBlank(bubble_column))
        {

          bubble_size = data.getFloat(r, bubble_column);
        }


        float x_pos = xStep*x_axis_value;
        float y_pos = yStep*y_axis_value;


        //if (!isNullOrBlank(title_label))
        //{
        //  label += "%n"+title_label;
        //  //println(title_label);
        //}

        //ArrayList<TriSymbol> tris= new ArrayList<TriSymbol>();

        IntDict pros = new IntDict();
        IntDict cons = new IntDict();

        //int iran = data.getInt(r, "Iran");

        if (arrow_columns_start_at>0)
        {

          for (int c = arrow_columns_start_at; c<data.getColumnCount(); c++)    
          {
            String arrow_label = data.getColumnTitle(c);

            data.setColumnType(c, Table.FLOAT); ///makes sure minuses are taken care of (?)

            int value = data.getInt(r, c);
            if (value!=0)
            {
              if (value>0)
              {
                pros.set(arrow_label, value);
              }

              if (value<0)
              {
                cons.set(arrow_label, value);
              };
            }
          }

          cons.sortValues();
          pros.sortValuesReverse();
        }


        //////////DISPLAY///////////////

        g.pushMatrix();
        g.translate(x_pos, y_pos);
        g.noStroke();

        color unique_colour = getUniqueColourFromTable(masterData, hues, big_label, big_label_column);



        g.noStroke();


        float circle_mark_size = 8f;
        float y_text_offset = -2;


        float pro_arrow_yOff = circle_mark_size+2;
        float con_arrow_yOff = circle_mark_size+2;
        float shaft_width = 2;

        float offset_from_centre = 1f;

        //g.textSize(arrow_text_size);

        if (arrow_columns_start_at==0)
        {
          display_arrows = false;
        }

        if (display_arrows)
        {

          g.textFont(arrow_font);

          for (String k : pros.keyArray()) {
            // use the key here
            int value = pros.get(k);

            g.fill(unique_colour, arrow_fill_opacity);
            drawArrow(g, -value, -offset_from_centre, pro_arrow_yOff, shaft_length, shaft_width);
            g.fill(unique_colour, arrow_label_opacity);
            g.textAlign(RIGHT);
            g.textMode(MODEL);
            g.text(k, -offset_from_centre-4, pro_arrow_yOff+y_text_offset);
            pro_arrow_yOff += arrow_spacing;
          }


          for (String k : cons.keyArray()) {
            // use the key here
            int value = cons.get(k);
            g.fill(unique_colour, arrow_fill_opacity);
            //if (has_party)
            //{
            //  g.fill(getPartyColour(party), 100);
            //}
            drawArrow(g, -value, offset_from_centre, con_arrow_yOff, shaft_length, shaft_width);
            g.textAlign(LEFT);
            g.fill(unique_colour, arrow_label_opacity);
            g.textMode(MODEL);
            g.text(k, offset_from_centre+4, con_arrow_yOff+y_text_offset);
            con_arrow_yOff += arrow_spacing;
          }


          float rect_depth = pro_arrow_yOff>con_arrow_yOff ? pro_arrow_yOff : con_arrow_yOff;

          //g.fill(getPartyColour(party), 100);
          //g.rect(-offset_from_centre/2, circle_mark_size-arrow_spacing+(shaft_width), (offset_from_centre), rect_depth-circle_mark_size);


          //g.stroke(unique_colour);
          //g.strokeWeight(1);
          //g.strokeCap(SQUARE);
          //float line_x_pos = -offset_from_centre/2+.5;
          //g.line(line_x_pos, circle_mark_size-arrow_spacing+(shaft_width), line_x_pos, circle_mark_size-arrow_spacing+(shaft_width)+ rect_depth-circle_mark_size);

          g.fill(unique_colour);
          g.noStroke();
          float line_x_pos = -offset_from_centre/2;
          g.rect(line_x_pos, circle_mark_size+4-arrow_spacing+(shaft_width), 1, circle_mark_size+2-arrow_spacing+(shaft_width)+ rect_depth-circle_mark_size-(arrow_spacing/2));
        }///display arrows

        g.noStroke();
        g.fill(unique_colour, 200);

        ////mark a normal sized 
        //g.ellipse(0, 0, circle_mark_size, circle_mark_size);////this is only if there are no sized bubbles

        //g.stroke(getPartyColour(party));
        //g.strokeWeight(10);
        /////////////
        //for (int c = 8; c<data.getColumnCount(); c++)
        //{
        //  String factor_name = data.getColumnTitle(c);
        //  int value = data.getInt(r, c);

        //  //g.line(x_pos, y_pos, x_pos-(value*25), y_pos);
        //}////c
        ///////////

        // g.stroke(getPartyColour(party), 100);
        //g.strokeWeight(circle_size);
        //g.point(0, 0);

        g.textAlign(CENTER);
        g.textMode(MODEL);
        g.fill(unique_colour);
        g.noStroke();

        if (bubble_size!=0)
        {
          bubble_size = getCircleDiameterFromValue(bubble_size*scale*.000001);
          g.fill(unique_colour, description_label_opacity);
          g.ellipse(0, 0, bubble_size, bubble_size);
        } else
        {
          rectMode(CENTER);
          pushMatrix();
          rotate(TAU/8);
          rect(0, 0, circle_mark_size, circle_mark_size);
          popMatrix();
          rectMode(CORNER);
          //println(
        }


        float y_label_offset = 0;

        if (isString(big_label))
        {
          g.fill(unique_colour, big_label_opacity);
          g.textFont(big_label_font);
          g.text(big_label, 0, y_label_offset);
          y_label_offset -= 14;
        }



        if (isString(description_label))
        {

          g.fill(unique_colour, description_label_opacity);
          g.textFont(description_font);
          g.text(description_label, 0, y_label_offset);
          y_label_offset -= 6;
        }
        else
        {
          println("no description found");
        }



        if (isString(year_label))
        {
          g.fill(unique_colour, year_label_opacity);
          g.textFont(year_font);
          g.text(year_label, 0, y_label_offset);
        }

        g.popMatrix();////each entry (r)




        //////COLOUR BOX (to help with grouping in Illustrator)

        int master_index = findRowIndexInMasterData(masterData, big_label, big_label_column);
        float masterPos = hh/masterData.getRowCount();

        float colourBox_yPos = masterPos * master_index - (hh*.5);
        g.fill(unique_colour, 255*.92);     
        g.rect(-ww*.6, colourBox_yPos, 10, masterPos);
      }////each entry (r)



      g.popMatrix();
      g.endDraw();
    }///datanull
  }
}

class TriSymbol
{
  String label;
  float mag;
  // boolean pro=false;
  float r = 3;

  TriSymbol(String label_, float mag_)
  {
    this.label = label_;
    this.mag = mag_;
  }

  void display(PGraphics g, color fill, float x, float y)
  {
    g.fill(fill);
    g.noStroke();
    g.pushMatrix();
    g.translate(x, y);
    if (mag>0)
    {
      g.rotate(-PI/2);
    } else
    {
      g.rotate(PI/2);
    }
    g.beginShape();
    g.vertex(0, -r*2 );
    g.vertex(-r, r*2);
    g.vertex(r, r*2);
    g.endShape(CLOSE);
    g.popMatrix();
  }
}

void drawArrow(PGraphics pg, float value, float x, float y, float shaft_length, float shaft_width )
{
  //pg.beginDraw();

  ///////////////////////
  //float shaft_length = 40;


  float point_length = 8;

  if (value<0)
  {
    point_length = -point_length;
  }

  if (value==0)
  {
    return;
  }


  float head_overhang = 2;

  //pg.pushMatrix();
  pg.translate(x, y);

  pg.beginShape();

  ///starts in the centre


  pg.vertex(0, 0);
  pg.vertex(0, -.5*shaft_width);
  pg.vertex(value*shaft_length, -.5*shaft_width);

  ///HEAD
  pg.vertex(value*shaft_length, -.5*shaft_width-head_overhang);
  pg.vertex(value*shaft_length+point_length, 0);
  pg.vertex(value*shaft_length, .5*shaft_width+head_overhang);  

  ///HEAD


  pg.vertex(value*shaft_length, .5*shaft_width);
  pg.vertex(0, .5*shaft_width);

  ///point of arrow
  //g.vertex(value*shaft_length, 0);


  pg.endShape(CLOSE);
  pg.translate(-x, -y);
  //g.ellipse(x,y,444,444);
  //pg.popMatrix();
  ///////////////////////////
  //pg.endDraw();
}
