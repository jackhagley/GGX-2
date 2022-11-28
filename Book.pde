////////////////////////////////////////////
//////////////////GRAPH/////////////////////
////////////////////////////////////////////

class Graph extends Element
{ 

  Table data; // for unconnected graphs
  float xMax, xMin, yMax, yMin;
  float xStep, yStep;
  boolean displayTitle = true;
  String title="";
  HashMap<String, Table> inputs_data;


  Graph(Page p_, int x_, int y_, int w_, int h_)
  {
    super(p_, x_, y_, w_, h_);
    //portman = new ElementPortManager(this);
    inputs_data = new HashMap<String, Table>();
    data = new Table();
  }

  void printdata()
  {    

//    PrintWriter debugout = createWriter(title+"-printdata.txt");
//    //data.write(debugout);
//    debugout.flush();
//    debugout.close();
  }

  void setTitle(String s)
  {
    title = s;
  }

  void setXMax(float n)
  {
    xMax = n;
  }

  void setXMin(float n)
  {
    xMin = n;
  }

  void setYMax(float n)
  {
    yMax = n;
  }

  void setYMin(float n)
  {
    yMin = n;
  }
  
  float getRange(float a, float b)
  {
    return abs(a)+abs(b); 
  }
  
  float getYRange()
  {
  return getRange(yMax,yMin); 
  }
  
  float getXRange()
  {
   return getRange(xMax,xMin); 
  }

  void addData(String filename)
  {
    data = loadTable(filename, "header");
  }

  void addData(Table t)
  {
    data = cloneTable(t);
  }

  void displayTitleOn()
  {
    displayTitle = true;
  }

  void displayTitleOff()
  {
    displayTitle = false;
  }

  void addIn(String new_in, String data_type_)
  {
    //data.addColumn(new_in);

    super.addIn(new_in, data_type_);
    inputs_data.put(new_in, new Table());
    
  }

  //void addIn(String new_in, String data_type_)
  //{
  //  portman.addIn(new_in, data_type_);
  //}



  void updateDisplay()
  {

    super.updateDisplay();
  }

  void display()
  {  
    fill(ui.GH);
   
    super.display();
  }

  void updateData()
  {
    ///need as many tables as there are inputs
    //for (int i = 0; i<epm.ins.size(); i++)
    //{
    //  ///name them and store them according to the name of the in

    //}



      //look at each of the ins in turn
      for (int i = 0; i<epm.ins.size(); i++)
      {
        
        //String port_label = epm.ins.get(i).label;
        
        if (epm.ins.get(i).cable!=null)//has a cable attached
        {  
          Datum temp_datum = epm.ins.get(i).cable.datumRefI;
          if (temp_datum!=null)
          {
            int out_data_column_number = epm.ins.get(i).cable.getOutPortNumber();//could this be encapsulated better?
            int out_data_row_count = temp_datum.data.getRowCount();///so colour needs to be formalised into Table object? Surely wasteful??

            //clear out old data
            if (data!=null) {
              data.clearRows();
              //displayValues.clearRows();
            }

            for (int r = 0; r<out_data_row_count; r++)
            {
              if (epm.ins.get(i).data_type.equals("float"))
              {
                data.setFloat(r, i, temp_datum.data.getFloat(r, out_data_column_number-1));
              }
            }

            for (int r = 0; r<out_data_row_count; r++)
            {
              if (epm.ins.get(i).data_type.equals("String"))
              {
                data.setString(r, i, temp_datum.data.getString(r, out_data_column_number-1));
              }
            }
            ///////
          }//tempdatum
        }//ins not null
      }//for each in

    updateDisplay();
  }//updateData
}

////////////////////////////////////////////
//////////////////GRAPH/////////////////////
////////////////////////////////////////////


class Element
{

  PVector loc;//Changed from ints to PVectors
  int w, h;//size in grid
  float xx, yy, ww, hh;//calculated size for display/print
  float size;
  float xOff, yOff;


  color COLOUR;
  color HL =  #FF00D5;
  float transparency=255;


  boolean ColourIsSet = false;

  PGraphics buffer;
  //HashMap<String, Integer> feels;//how does it feel about other things?
  //ArrayList<String> tags;//what properties does it have itself?

