
//LaunchControl lc;

////lc = new LaunchControl();
////lc.setRange(21, 0.0, 255.0);
////lc.setRange(22, 0.0, 255.0);
////lc.setRange(23, 0.0, 255.0);
////lc.toggle();

//class LaunchControl
//{
//  ///CAREFUL

//  ///ARE YOU USING user OR factory MODE? 

//  //store the values
//  float   values            [];
//  boolean buttonOn          [];
//  boolean buttonsAreToggles [];

//  //range
//  float minValue [];
//  float maxValue [];

//  LaunchControl()
//  {
//    //POTS
//    values = new float[99];
//    minValue = new float [99];
//    maxValue = new float [99];

//    //BUTTONS
//    buttonOn = new boolean[30];
//    buttonsAreToggles = new boolean[30];

//    for (int i = 0; i<99; i++)
//    {
//      minValue[i] = 0; 
//      maxValue[i] = 127;
//    }
//  }

//  void buttonPressed(int number) {
//    if (buttonsAreToggles[number])
//    {
//      buttonOn[number] = ! buttonOn[number];
//    } else
//    {
//      buttonOn[number] = true;
//    }

//    //switch(number)
//    //{
//    //case 9:
//    //  break;

//    //case 10:
//    //  break;

//    //case 11:
//    //  break;

//    //case 12:
//    //  break;

//    //case 25:
//    //  break;

//    //case 26:
//    //  break;

//    //case 27:
//    //  break;

//    //case 28:
//    //  break;
//  }
//}

//void buttonReleased(int number) {
//  if (!buttonsAreToggles[number])
//  {
//    buttonOn[number] = false;
//  }

//  switch(number)
//  {
//  case 9:
//    break;

//  case 10:
//    break;

//  case 11:
//    break;

//  case 12:
//    break;

//  case 25:
//    break;

//  case 26:
//    break;

//  case 27:
//    break;

//  case 28:
//    break;
//  }
//}


/////POTS

//void turnPot(int channel, int number, int value)
//{
//  float v = map(value, 0, 127, minValue[number], maxValue[number]);
//  values[number] = v;
//  println(v);
//  book.updateDisplay();
//}

//void setAllRange(float min_, float max_)
//{
//  for (int i = 0; i<99; i++)
//  {
//    minValue[i] = min_; 
//    maxValue[i] = max_;
//  }
//}

//void setMin(int number, float min_)
//{
//  minValue[number] = min_;
//}

//void setMax(int number, float max_)
//{
//  maxValue[number] = max_;
//}

//void setRange(int number, float min_, float max_)
//{

//  minValue[number] = min_; 
//  maxValue[number] = max_;
//}


//void setValue(int number, float value)
//{
//  values[number] = value;
//}


//float getValue(int number)
//{
//  return values[number];
//}


/////BUTTONS

//void toggle(int number)
//  ///actually a toggle that toggles toggle.
//{
//  buttonsAreToggles[number] = ! buttonsAreToggles[number];
//}

//boolean isButtonOn(int number)
//{
//  return buttonOn[number];
//}
//}/////END OF LAUNCH CONTROL//////////



/////MIDIBUS STUFF
/////DON’T TOUCH!

//import themidibus.*; //Import the library
//MidiBus myBus; // The MidiBus

//void noteOn(int channel, int pitch, int velocity) {
//  lc.buttonPressed(pitch);
//}

//void noteOff(int channel, int pitch, int velocity) {
//  lc.buttonReleased(pitch);
//}

//void controllerChange(int channel, int number, int value) {
//  lc.turnPot(channel, number, value);
//}
/////MIDIBUS STUFF
/////DON’T TOUCH!


////////////////MOUSE//////////////////////////

boolean mouseHasDatumOut = false;
String book_selected_port_data_type;

