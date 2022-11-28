import java.text.BreakIterator;

class BodyText extends Element
{

  PFont font;
  //String paragraphs[];
  ArrayList<Paragraph> paragraphs;
  float leading;

  BodyText(Page p_, int x_, int y_, int w_, int h_)
  {
    super(p_, x_, y_, w_, h_);
    type = "Body Text";
  }

  void addText(String file)
  {
    paragraphs = new ArrayList<Paragraph>();
    String temp[] = loadStrings(file);


    for (int i = 0; i<temp.length; i++)
    {
      println(i);

      Paragraph p1 =  new Paragraph(temp[i]);

      paragraphs.add(p1);

      //      p1.printSentences();
    }

    println(paragraphs.size() );
  }

  void setLeading(float l)
  {
    leading = l;
  }

  void setFont(PFont f)
  {
    font = f;
  }

  void drawElement(PGraphics g)
  {

    g.beginDraw();
    g.pushMatrix();
    g.translate(xx, yy);

    //for each of the paragraphs
    //for each of the sentences
    //for each of the words


    g.popMatrix();
    g.endDraw();
  }
}

class Paragraph {

  String text;
  ArrayList<Sentence> sentences;

  Paragraph(String s)
  {
    text = s;
    //println(text);
    sentences = new ArrayList<Sentence>();

    BreakIterator iterator = BreakIterator.getSentenceInstance();
    //BreakIterator iterator = BreakIterator.getWordInstance();
    iterator.setText(text);

    //split into sentences
    int start = iterator.first();
    for (int end = iterator.next(); 
      end != BreakIterator.DONE; 
      start = end, end = iterator.next() )
    {
      sentences.add( new Sentence( text.substring(start, end) ) );
    }


    //int start = boundary.first();
    //int end = boundary.next();
    //System.out.println(source.substring(start, end));



    //String temp [] =  text.split("(?<=[a-z])\\.\\s+");

    //for (int i = 0; i<temp.length; i++)
    //{
    //  sentences.add(new Sentence(temp[i]) );
    //  println(temp[i]);
    //}
  }

  void printText()
  {
  }

  void printSentences()
  {
    for (Sentence s : sentences)
    {
      //s.printText();
      //println("");
    }
  }
}

class Sentence {

  String text;
  StringList words;

  Sentence(String s)
  {
    text = s;
    words = new StringList();

    BreakIterator iterator = BreakIterator.getWordInstance();
    iterator.setText(text);

    int start = iterator.first();
    for (int end = iterator.next(); 
      end != BreakIterator.DONE; 
      start = end, end = iterator.next() )
    {
      words.append( text.substring(start, end) );
    }
  }

  void printText()
  {
    print(text);
  }
}


class HorzBarChart extends Graph
{

  String values_column_name;
  String categories_column_name;
  StringList categories;
  float column_gap = 10;

  HorzBarChart(Page p_, int x_, int y_, int w_, int h_)
  {
    super(p_, x_, y_, w_, h_);
    type = "Horizontal BarChart";
    categories = new StringList();
    addIn("values","float");
    addIn("labels","String");
  }


  void addValuesColumn(String s) {
    values_column_name = s;
  }

  void addCategory(String s) {
    categories.append(s);
  }

  void addCategories(String [] list)
  {
    for (String s : list)
    {
      addCategory(s);
    }
  }

  void setCategoriesColumnName(String s)
  {
    categories_column_name = s;
  }

  void drawElement(PGraphics g)
  {
    if (data!=null) 
    {
      g.beginDraw();
      g.pushMatrix();
      g.translate(xx, yy);

      g.textAlign(LEFT, BOTTOM);
      //g.text(values_column_name, 0, 0);

      xStep = ww/categories.size();


      ///remove any empty rows in the sheet

      IntList rows_to_remove = new IntList();
      Table dataCopy = cloneTable(data);

      for (int r = 0; r<dataCopy.getRowCount(); r++)
      {
        String value_string = dataCopy.getString(r, values_column_name);
        ///filter out the NaNs
        if ( ! isNullOrBlank(value_string))
        {
          if ( ! isNumeric(value_string) )
          {
            rows_to_remove.append(r);
          }
        } else {
          rows_to_remove.append(r);
        }
      }


      rows_to_remove.sortReverse();

      for (int r : rows_to_remove)
      {
        dataCopy.removeRow(r);
      }


      for (int i = 0; i<categories.size(); i++)
      {
        String category = categories.get(i);

        Table categoryData = sift(dataCopy, categories_column_name, category);

        FloatList values = categoryData.getFloatList(values_column_name);
        //values.removeValues(null);

        //println(values);

        if (values.size()>0) {  
          if (yMax<values.max() )
          {
            yMax = values.max();
          }

          if (yMin>values.min() )
          {
            yMin = values.min();
          }

          float value = getMedian(values);
          if (value!=-1)
          {

            value = map(value, yMin, yMax, 0, hh);

            g.fill(COLOUR);
            g.noStroke();

            g.rect(xStep*i, hh, xStep-column_gap, -value );
            //g.rect(xStep*i, hh, xStep-column_gap, -10 * random(19) );
            g.textAlign(LEFT, TOP);
            g.text(categories.get(i), xStep*i, hh);
            g.textAlign(LEFT, BOTTOM);
            //g.text(percentage.format(value/100), xStep*i, hh-value);
          }
        }
      }




      //yMax = values.max();
      //yMin = values.min();

      //float value = getMedian(values);
      //value = map(value, yMin, yMax, 0, -hh);


      ////println(value);

      //g.fill(COLOUR);
      //g.noStroke();

      //g.rect(xStep*i, hh, xStep-column_gap, value );
      //g.textAlign(LEFT, TOP);
      //g.text(categories.get(i), xStep*i, hh);
      //}



      g.popMatrix();
      g.endDraw();
    }
  }
}