  boolean canBeOverlapped = false;

  ///for UI, not used at the moment
  boolean isSelected;


  /////HIERARCHIES///
  Page parent_page;
  ElementPortManager epm;

  String type;

  ///movement things
  float xMove, yMove;

  float borderLeft, borderRight;



  int id; //id number, used for testing
  boolean id_added;
  int page_number;
  

  boolean clicked;

  Element(Page p_, int x_, int y_, int w_, int h_)
  {
    this.parent_page = p_;
    loc = new PVector(x_, y_, 1);
    this.w = w_;
    this.h = h_;
    size = w*h;
    //tags = new ArrayList<String>();
    //feels = new HashMap<String, Integer>();
    p_.addElement(this);
    epm = new ElementPortManager(this);

    transparency = 255;
    
    

    int page_number = book.pages.indexOf(parent_page);
    updateDisplay();
  }

  void display()
  {
    if (ui.dm)
    {
      //fill must be defined by the element!
      //so that graphics/graphs are separate
      pushStyle();
      stroke(ui.LN);
      strokeWeight(1);
      rect(xx, yy, ww, hh);

      epm.display();
      fill(255);
      textAlign(LEFT);
      textFont(ui.datafont);
      if (!isNullOrBlank(type)) {
        text(type, xx+4, yy+4, ww-4, hh-4);
      } else {
        println("you are being lazy and have not defined a type for the graph. But as you haven’t defined its type, I can’t tell you what it is. Perhaps this should be a lesson to you");
        popStyle();
      }
    } else
    {
      //image(buffer, 0, 0);
    }
  }

  int getPageNumber()
  {
    return book.pages.indexOf(parent_page);
  }


  void write(PGraphics pdf)
  {
    try {
      pdf.image(buffer, 0, 0, ww, hh);
    }
    catch(NullPointerException np11) {
      println(type+" "+id+" does not have a proper write command");
    }
  }

  void setBorderLeft(float f) {
    this.borderLeft = f;
    updateDisplay();
  }

  void setBorderRight(float f) {
    this.borderRight = f;
    updateDisplay();
  }

  void drawElement(PGraphics g) {
    println("you haven’t made drawElement for "+type);
  }

  void setTransparency(float trans)
  {
    transparency = trans;
  }

  void dragDisplay() {
    //when the element is being dragged



    fill(COLOUR, 100);
    noStroke();

    float x1 = book.translateMaster.x + mouseX - xMove;
    float y1 = book.translateMaster.y + mouseY - yMove;

    rect(x1, y1, ww, hh);

    noFill();
    if (ui.dm)
    {
      stroke(ui.LN);
    } else {
      stroke(COLOUR);
    }
    //strokeWeight(1);
    strokeWeight(3);

    int x2 = int((x1-parent_page.border_x)/(parent_page.size_grid_x+parent_page.gutter_x));
    int y2 = int((y1-parent_page.border_y)/(parent_page.size_grid_y+parent_page.gutter_y));

    float x3 = xOff+parent_page.border_x+(x2*parent_page.size_grid_x)+(x2*parent_page.gutter_x)+borderLeft;
    float y3 = yOff+parent_page.border_y+(y2*parent_page.size_grid_y)+(y2*parent_page.gutter_y);

    rect(x3, y3, ww, hh);
  }

  JSONObject saveElement()
  {
    JSONObject ele = new JSONObject();

    ele.setInt("id", id);
    ele.setFloat("x", loc.x);
    ele.setFloat("y", loc.y);
    ele.setFloat("w", w);
    ele.setFloat("h", h);
    ele.setFloat("xOff", xOff);
    ele.setFloat("yOff", yOff);
    ele.setFloat("size", size);

    ele.setInt("COLOUR", COLOUR);
    ele.setString("type", type);

    //doesn’t yet save feelings etc as this part isn’t properly added


    return ele;
  }

  void updateDisplay()
  {
    loc = normaliseVector(loc);
    xx = xOff+parent_page.border_x+(loc.x*parent_page.size_grid_x)+(loc.x*parent_page.gutter_x)+borderLeft;
    yy = yOff+parent_page.border_y+(loc.y*parent_page.size_grid_y)+(loc.y*parent_page.gutter_y);
    ww = w*parent_page.size_grid_x+(w*parent_page.gutter_x)-parent_page.gutter_x-borderLeft;
    hh = h*parent_page.size_grid_y+(h*parent_page.gutter_y)-parent_page.gutter_y;

    epm.updateDisplay();
    
    buffer = createGraphics(int(ww),int(hh));
    
  }


