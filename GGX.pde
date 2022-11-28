import processing.pdf.*;
import java.util.Comparator;
import java.util.Collections;
import java.util.Calendar;
import java.text.DecimalFormat;

boolean is_for_print = true; //false if this document is for print
float mmpx = 2.83465;//converts mm to px and back

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
String version  = "0.4";//increment this every time you do something different
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
String bookName = "GGX_ThinkTanks_";
String masterDataFilename = "USUKTT_v6";//no need for csv

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
///Custom values for different visualisations////////////////////////
String y_axis = "Rank";
String x_axis = "Political alignment (0=left, 10=right)";
String big_label_column = "Organisation";
String country_column = "Home Jurisdiction";
String description_column = "Leadership figures & background";
String assigned_colour_column = "Home Jurisdiction";
String bubble_column = "Income $";
String year_column = "Foundation Year";
String [] label_columns = {
big_label_column,
description_column,
};


/////////////////////////////////////////////////////////////////////
/////HACKY SHIT TO MAKE IT WORK//////////////////////////////////////
/////////////////////////////////////////////////////////////////////
float hacked_y_offset = -500; /// negative brings it up
float y_scalar = .9; /// squeezes it
float additional_x_slots = 3; ///bigger fits more stuff on the page



/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

color HIGHLIGHT = #CC00CC;
float scalar = 20;
float zoom = 1;


String date;
String time;
String randomNumber = ""+(int)random(9999);

//String documentName = bookName+"_"+version;

//String documentName = bookName+date+randomNumber;
//String documentName = bookName+"_"+date;
String documentName;

Table masterData;


//for managing fonts etc, not data
CommanderData cd;
//cd should really handle the fonts below
PFont bodyfont;

PFont big_label_font;
PFont arrow_font;
PFont description_font;
PFont year_font;

UI ui;

Book book;
//DecimalFormat money, money2, percentage, percentageChange, df0, df1, df2;


String doc_id;

void setup()
{  
  //size(displayWidth, displayHeight);
  size(1200, 900);

  ///TIMER/////////////
  float t = millis();
  ///TIMER/////////////

  ////UI/////////////
  ui = new UI();
  ////UI/////////////

  ////NAMING///////////////
  output_path += "/";
  date = "Z"+year()+nf(month(), 2)+nf(day(), 2);
  time = "T"+nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
  documentName = bookName+version+" at "+date+time;
  masterDataFilename+= ".csv";
  ////NAMING///////////////


  ////BOOK/////////////////
  //if(is_for_print) = book dimensions in mm//
  /////A4 portrait
  // book = new Book(210, 210, documentName);
  /////A4 landscape
  book = new Book (297, 210, documentName);
  /////A3 landscape
  // book = new Book (420, 297, documentName);
  ///approx powerpoint dimensions
  //book = new Book(338.7, 190.5, documentName);
  ////BOOK////////////////


  ///FONTS/////
  //cd.printFontList();
  big_label_font = createFont("UniversLTStd-BoldCn", 12);
  arrow_font = createFont("UniversLTStd-Cn", 9);
  description_font = createFont("UniversLTStd-Cn", 7);
  year_font = createFont("UniversLTStd-BoldCn", 8);
  ///FONTS/////




  masterData = loadTable(masterDataFilename, "header");
  invertDataValues(masterData, x_axis);
  invertDataValues(masterData, y_axis);
  //invertDataValues(masterData, "Weapons sales");
  //invertDataValues(masterData, "Khashoggi Affair");
  //invertDataValues(masterData, "Energy Interests");
  //invertDataValues(masterData, "Strategic Partner for  Security Goals");
  //invertDataValues(masterData, "Democratic Party Base");
  //invertDataValues(masterData, "US General Public");
  //invertDataValues(masterData, "Re-invigorating JCPOA");
  //invertDataValues(masterData, "De-escalating Tension with Iran ");
  hues = generateHuesForEachEntry(masterData);
  
  setAssignedColours();


  String[] countries = masterData.getUnique(country_column);

  countries = removeEmpty(countries);

  float y_axis_max = returnMaxFloat(masterData, y_axis);
  float y_axis_min = returnMinFloat(masterData, y_axis);

  float x_axis_max = returnMaxFloat(masterData, x_axis);
  float x_axis_min = returnMinFloat(masterData, x_axis);
  


  float biggest_col = 0;
  float biggest_pos = 0;



  //float scale = 1300;

  for (int r = 0; r<masterData.getRowCount(); r++)
  {

    for (int c = arrow_columns_start_at; c<masterData.getColumnCount(); c++)    
    {

      float col_value = abs(masterData.getFloat(r, c));
      float pos_value = abs(masterData.getFloat(r, x_axis));

      if ( (col_value+pos_value) > (biggest_col+biggest_pos) )
      {
        biggest_col = col_value;
        biggest_pos = pos_value;
      }
    }
  }

  float x_slots_needed = (2*biggest_col+biggest_pos)+additional_x_slots;
  
  x_slots_needed = 10+additional_x_slots;
  float y_slots_needed = abs(y_axis_max)+abs(y_axis_min);

  println("x_slots_needed="+x_slots_needed);
  //println("y_slots_needed="+y_slots_needed);

  // float biggest_circle = getCircleDiameterFromValue(yMax*scale);


  //float m_xStep = (ww-biggest_circle)/(2*(biggest_col+biggest_pos));

  ////shaft_length = xStep;

  ////yStep = (-hh+biggest_circle)/getYRange();
  //float m_yStep = (-hh)/getYRange();




  //


  Page summary = new Page(book);
  summary.setGrid(1, 1);
  summary.setBorder(7.5, 8);
  summary.setGutter(5, 5);

  ConvexHull hull_summary= new ConvexHull(summary, 0, 0, 1, 1);
  hull_summary.x_slots_needed = x_slots_needed;
  hull_summary.y_slots_needed = y_slots_needed;
  hull_summary.addData(masterData);
  for (int i = 0; i<countries.length; i++)
  {
    String country = countries[i];
    hull_summary.addDisplayItem(country);
  }



  for (int i = 0; i<countries.length; i++)
  {

    ///PAGE
    Page p = new Page(book);
    p.setGrid(1, 1);
    p.setBorder(7.5, 8);
    p.setGutter(5, 5);//not needed

    ///DATA
    String country = countries[i];
    Table countryData = sift(masterData, country_column, country);


    ConvexHull hull= new ConvexHull(p, 0, 0, 1, 1);
    hull.x_slots_needed = x_slots_needed;
    hull.y_slots_needed = y_slots_needed;
    hull.addData(masterData);
    hull.addDisplayItem(country);

    SentimentMap sentMap1= new SentimentMap(p, 0, 0, 1, 1);
    sentMap1.displayArrows();
    sentMap1.x_slots_needed = x_slots_needed;
    sentMap1.y_slots_needed = y_slots_needed;
    sentMap1.addData(countryData);

    SentimentMap sentMap2= new SentimentMap(summary, 0, 0, 1, 1);

    sentMap2.x_slots_needed = x_slots_needed;
    sentMap2.y_slots_needed = y_slots_needed;
    sentMap2.addData(countryData);
  }





  ////MUST STAY AT BOTTOM
  //book.write();
  book.updateDisplay();

  book.run();
  t = millis()-t;
  //book.saveBook();
  book.write();
  println("done in "+t/1000+" seconds");


  //exit();
}

void draw() {
  book.run();
}