class HorzStackBar extends Graph
{
  String columnName;
  StringList categories;


  HorzStackBar(Page p_, int x_, int y_, int w_, int h_)
  {
    super(p_, x_, y_, w_, h_);
    type = "Horizontal Stacked Bar Chart";
    categories = new StringList();
  }

  void addCategory(String s) {
    categories.append(s);
  }

  void setColumnName(String s)
  {
    columnName = s;
  }

  void drawElement(PGraphics g)
  {
    if (data!=null) 
    {
      g.beginDraw();
      g.pushMatrix();
      g.translate(xx, yy);

      g.textAlign(LEFT, BOTTOM);
      g.text(columnName, 0, 0);

      IntDict values = data.getTally(columnName);
      values.remove(null);

      if (categories.size()>0)
      {
        //only take the listed categories and remove the others.
        IntDict tempValues = new IntDict();

        for (int i = 0; i<categories.size(); i++)
        {
          String key1 = categories.get(i);
          int v = values.get(key1);
          tempValues.add(key1, v);
        }

        values = tempValues;
      } else {

        values.sortValuesReverse();
      }


      FloatDict percs = values.getPercent();



      float offset = 0.0;

      for (int i = 0; i<percs.size(); i++)
      {

        String label = percs.key(i);
        float v = percs.get(label);
        float size = ww*v;

        g.noFill();
        g.stroke(0);
        g.rect(offset, 0, size, hh);
        g.textAlign(CENTER, CENTER);
        g.textFont(big_label_font);

        //String s = label+"%n"+percentage.format(v*100);
        //s = String.format(s);
        //s+="%";
        //g.text(s, offset+(size/2), hh/2);



        offset+=size;
      }

      //println(percs);

      g.popMatrix();
      g.endDraw();
    }
  }
}///HorzStackBar


class Square extends Graph
{
  Square(Page p_, int x_, int y_, int w_, int h_)
  {
    super(p_, x_, y_, w_, h_);
    type = "Square";
  }

  void drawElement(PGraphics g)
  {

    g.beginDraw();
    g.pushMatrix();
    g.translate(xx, yy);

    g.fill(COLOUR);
    g.rect(0, 0, ww, hh);


    g.popMatrix();
    g.endDraw();
  }
}




class TextList extends Graph
{
  PFont font;
  int n;
  String category_column;
  String value_column;

  TextList(Page p_, int x_, int y_, int w_, int h_)
  {
    super(p_, x_, y_, w_, h_);
    type = "TextList";

    n=0;
  }

  void setNumber(int i)
  {
    n = i;
  }

  void setCategory(String s)
  {
    category_column = s;
  }

  void setValue(String s)
  {
    value_column = s;
  }

  void drawElement(PGraphics g)
  {
    if (data!=null) 
    {
      g.beginDraw();
      g.pushMatrix();
      g.translate(xx, yy);

      if (!isNullOrBlank(title))
      {
        g.textAlign(LEFT, BOTTOM);
        g.text(title, 0, 0);
      }

      FloatDict list = new FloatDict();

      String [] categories = data.getUnique(category_column);

      for (String category : categories)
      {
        Table category_data = sift(data, category_column, category);

        float category_median = getMedian(category_data, value_column);

        if (isNumeric(category_median+"") )
        {

          list.add(category, category_median);
        }
      }
      list.remove(null);
      list.remove("Other");

      list.sortValuesReverse();

      yStep = hh/(n);

      for (int i = 0; i<n; i++)
      {
        float text_y = i*yStep;
        String label = list.key(i);
        float value = list.get(label);
        g.textAlign(LEFT, TOP);
        //g.textFont(reallyBigTitle);
        g.fill(0);
        //g.text(label+"  "+money.format(value), 0, text_y);
        g.textSize( yStep *.66  ) ;
        g.text(label.toUpperCase(), 0, text_y);
      }

      g.popMatrix();
      g.endDraw();
    }
  }
}

class RatioBar extends Graph
{
  String column_name;
  StringList categories;
  StringList exclusions;


  RatioBar(Page p_, int x_, int y_, int w_, int h_)
  {
    super(p_, x_, y_, w_, h_);
    type = "Ratio Bar";
    categories = new StringList();
    exclusions = new StringList();
  }

  void setColumnName(String s)
  {
    this.column_name = s;
  }

  void addExclusion(String s)
  {
    exclusions.append(s);
  }

  void drawElement(PGraphics g)
  {
    if (data!=null) 
    {
      g.beginDraw();
      g.pushMatrix();
      g.translate(xx, yy);


      g.textAlign(LEFT, BOTTOM);
      g.text(column_name, 0, 0);


      //FloatList values = data.getFloatList<
      IntDict values = data.getTally(column_name);
      FloatDict percValues = values.getPercent();
      percValues.remove(null);

      for (int i = 0; i<exclusions.size(); i++)
      {
        percValues.remove(exclusions.get(i));
      }

      float offset = 0;
      int i=0;

      g.noStroke();
      for (String s : percValues.keys() )
      {
        g.fill(makeAColour(i++, percValues.size()), 100);
        float v = percValues.get(s);
        float value_label = values.get(s);
        g.rect(offset, 0, ww*v, hh);
        g.fill(0);
        g.textAlign(CENTER, CENTER);

        float label_x = offset+(ww*v*.5);
        float label_y = hh*.5;
        //String.format(s); 
        g.text(s, label_x, label_y);
        //g.text(df0.format(value_label), label_x, label_y+10);

        offset+=ww*v;
      }


      //g.rect(0, 0, ww, hh);

      g.popMatrix();
      g.endDraw();
    }
  }
}//ratiobar