  boolean mouseOver() {
    if (
      mouseX>= parent_page.parent_book.translateMaster.x+xx
      &&mouseX<= parent_page.parent_book.translateMaster.x+xx+ww
      &&mouseY>= parent_page.parent_book.translateMaster.y+yy
      &&mouseY<= parent_page.parent_book.translateMaster.y+yy+hh)
    {
      return true;
    } else {
      return false;
    }
  }

  boolean isType(String s) {

    return (s.equals(this.type));
  }

  void addID(int id_number)
  {
    if (!id_added) {
      id = id_number;
      id_added=false;
    } else {
      println("duplicate id. error!");
    }
  }

  void step() {
  }

  void unclick()
  {
    clicked = false;
  }

  void click() {
    clicked = true;
    parent_page.selected = this;
  }


  void updateData() {
    println("element.super.updateData() is here");
  }

  void addIn(String new_in, String data_type_)
  {
    epm.addIn(new_in, data_type_);
  }


  void setLoc(float x_, float y_)
  {
    int x1 = int((x_-parent_page.border_x)/(parent_page.size_grid_x+parent_page.gutter_x));
    int y1 = int((y_-parent_page.border_y)/(parent_page.size_grid_y+parent_page.gutter_y));
    loc.set(x1, y1); 
    updateDisplay();
  }

  void setLoc(int x_, int y_)
  {
    loc.set(x_, y_);
    loc = normaliseVector(loc);
    updateDisplay();
  }

  void addLoc(PVector p)
  {
    loc.add(p);
    updateDisplay();
  }

  void setW(int w_)
  {
    this.w = w_;
    size = w*h;
    updateDisplay();
  }

  void setH(int h_)
  {
    this.h = h_;
    size = w*h;
    updateDisplay();
  }

  void setColour(color c)
  {
    COLOUR = c;
    ColourIsSet = true;
  }

  void setColour(color c, float trans)
  {
    COLOUR = color(c, trans); 
    ColourIsSet = true;
  }

  void setXoff(float newX) {
    this.xOff = newX;
    updateDisplay();
  }

  void setYoff(float newY) {
    this.yOff = newY;
    updateDisplay();
  }
}


class EleCompSize implements Comparator <Element> {

  int compare(Element e1, Element e2)
  {

    if (e1.size == e2.size)
    {
      return 0;
    } 

    if (e1.size > e2.size)
    {
      return -1;
    }

    if (e1.size < e2.size)
    {
      return 1;
    } 

    return int(e1.size - e2.size);
  }
}



//class Square extends Graphic {

//  Square(Page p, int x_, int y_, int w_, int h_)
//  {
//    super(p, x_, y_, w_, h_);
//    COLOUR = color(200, 0, 0, 75);
//    type = "Square";
//    //addIn("colour", "colour");
//  }

//  void display()
//  { 
//    if (!ui.dm) {
//      //buffer.updatePixels();
//      //image(buffer, 0, 0);
//    } else {
//      super.display();
//    }
//  }


//  JSONObject saveElement()
//  {
//    JSONObject temp = super.saveElement();

//    return temp;
//  }


//  void drawElement(PGraphics g)
//  {    
//    g.beginDraw();
//    g.pushMatrix();
//    g.translate(xx, yy);
//    g.fill(COLOUR);
//    g.noStroke(); 
//    g.rect(0, 0, ww, hh);
//    g.popMatrix();
//    g.endDraw();
//  }
//}//square


class HorzLine extends Element
{
  float weight;

  HorzLine(Page p_, int x_, int y_, int w_, int h_)
  {
    super(p_, x_, y_, w_, h_);
  }

  void setWeight(float weight_)
  {
    this.weight = weight_;
  }

