class MAP_Graph_TypeIssue extends Graph
{
  String sort_column;
  float sort_col_min_value;
  float sort_col_max_value;
  float sort_range;
  float text_multipler = 8;
  float text_base_size = 10;

  String colour_column;
  float colour_max;
  float colour_min;
  //float colour_range;

  StringList dataColumns;


  MAP_Graph_TypeIssue(Page p_, int x_, int y_, int w_, int h_)
  {
    super(p_, x_, y_, w_, h_);
    type = "MAP_Graph_TypeIssue";
    dataColumns = new StringList();
  }

  void drawElement(PGraphics g)
  {

    g.beginDraw();
    g.pushMatrix();
    g.translate(xx, yy);

    float amount_of_space_for_column_titles = xStep/2;

    float y_offset = amount_of_space_for_column_titles;
    float x_offset = 0;




    if (data!=null && !isNullOrBlank(sort_column)) 
    {

      //float range = 



      for (int r = 0; r< data.getRowCount(); r++)
      {

        String label = data.getString(r, 0);

        float scalar = data.getFloat(r, sort_column);
        if (sort_col_min_value<0)
        {
          scalar+=abs(sort_col_min_value);
        } else        
        {
          scalar-=abs(sort_col_min_value);
        }
        float text_size = text_base_size+(text_multipler*scalar);

        if (r%2==0)
        {
          g.noStroke();
          g.fill(LIGHT_GREY);
          g.rect(0, y_offset+text_size/5, ww, text_size);
        }

        y_offset+=text_size;





        ///get the fill colour
        //float colour_lerp_amount = scalar/sort_range;

        float colour_input = data.getFloat(r, colour_column);
        //set to baseline
        if (colour_min<0)
        {
          colour_input+=abs(colour_min);
        } else
        {
          colour_input-=abs(colour_min);
        }

        //normalise
        float colour_lerp_amount = colour_input/getRange(colour_min, colour_max);

        println(colour_lerp_amount);

        color ISSUE_COLOUR = lerpColor(MID_GREY, HOT_ISSUE, colour_lerp_amount);
        //g.fill(BLACK);        

        ///write out the name of the issues one by one

        g.fill(ISSUE_COLOUR);
        //g.fill(BLACK);
        PFont scaleFont=createFont("AvenirLTStd-Medium", 10);
        g.textAlign(LEFT);
        g.textFont(scaleFont);
        g.textSize(text_size);

        g.text(label, 0, y_offset);


        float line_height = textAscent()+textDescent();




        if (textWidth(label)>x_offset)
        {
          x_offset = textWidth(label);
        }
      }

      x_offset *=2;///a hack!!!

      xStep =  ( (ww-x_offset)/dataColumns.size() );


      ///////////////////////////////////////////
      //////////COL TITLES //////////////////////      
      ///////////////////////////////////////////
      for (int c = 0; c<dataColumns.size(); c++)
      {
        float x_pos = (x_offset) + ( (c) *xStep);

        float y_pos = 0;

        String columnlabel = dataColumns.get(c);
        g.fill(BLACK);
        g.textAlign(CENTER);
        g.text(columnlabel, x_pos, y_pos, xStep, amount_of_space_for_column_titles);
        //textB
      }


      ///////////////////////////////////////////
      //////////2ND PASS ////////////////////////      
      ///////////////////////////////////////////
      float y_offset2 = amount_of_space_for_column_titles;
      for (int r = 0; r< data.getRowCount(); r++)
      { 
        float scalar = data.getFloat(r, sort_column);
        if (sort_col_min_value<0)
        {
          scalar+=abs(sort_col_min_value);
        } else        
        {
          scalar-=abs(sort_col_min_value);
        }
        float text_size = text_base_size+(text_multipler*scalar);
        y_offset2+=text_size;

        for (int c = 0; c<dataColumns.size(); c++)
        {
          float x_pos = (x_offset) + ( (c+.5) *xStep);

          if (data.getFloat(r, dataColumns.get(c))>0)
          {
            g.fill(BLACK);
            g.noStroke();
            g.ellipse(x_pos, y_offset2-text_size/2+text_size/5, text_multipler, text_multipler);
          }
        }
      }
    }///data nulll

    if (y_offset>hh)
    {
      text_multipler-=.1;
      book.updateDisplay();
    }





    //g.stroke(COOL_GREY);
    //g.line(x_offset, 0, x_offset, hh);


    /////STAYS AT BOTTOM
    g.popMatrix();
    g.endDraw();
  }

  void assignSortColumn(String s)
  {
    sort_column = s;
    if (data!=null) 
    {
      //FloatList column_data = data.getFloatList(s);
      /////set xMax, xMin
      //sort_col_max_value = column_data.max();
      //ysort_col_max_value = column_data.min();


      //      data.setColumnType(sort_column, Table.FLOAT); /// otherwise minus numbers aren’t sorted correctly
      //      data.sortReverse(sort_column);
      sort_col_max_value = returnMaxFloat(data, s);
      sort_col_min_value = returnMinFloat(data, s);
      sort_range = getRange(sort_col_max_value, sort_col_min_value);
    }
  }



  void assignDataColumn(String s)
  {
    dataColumns.append(s);
  }


  void assignColourColumn(String s)
  {
    colour_column = s;

    FloatList column_data = data.getFloatList(s);
    ///set xMax, xMin
    colour_max = column_data.max();
    colour_min = column_data.min();
  }
}////MAP Graph