void mouseDragged() {


  /////CLICKING AND DRAGGING THINGS
  if (book.currentPage.selected!=null && book.selected_datum==null && book.selected_port==null)
  {


    float x = book.translateMaster.x + mouseX - book.currentPage.selected.xMove;
    float y = book.translateMaster.y + mouseY - book.currentPage.selected.yMove;



    book.currentPage.selected.setLoc(x, y);
  }

  if (book.selected_datum!=null && book.currentPage.selected==null && book.selected_port==null)
  {
    float x = book.translateMaster.x + mouseX - book.selected_datum.xMove;
    float y = book.translateMaster.y + mouseY - book.selected_datum.yMove;

    book.selected_datum.setLoc(x, y);
  }


  /////MAKING CABLES AND THINGS
  if (book.selected_port!=null && book.currentPage.selected==null && book.selected_datum==null)
  {  
    mouseHasDatumOut = true;
    //cursor(HAND);
  }

  if (book.currentPage.selected!=null && book.selected_datum==null && book.selected_port==null)
  {

    textAlign(CENTER, CENTER);

    text(
      book.currentPage.selected.loc.x
      +","+
      book.currentPage.selected.loc.y
      +","+
      book.currentPage.selected.w
      +","+
      book.currentPage.selected.h
      , 
      width/2, 100);
  }
}


void mouseClicked()
{

  for (Element e : book.currentPage.elements)
  {
    for (ElementIn e_i : e.epm.ins) {

      if (e_i.xButton.isOn()  && e_i.xButton.mouseOver() ) {

        removeCable(e_i.cable);
        e_i.xButton.off();
        e.updateData();
      }
    }
  }

  for (Datum d : book.datums)
  {

    for (DatumIn d_i : d.dpm.ins) {

      if (d_i.xButton.isOn()  && d_i.xButton.mouseOver() ) {

        removeCable(d_i.cable);
        d_i.xButton.off();
        d.updateData();
      }
    }
  }
}


void mouseReleased() {
  //here go the checks to see if the mouse is holding something
  if (mouseHasDatumOut)
  {  

    //////ELEMENTS
    for (Element e : book.currentPage.elements)
    {
      for (ElementIn e_i : e.epm.ins) {
        if (e_i.mouseOver()) {
          if (book.selected_port.data_type.equals(e_i.data_type))
          {
            if (e_i.cable==null)
            {

              //book.currentPage.cables.add(new Cable( ((DatumOut)book.selected_port), e_i));

              book.currentPage.makeNewCable( (DatumOut)book.selected_port, e_i);

              //page.addCable(book.selected_port,e_i);
              e.updateData();
            }
          }
        }
      }
    }//elements


    //NOT YET IMPLEMENTED
    //////DATUMS
    for (Datum d : book.datums)
    {
      for (DatumIn d_i : d.dpm.ins) {
        if (d_i.mouseOver())
        {
          if (book.selected_port.data_type.equals(d_i.data_type))
          {
            if (d_i.cable==null)
            {
              book.currentPage.cables.add(new Cable( ((DatumOut)book.selected_port), d_i));
              d.updateData();
            }
          }
        }
      }
    }///datums
  }///DATUM OUT
  mouseHasDatumOut = false;
  //cursor(ARROW);
  book.currentPage.updateDisplay();///should this be here?
  book.unclick();
}


void mousePressed()
{
  for (Element e : book.currentPage.elements)
  {
    if (e.mouseOver()) {
      e.click();
      e.xMove = book.translateMaster.x + mouseX-e.xx;
      e.yMove = book.translateMaster.y + mouseY-e.yy;
    }
  }

  if (ui.dm)
  {
    for (Datum d_ : book.datums)
    {
      if (d_.mouseOver())
      {
        d_.click();
        d_.xMove = book.translateMaster.x + mouseX-d_.loc.x;
        d_.yMove = book.translateMaster.y + mouseY-d_.loc.y;
      }
    }

    for (Datum d_ : book.datums)
    {
      ///PORTS
      for (int i = 0; i<d_.dpm.ins.size(); i++)
      {
        if (d_.dpm.ins.get(i).mouseOver())
        {
          //println(d_.dpm.ins.get(i).loc);
          d_.dpm.ins.get(i).clicked();
          book.selected_port = d_.dpm.ins.get(i);
        }
      }

      for (int o = 0; o<d_.dpm.outs.size(); o++)
      {
        if (d_.dpm.outs.get(o).mouseOver())
        {
          d_.dpm.outs.get(o).clicked();
          book.selected_port = d_.dpm.outs.get(o);
        }
      }
    }///ports
  }///ui dm
}
////////////////MOUSE//////////////////////////