  void drawElement(PGraphics g)
  {    
    g.beginDraw();
    g.pushMatrix();
    g.translate(xx, yy);

    if (weight>0) {
      g.strokeWeight(weight);
    } else {
      g .strokeWeight(1);
    }

    g.stroke(COLOUR);
    g.strokeCap(SQUARE);
    g.line(0, 0, ww, 0);

    g.popMatrix();
    g.endDraw();
  }
}





class Graphic extends Element
{
  Graphic (Page p, int x_, int y_, int w_, int h_)
  {
    super(p, x_, y_, w_, h_);
  }


  void display()
  {
    fill(ui.GC);
    super.display();
  }
}

class TextBox extends Graphic
{
  /*
  Initial Read order is 
   determined by the order
   in which the text boxes
   are added.
   */

  PFont font;
  float fontSize;

  String text;
  String alignmentH;
  String alignmentV;


  TextBox(Page p, int x_, int y_, int w_, int h_)
  {
    super(p, x_, y_, w_, h_);
    type = "Text Box";
    this.text = "";
    this.alignmentH = "l";
    this.alignmentV = "b";
  }

  TextBox(Page p, int x_, int y_, int w_, int h_, String t_)
  {
    super(p, x_, y_, w_, h_);
    type = "Text Box";
    this.text = t_;
    //this.type = ;
    this.alignmentH = "l";
    this.alignmentV = "b";
  }

  void setFontSize(float size_)
  {
    this.fontSize = size_;
  }

  void setFont(PFont f1)
  {
    this.font = f1;
    //*mmpx;
  }

  void setFont(String font_, float size_)
  {
    fontSize = size_;
    this.font = createFont(font_, fontSize);
    this.size = size_;
    //*mmpx;
  }

  void setTextFromFile(String filename)
  {
    String temp[] = loadStrings(filename); 
    for (int i = 0; i<temp.length; i++)
    {
      text+=temp[i];
    }
  }


  void setText(String s) {
    this.text = s;
  }

  void setText(int input) {
    this.text = Integer.toString(input);
  }

  void alignH(String s) {

    alignmentH = s;
  }

  void alignV(String s) {

    alignmentV = s;
  }

  void drawElement(PGraphics g)
  {
    if (!isNullOrBlank(text)) 
    {
      g.beginDraw();
      g.pushMatrix();
      g.translate(xx, yy+yOff);

      if (!isNullOrBlank(alignmentH)) {

        if (alignmentH.equals("r")) {
          g.textAlign(RIGHT, CENTER);
        }
        if (alignmentH.equals("c")) {
          g.textAlign(CENTER, CENTER);
        }
        if (alignmentH.equals("l")) {
          g.textAlign(LEFT, CENTER);
        }
      }

      g.fill(COLOUR, transparency);
      g.textFont(font);
      g.text(text, 0, 0, ww, hh);


      g.popMatrix();
      g.endDraw();
    }
  }
}


/////////////////PAGE/////////////////////////

class Page {

  Book parent_book;

  color COLOUR =255;

  color HL = #000000;
  color UH = #979797;
  color line;

  boolean showGrid = false;

  ArrayList<Element> elements;
  ArrayList<Cable> cables;
  Element selected; //uses this when an element is selected

  ///GRID
  //number of grid squares
  int n_grid_x;
  int n_grid_y;

  //size of grid squares
  float size_grid_x;
  float size_grid_y;

  //border is around everything
  float border_x;
  float border_y;

  //gutter is between grid squares
  float gutter_x;
  float gutter_y;

  ///count is used to id the elements
  int count = 0;

  float w, h;
  int ww, hh;

  PGraphics buffer;

  //JSONArray pageSave;

  JSONObject pageSave;

  Page(Book b_) {

    this.parent_book = b_;

    w = parent_book.w;//floats for display
    h = parent_book.h; 
    ww = parent_book.ww;//ints for render/screen
    hh = parent_book.hh;
    buffer = createGraphics(ww, hh);

    this.border_x = 0;
    this.border_y = 0;
    this.gutter_x = 0;
    this.gutter_y = 0;
    this.n_grid_x = 1;
    this.n_grid_y = 1;

    elements = new ArrayList<Element>();
    cables = new ArrayList<Cable>();

    parent_book.addPage(this);
    
    //this.buffer = createGraphics(ww, hh);

    //pageSave = new JSONObject();//TODO
  }


  void setBGColour(color c)
  {
    COLOUR = c;
  }

  JSONObject savePage()
  {
    //pageSave.setInt("page number", parent_book.pages.indexOf(this));
    //pageSave.setFloat("w", w);
    //pageSave.setFloat("h", hh);
    //pageSave.setFloat("ww", ww);
    //pageSave.setFloat("hh", hh);
    //doesn’t need the w,h stuff as it comes from book anyhoo


    pageSave.setFloat("border_x", border_x);
    pageSave.setFloat("border_y", border_y);
    pageSave.setFloat("gutter_x", gutter_x);
    pageSave.setFloat("gutter_y", gutter_y);
    pageSave.setFloat("n_grid_x", n_grid_x);
    pageSave.setFloat("n_grid_y", n_grid_y);



    JSONArray JSelements = new JSONArray();
    for (int i = 0; i<elements.size (); i++)
    {
      JSelements.setJSONObject (elements.get(i).id-1, elements.get(i).saveElement() );
    }
    pageSave.setJSONArray("elements", JSelements);

    JSONArray JScables = new JSONArray();
    for (int i = 0; i<cables.size (); i++)
    {
      JSelements.setJSONObject (cables.get(i).id, cables.get(i).saveCable() );
    }
    pageSave.setJSONArray("cables", JScables);

    return pageSave;
  }

  void addElement(Element e)
  {
    elements.add(e);
    count++;
    e.addID(count);
  }


  void makeNewCable(DatumOut start, ElementIn end)
  {
    Cable c = new Cable(start, end);
    cables.add(c);
    println("number of cables: "+book.currentPage.cables.size());
  }

  void removeCable(Cable c_) {
    cables.remove(c_);
  }


  void update()
  {
  }

  void unclick() {
    for (Element e : elements)
    {
      e.unclick();
    }
    selected = null;
  }

  void display() {

    strokeWeight(1);
    if (ui.dm)
    {
      fill(ui.BG);
      stroke(ui.LN, 100);
      rect(0, 0, w, h);

      for (Cable c_ : cables)
      {
        c_.display();
      }
    } else {
      fill(255);
      stroke(151);
      rect(0, 0, w, h);
      image(buffer, 0, 0);
    }

    for (Element e : elements)
    {
      e.display();
    }
  }

  void toggleGrid()
 {
    showGrid=!showGrid;
    updateDisplay();
  }

  void gridOn()
 {
    showGrid= true;
    updateDisplay();
  }
  void gridOff()
  {
    showGrid= false;
    updateDisplay();
  }


  void setBorder(float newX, float newY)
  {
    this.border_x = newX;
    this.border_y = newY;

    if (is_for_print)
    {
      this.border_x = newX*mmpx;
      this.border_y = newY*mmpx;
    }

    updateDisplay();
  }

  void setGrid(int newX, int newY) {
    ///these are the number of grid lines, not measurements
    this.n_grid_x = newX;
    this.n_grid_y = newY;
    updateDisplay();
  }

  void setGutter(float newX, float newY)
  {
    this.gutter_x = newX;
    this.gutter_y = newY;

    if (is_for_print)
    {
      this.gutter_x = newX*mmpx;
      this.gutter_y = newY*mmpx;
    }
    updateDisplay();
  }


  void updateDisplay() {
    //update should only be called when the size
    //or the number of cells changes
    //buffer = createGraphics(ww, hh);
    buffer.beginDraw();
    buffer.clear();

    size_grid_x = (w-(2*border_x)-((n_grid_x-1)*gutter_x)) /n_grid_x;
    size_grid_y = (h-(2*border_y)-((n_grid_y-1)*gutter_y)) /n_grid_y;

    drawElement(buffer);

    for (Element e : elements) {
      e.updateDisplay();
      e.drawElement(buffer);
    }

    buffer.endDraw();

    stroke(200, 0, 0, 133);
    strokeWeight(.5);
    noFill();
  }