/////////////KEYS////////////////////

void keyReleased() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      if (book.current>0)
      {
        book.current--;
        book.pages.get(book.current).updateDisplay();
      }
    }

    if (keyCode == RIGHT) {
      if (book.current<book.pages.size()-1)
      {
        book.current++;
        book.pages.get(book.current).updateDisplay();
      }
    }
  }


  switch(key) {
  case 'g':
    book.toggleGrid();
    break;

  case 'a':

    break;

    //case 'c':

    //  chopper.chop();
    //  break;

  case '1':

    break;

  case '2':
    //book.pages.get(1).bbc.y_lines.shuffle();

    break;

  case '0':
    zoom = 1;
    break;

  case '9':
    zoom = 2;
    break;

  case 'o':
    book.write();
    break;

  case 'f':
    cd.printFontList();
    break;

  case 's':
    book.saveBook();
    //book.currentPage.buffer.save("1.png");
    break;

  case 'l':
    //book.loadBook("files/GGX20168291682.json");
    //book.currentPage.buffer.save("1.png");
    println("you know that load and save are borked until you learn Serialized");
    break;

  case 'd':
    ui.toggledm();
    break;


  case 'r':
    //c1.randomise();
    break;
  }
}
/////////////KEYS////////////////////

////////////////BUTTON//////////////////////////


interface Clickable {

  boolean mouseOver();

  void click();

  void unclick();
}





class Menu {
  ///
}


class cableDeleteButton extends Button {
  Port parent_port;

  cableDeleteButton(Port p_)
  {
    super("x");
    parent_port = p_;
    loc = new PVector(parent_port.loc.x, parent_port.loc.y);
    COLOUR = ui.BUTTON_DELETE_BG;
  }

  void updateDisplay()
  {
    loc.set(parent_port.loc.x+parent_port.offset+parent_port.w, parent_port.loc.y);
  }

  void display()
  {
    pushStyle();
    noStroke();
    fill(COLOUR);
    rect(loc.x, loc.y, w, h);
    textFont(ui.datafont);
    textAlign(LEFT);
    fill(ui.BUTTON_DELETE_FG);
    text(label, loc.x+4, loc.y+8);
    popStyle();
  }
}

class Button {
  String label;
  float w = 6; 
  float h = 10;
  PVector loc;
  boolean on;
  color COLOUR;

  Button()
  {
  }

  Button(String label_) {
    this.label = label_;

    textFont(ui.datafont);
    try {
      w+=textWidth(label);
    }
    catch( NullPointerException np6)
    {
    }
  }

  void display() {
  }

  boolean mouseOver() {
    if (
      mouseX>= book.translateMaster.x + loc.x
      &&
      mouseX<= book.translateMaster.x + loc.x+w
      &&
      mouseY>= book.translateMaster.y + loc.y
      &&
      mouseY<= book.translateMaster.y + loc.y+h)
    {

      return true;
    } else {

      return false;
    }
  }

  void on()
  {
    on = true;
  }

  void off() {
    on = false;
  }

  boolean isOn() {
    return on;
  }
}


////////////////BUTTON//////////////////////////















////////////////UI//////////////////////////


class UI {

  /*
  All of the colours for everything should be stored here
   then it will be really easy to re-skin it
   
   
   */

  boolean dm;//datamode
  color BG = #000000;//bg
  color LN = #14FF00;//line
  color GH = #004B4D;//datamode graph
  color GC = #304600;//datamode graphic
  color CB = #ffffff;//CABLE;

  color BTBG = #000000;//button background
  color BTFG = #ff00ff;//button foreground
  color BUTTON_DELETE_FG = #000000;//delete (button)
  color BUTTON_DELETE_BG = #ff0000;
  color BUTTON_DELETE_HL = #ff0000;



  PFont datafont;

  UI() {
    dm =false;
    datafont = createFont("Minecraftia", 8);
  }

  void dmON()
  {
    dm = true;
  }

  void dmOFF()
  {
    dm = false;
  }

  boolean dm() {
    return dm;
  }

  void toggledm() {
    dm = !dm;
  }
}
////////////////UI//////////////////////////