  void drawElement(PGraphics pg) 
  {
    pg.beginDraw();
    pg.background(COLOUR);
    if (showGrid) {


      pg.strokeWeight(1);

      for (int i=0; i<n_grid_x; i++)
      {
        float x = border_x + (i*size_grid_x) + (i * gutter_x);
        for (int j=0; j<n_grid_y; j++)
        {
          float y = border_y + (j*size_grid_y) + (j * gutter_y);
          pg.stroke(#00FFFF);
          pg.noFill();
          pg.rect(x, y, size_grid_x, size_grid_y);

          pg.fill(#00FFFF);
          pg.noStroke();
          textAlign(CENTER, CENTER);
          pg.text(i+","+j, x + (size_grid_x/2), y + (size_grid_y/2) );
        }
      }
    }
    pg.endDraw();
  }




  void write(PGraphics pdf) {
    for (Element e : elements) {
      e.drawElement(pdf);
    }
  }//writer
}//Page class


class Book {

  //Page stuff
  Page currentPage;//only displays this one
  int current = 0;//number of current page
  ArrayList<Page> pages;



  //display values
  float w, h; //
  int ww, hh; // int values for buffers etc
  PVector translateMaster; //used for viewing

  //output
  PGraphics output;
  String title;

  ArrayList<Datum> datums;//datums are page agnostic, cables are page specific
  int datumCount = 0;

  //SELECTED
  Datum selected_datum;
  Port selected_port;

  JSONObject bookSave;
  //JSONArray bookSave;


  boolean border_is_set=false;///not implemented!
  boolean gutter_is_set=false;///not implemented!
  boolean margin_is_set=false;///not implemented!

  ///GRID
  //number of grid squares
  int n_grid_x;///not implemented!
  int n_grid_y;///not implemented!

  //size of grid squares
  float size_grid_x;///not implemented!
  float size_grid_y;///not implemented!

  //border is around everything
  float border_x;///not implemented!
  float border_y;///not implemented!

  //gutter is between grid squares
  float gutter_x;///not implemented!
  float gutter_y;///not implemented!


  //CONSTRUCTOR
  Book(float w_, float h_, String t_)
  {

    ///DISPLAY
    if (is_for_print)
    {
      w_*=mmpx;
      h_*=mmpx;
    }

    this.w = w_;
    this.h = h_;

    ww = (int)w;
    hh = (int)h;

    ///DATA

    cd = new CommanderData();

    pages = new ArrayList<Page>();
    datums = new ArrayList<Datum>();


    this.title = t_;

    translateMaster = new PVector( (width/2) + (-w/2), (height/2) + (-h/2) );

    output = createGraphics(this.ww, this.hh, PDF, "output/"+title+".pdf");

    //bookSave = new JSONObject();//TODO
  }

  void reset()
  {
    pages.clear();
    datums.clear();
  }

  void saveBook()
  {

    bookSave.setString("document title", title);
    bookSave.setInt("ww", ww);
    bookSave.setInt("hh", hh);
    bookSave.setFloat("w", w);
    bookSave.setFloat("h", h);
    bookSave.setFloat("n_pages", pages.size());


    /////PAGES////////////////////////
    JSONArray  pagesJSON = new JSONArray();
    for (int i = 0; i<pages.size (); i++)
    {
      String p = "page number "+i;
      //bookSave.setJSONObject (p, pages.get(i).savePage());
      pagesJSON.setJSONObject (i, pages.get(i).savePage());
    }
    bookSave.setJSONArray("pages", pagesJSON);
    /////PAGES////////////////////////

    /////DATUM////////////////////////
    JSONArray JSdatums = new JSONArray();
    for (int i = 0; i<datums.size (); i++)
    {
      JSdatums.setJSONObject (datums.get(i).id-1, datums.get(i).saveDatum() );
    }

    bookSave.setJSONArray("datums", JSdatums);
    /////DATUM////////////////////////


    saveJSONObject(bookSave, "files/"+title+".json");
  }

  void loadBook(String fileName)
  {

    println("load and save are borken");
    //    reset();
    //
    //
    //    JSONObject bookFile = loadJSONObject(fileName);
    //
    //
    //    JSONArray datums = bookFile.getJSONArray("datums");
    //    for (int i = 0; i<datums.size(); i++)
    //    {
    //      JSONObject datum = datums.getJSONObject(i);
    //      //how do I load the object if I am not sure what kind of thing it is going to be
    //    }
    //
    //
    //    JSONArray pages = bookFile.getJSONArray("pages"); 
    //    println(pages);
  }


  void display()
  {
    if (ui.dm) {
      background(#000000);
    } else {
      background(#b0b0b0);
    }

    pushMatrix();
    scale(zoom);
    translate(translateMaster.x, translateMaster.y);


    if (currentPage!=null) {
      currentPage = pages.get(current);
      currentPage.display();
    }

    if (ui.dm) {
      for (Datum d : datums) {
        d.display();
      }
    }


    if (book.currentPage.selected!=null) {

      book.currentPage.selected.dragDisplay();
    }


    popMatrix();

    if (mouseHasDatumOut)
    {
      stroke(ui.LN);
      line(translateMaster.x+book.selected_port.loc.x+book.selected_port.offset+(book.selected_port.w/2), translateMaster.y + book.selected_port.loc.y, mouseX, mouseY);
    }
  }

  void toggleGrid()
  {
    for (Page p : pages)
    {
      p.toggleGrid();
    }
  }

  void run()
  {
    updateUI();

    display();
  }

  void write()
  { 
    PGraphicsPDF pdf = (PGraphicsPDF) output;  // Get the renderer
    output.beginDraw();
    //output.textMode(MODEL);
    for (int i = 0; i<pages.size (); i++)
    {
      pages.get(i).write(pdf);

      if (i+1<pages.size ())///this makes sure there is no empty page at the end of the document
      {
        pdf.nextPage();
      }
    }
    output.dispose();
    output.endDraw();
  }



  void addPage(Page p_) {
    pages.add(p_);
    //println(pages.size());
    updateDisplay();
  }

  void addDatum(Datum d_)
  {
    datums.add(d_);
    datumCount++;
    d_.addID(datumCount);
  }


  void unclick() {
    currentPage.unclick();
    for (Datum d : datums)
    {
      d.unclick();
    }
    selected_port = null;
    selected_datum = null;
  }

  void update()
  {
  }

  void updateUI()
  { 
    if (ui.dm) {
      for (Datum d_ : datums)
      {
        d_.updateDisplay();
      }
    }
  }


  void updateDisplay()
  { 

    if (pages.size()>0)
    {
      currentPage = pages.get(current);
    }
    //currentPage.updateDisplay();

    try {

      currentPage.updateDisplay();
    }
    catch(NullPointerException np5)
    {
      println("somehow the current page has disappeared while updating");
    }
  }




  void setTitle(String t_)
  {
    this.title = t_;
    output = createGraphics(this.ww, this.hh, PDF, title+"_"+".pdf");
  }
}////BOOK

//////////////////////////////COMMANDER DATA////////////////////
class CommanderData
{
  //wraps up all the data commands

  String[] fontList;
  String[] filenames;

  CommanderData() {
    fontList = PFont.list(); 
    java.io.File folder = new java.io.File(dataPath(""));
    filenames = folder.list();
    //println(fontList);
  }

  void printFontList()
  {
    println(fontList);
  }

  ///needs a reload function here so that you can update the file list
}
///////////COMMANDER DATA////////////////////


class DisplayHelper
{
  ArrayList<DisplayLine>lines;//should be 2D array and have no lines

  DisplayHelper()
  {
    init();
  }

  DisplayHelper(DisplayCell firstCell)
  {
    init();
  }

  void init()
  {
    lines = new ArrayList<DisplayLine>();
  }
}

class DisplayLine
{
  /* 
   subclass that stores data when the final sizes
   of columns and height of lines is not yet known
   */

  ArrayList<DisplayCell>cells;

  DisplayLine(DisplayCell cell)
  {
    init();
    addCell(cell);
  }

  void init()
  {
    cells = new ArrayList<DisplayCell>();
  }

  void addCell(DisplayCell cell)
  {
    cells.add(cell);
  }


  ///return largest cell height;

  ///return largest cell width;
}

class BooleanCell extends DisplayCell
{
  boolean data;

  BooleanCell(boolean b)
  {
    super();
    this.data = b;
  }
}

class StringCell extends DisplayCell
{
  String data;

  StringCell(String s)
  {    
    super();
    this.data = s;
  }
}

class DisplayCell
{  
  /*
 subclass that further divides displayLine, used for storing data types for data
 */
  float h, w;//proportional sizes
  float ww, hh;//display sizes;
}
