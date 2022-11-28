/////////////CABLE////////////////////
//////CABLE

int cable_id_count = 1;
class Cable
{

  //used for joining Datum to Datum or Datum to Element
  //must start at a Datum

  Port in;
  Port out;

  int in_port_number = -1;
  int out_port_number = -1;
  int inElement_id = -1;
  int inDatum_id = -1;
  int outDatum_id  = -1;

  int id;

  boolean deleted;
  float dist;

  //values
  color COLOUR = ui.CB;
  float tightness = .5;

  //POSSIBLE SOURCES
  Datum datumRefI;

  ///POSSIBLE SINKS
  Datum datumRefO;
  Element elementRef;

  ///POSSIBLE PORTS
  DatumOut datumOut;
  ElementIn elementIn;
  DatumIn datumIn;

  Cable(DatumOut out_, ElementIn in_) {
    setID();
    inElement_id = in_.manager.parent_element.id;
    outDatum_id = out_.manager.parent_datum.id;

    this.datumOut = out_;
    this.elementIn = in_;

    in_.addCable(this);
    out_.addCable(this);

    this.in = in_;
    this.out = out_;

    elementRef = in_.manager.parent_element;
    datumRefI = out_.manager.parent_datum;

    in_port_number = in_.manager.ins.indexOf(in_);
    out_port_number = out_.manager.outs.indexOf(out_);
    //println("port out "+out_port_number+" goes to "+ "port in "+ in_port_number);

    if (out_.data_type.equals("colour") && in_.data_type.equals("colour"))
    {
      elementRef.setColour(datumRefI.getColour());
    }

    elementRef.updateData();
    dist = in.loc.y-out.loc.y;
    //book.currentPage.cables.add(this);
    println("adding a datum to element cable");
  }

  Cable(DatumOut out_, DatumIn in_) {
    setID();
    inDatum_id = in_.manager.parent_datum.id;
    outDatum_id = out_.manager.parent_datum.id;

    this.datumOut = out_;
    this.datumIn = in_;

    in_.addCable(this);
    out_.addCable(this);

    this.in = in_;
    this.out = out_;

    datumRefO = in_.manager.parent_datum;
    datumRefI = out_.manager.parent_datum;

    in_port_number = in_.manager.ins.indexOf(in_);
    out_port_number = out_.manager.outs.indexOf(out_);
    //println("port out "+out_port_number+" goes to "+ "port in "+ in_port_number);

    datumRefI.updateData();
    dist = in.loc.y-out.loc.y;
    //book.currentPage.cables.add(this);
    println("adding a datum to datum cable");
  }




  JSONObject saveCable()
  { 
    JSONObject cableJSON = new JSONObject();
    //println("saveCable is calling");
    cableJSON.setInt("id", id);
    cableJSON.setInt("inElement_id", inElement_id);
    cableJSON.setInt("inDatum_id", inDatum_id);
    cableJSON.setInt("outDatum_id", outDatum_id);
    cableJSON.setInt("in_port_number", in_port_number);
    cableJSON.setInt("out_port_number", out_port_number);
    return cableJSON;
  }
  void setID() {
    id = cable_id_count++;
    //println("testing cable id count = "+id);
  }

  Table getData()
  {
    return datumIn.data;
  }

  int getOutPortNumber() {
    return out_port_number;
  }

  int getInPortNumber() {
    return in_port_number;
  }

  int getDatumRowCount() {

    if (datumRefI!=null)
    {
      datumRefI.data.getRowCount();
    }

    if (datumRefO!=null)
    {
      datumRefO.data.getRowCount();
    }

    println("ERROR: CABLE — Datum Row Count returning -1");
    return -1;//error like a motherfucker
  }

  void delete() {


    //remove IN connection
    if (elementIn!=null) {
      elementIn.cable = null;

      elementRef.updateData();
    }

    ///remove OUT connection
    datumOut.cables.remove(this);

    //boolean actually never used
    deleted = true;
  }

  void updateDisplay()
  {
  }

  void display()
  {

    if (ui.dm)
    {
      //stroke(ui.LN);
      //line(in.loc.x +(in.w/2)+in.offset, in.loc.y, out.loc.x+(out.w/2)+out.offset, out.loc.y );

      //stroke(255,0,0);
      //
      //point(in.loc.x +(in.w/2)+in.offset, in.loc.y- dist*.25);
      //point(out.loc.x+(out.w/2)+out.offset, out.loc.y + dist*.25);


      stroke(COLOUR);
      noFill();
      strokeWeight(3);
      bezier(in.loc.x +(in.w/2)+in.offset, in.loc.y, in.loc.x +(in.w/2)+in.offset, in.loc.y- dist*tightness, out.loc.x+(out.w/2)+out.offset, out.loc.y + dist*tightness, out.loc.x+(out.w/2)+out.offset, out.loc.y);
    }
  }

  void update()
  {  
    dist = in.loc.y-out.loc.y;
    if (out.data_type.equals("colour") && in.data_type.equals("colour"))
    {
      elementRef.setColour(datumRefI.getColour());
      println("The way that colour is passed is wrong and you need to look in the update of Cable");
    }
  }
}
/////////////////////////CABLE//////////////////////////



////Port

///need a wrapper class for this?
///might be easier when we update the size of the menu

class Port {

  Table data;//must be universal

  String label;
  color COLOUR = #AAFFFF;
  float w=10; 
  float h=10;
  boolean mouseOver;
  boolean clicked;
  boolean mouseDragged;

  boolean connected;

  float offset;///so that the buttons are in the right place
  float padding;//to make room for the x buttons

  String data_type;

  PVector loc;
  PVector centre;

  cableDeleteButton xButton;
  //boolean xIsVisible;

  Port()
  {
  }

  void display() {
    pushStyle();
    noStroke();
    fill(COLOUR);
    rect(loc.x+offset+padding, loc.y, w, h);
    textFont(ui.datafont);
    textAlign(LEFT);
    try {
      fill(0);
      text(label, loc.x+4+offset+padding, loc.y+8);
    }
    catch(NullPointerException npe5)
    {
      //rect(loc.x+offset, loc.y, w, h);
    }
    popStyle();

    if (xButton !=null && xButton.isOn()) {
      xButton.display();
    }
  }

  void update() {
  }

  void connect() {
    connected = true;
  }

  void disconnect() {
    connected =false;
  }

  boolean isConnected()
  {
    return connected;
  }

  void updateDisplay()
  {
  }

  void xOffset(float x_off)
  {
    offset = x_off;
  }


  void clicked() {
    clicked = true;
  }

  void unclick() {
    clicked = false;
  }
}///Port class


///////////////////////////


class PortManager
{
  PVector loc;
  float port_spacing = 12;
}

class DatumPortManager extends PortManager
{
  Datum parent_datum;
  ArrayList<DatumIn> ins;
  ArrayList<DatumOut> outs;

  DatumPortManager(Datum d_)
  {
    this.parent_datum = d_;
    loc = new PVector(parent_datum.loc.x, parent_datum.loc.y);
    ins = new ArrayList<DatumIn>();
    outs = new ArrayList<DatumOut>();
    updateDisplay();
  }

  void unclick()
  {
    for (DatumIn d_i : ins)
    {
      d_i.unclick();
    }

    for (DatumOut d_o : outs)
    {
      d_o.unclick();
    }
  }

  void update() {

    for (DatumIn d_i : ins)
    {
      d_i.update();
    }
    for (DatumOut d_o : outs)
    {
      d_o.update();
    }
  }

  void updateSize() {
    //println("update size is not made for epm"); 

    float in_offset = 0;

    for (DatumIn d_i : ins)
    {
      d_i.xOffset(in_offset);
      in_offset+=d_i.w+port_spacing;
    }

    float out_offset = 0;

    for (DatumOut d_o : outs)
    {
      d_o.xOffset(out_offset);
      out_offset+=d_o.w+port_spacing;
    }

    if ( parent_datum.w < out_offset)
    {
      parent_datum.setWidth(out_offset);
    }

    if ( parent_datum.w < in_offset )
    {
      parent_datum.setWidth(in_offset);
    }
  }

  void updateDisplay()
  {
    loc.set(parent_datum.loc.x, parent_datum.loc.y);

    float in_offset = 0;

    for (DatumIn d_i : ins)
    {
      d_i.updateDisplay();
    }

    float out_offset = 0;

    for (DatumOut d_o : outs)
    {
      d_o.updateDisplay();
    }
  }

  void display()
  {
    for (DatumIn d_i : ins)
    {
      d_i.display();
    }
    for (DatumOut d_o : outs)
    {
      d_o.display();
    }
  }

  void addIn(String new_label, String data_type_)
  {
    ins.add(new DatumIn(new_label, data_type_, this));
  }

  void addOut(String new_label, String data_type_)
  {
    outs.add(new DatumOut(new_label, data_type_, this));
  }
}/////////////DATUM PORT MANAGER///////////////


class DatumPort extends Port
{
  DatumPortManager manager;

  DatumPort(String label_, String data_type_, DatumPortManager dpm_)
  {
    manager = dpm_;
    loc = new PVector(manager.loc.x, manager.loc.y);
    this.label = label_;
    this.data_type = data_type_;
    textFont(ui.datafont);
    try {
      w+=textWidth(label);
    }
    catch( NullPointerException np6)
    {
    }
  }

  boolean mouseOver()
  {
    if (
      mouseX>= manager.parent_datum.parent_book.translateMaster.x + loc.x+offset
      &&
      mouseX<= manager.parent_datum.parent_book.translateMaster.x +loc.x+w+offset
      &&
      mouseY>= manager.parent_datum.parent_book.translateMaster.y +loc.y
      &&
      mouseY<= manager.parent_datum.parent_book.translateMaster.y +loc.y+h)
    {
      return true;
    } else {
      return false;
    }
  }
}

class DatumOut extends DatumPort
{

  ArrayList<Cable> cables;

  DatumOut(String label_, String data_type_, DatumPortManager dpm_) {
    super(label_, data_type_, dpm_);
    cables = new ArrayList<Cable>();
    //manager.addOut(this);
  }

  void updateDisplay() {
    loc.set(manager.loc.x, manager.loc.y+manager.parent_datum.h);


    //println("need to sort update on DatumOut???");
  }

  void update() {

    for (Cable c_ : cables)
    {
      c_.update();
    }
  }

  void addCable(Cable c_)
  {
    cables.add(c_);
    connect();
  }

  void removeCable(Cable c_)
  {
    cables.remove(c_);
    disconnect();
  }
}//////DATUM OUT


class DatumIn extends DatumPort
{

  Cable cable;//just one in!!

  DatumIn(String label_, String data_type_, DatumPortManager dpm_) {
    super(label_, data_type_, dpm_);
    xButton = new cableDeleteButton(this);
    xButton.off();
    //manager.addOut(this);
  }

  void addCable(Cable c_)
  {
    cable = c_;
    connect();
    xButton.on();
  }

  void updateDisplay() {

    loc.set(manager.loc.x, manager.loc.y-h);
        if (xButton!=null && xButton.isOn())
    {
      xButton.updateDisplay();
    }

    //println("Port is updating sucessfully");
  }

}

//////////////////////////////////////////////


class ElementPortManager extends PortManager
{ 
  Element parent_element;
  ArrayList<ElementIn> ins;
  ArrayList<ElementOut> outs;

  ElementPortManager(Element e_)
  {
    this.parent_element = e_;
    loc = new PVector(parent_element.loc.x, parent_element.loc.y);
    ins = new ArrayList<ElementIn>();
    outs = new ArrayList<ElementOut>();
  }

  void unclick()
  {
    for (ElementIn e_i : ins)
    {
      e_i.unclick();
    }

    for (ElementOut e_o : outs)
    {
      e_o.unclick();
    }
  }

  void updateSize() {
    float in_offset = 0;

    for (ElementIn e_i : ins)
    {


      e_i.xOffset(in_offset);

      in_offset+=e_i.w+port_spacing;
    }

    float out_offset = 0;

    for (ElementOut e_o : outs)
    {
      e_o.xOffset(out_offset);
      out_offset+=e_o.w+port_spacing;
    }
  }


  void update()
  {
    ///used for data

    for (ElementIn e_i : ins)
    {
      e_i.update();
    }

    float out_offset = 0;

    for (ElementOut e_o : outs)
    {
      e_o.update();
    }
  }

  void updateDisplay()
  {
    loc.set(parent_element.loc.x, parent_element.loc.y);


    for (ElementIn e_i : ins)
    {
      e_i.updateDisplay();
    }

    for (ElementOut e_o : outs)
    {
      e_o.updateDisplay();
    }
  }

  void display()
  {
    for (ElementIn e_i : ins)
    {
      e_i.display();
    }
    for (ElementOut e_o : outs)
    {
      e_o.display();
    }
  }

  void addIn(String new_label, String data_type_)
  {
    ins.add(new ElementIn(new_label, data_type_, this));
    updateSize();
    updateDisplay();
  }

  void addOut(String new_label, String data_type_)
  {
    outs.add(new ElementOut(new_label, data_type_, this));
    updateSize();
    updateDisplay();
  }
}//ELEMENT PORT MANAGER/////////

class ElementOut extends ElementPort
{
  ArrayList<Cable> cables;//not really that important, included for symmetry.

  ElementOut(String l_, String data_type_, ElementPortManager epm_) {
    label = l_;
    manager = epm_;
    loc = new PVector(manager.loc.x, manager.loc.y+manager.parent_element.hh);
    cables = new ArrayList<Cable>();
    //super(e_);//dunno why the fuck this doesn’t work!!
    //parentElement.addIn(this);
  }
}

class ElementIn extends ElementPort
{

  Cable cable; //just one!

  ElementIn(String label_, String data_type_, ElementPortManager epm_) {
    super(label_, data_type_, epm_);
    xButton = new cableDeleteButton(this);
    xButton.off();
  }

  void addCable(Cable c_)
  {
    cable = c_;
    connect();
    xButton.on();
  }

  void removeCable(Cable c_)
  {
    cable = null;
    disconnect();
    xButton.off();
  }

  void updateDisplay() {
    loc.set(manager.parent_element.xx, manager.parent_element.yy-h);

    if (xButton!=null && xButton.isOn())
    {
      xButton.updateDisplay();
    }
  }
}////////ELEMENT IN///////////////

class ElementPort extends Port
{
  ElementPortManager manager;

  ElementPort() {
  }

  ElementPort(String label_, String data_type_, ElementPortManager epm_)
  {
    manager = epm_;
    this.data_type = data_type_;
    loc = new PVector(manager.parent_element.xx, manager.parent_element.yy);
    this.label = label_;
    textFont(ui.datafont);
    try {
      w+=textWidth(label);
    }
    catch( NullPointerException np6)
    {
    }
    cableDeleteButton x = new cableDeleteButton(this);
  }

  boolean mouseOver()
  {
    if (
      mouseX>= manager.parent_element.parent_page.parent_book.translateMaster.x + loc.x +offset
      &&
      mouseX<= manager.parent_element.parent_page.parent_book.translateMaster.x + loc.x+w +offset
      &&
      mouseY>= manager.parent_element.parent_page.parent_book.translateMaster.y + loc.y
      &&
      mouseY<= manager.parent_element.parent_page.parent_book.translateMaster.y + loc.y+h)
    {
      return true;
    } else {
      return false;
    }
  }

  void update()
  {
  }
}///////ELEMENT PORT///////////////////


class CountEm extends Datum
{


  CountEm(Book b_)
  {
    super(b_);
    type = "CountEm";
    data = new Table();

    addIn("Input", "String");
    addOut("Labels", "String");
    addOut("Counts", "float");
  }

  void updateData() {
    
    ///where does the data come from?
    // 
    IntDict tally = dpm.ins.get(0).cable.datumIn.data.
    getTally(dpm.ins.get(0).
    cable.out_port_number);
    println(tally);
    
    dpm.update();
    
    ///take the data from the input and turn it into a new table
    ///unfinished!!
    
    
  }
}


class Loader extends Datum
{
  String filename;

  Loader(Book b_)
  {
    super(b_);
    type = "Loader";
  }

  void changeSource(String s_)
  {
    this.filename = s_;
  }

  void load(String filename_)
  {
    this.filename = filename_;
    data = loadTable(filename, "header");

    ///look at the data and generate outs

    addOut("ALL", "Table");

    for (int c = 0; c<data.getColumnCount(); c++)
    { 
      if (isNumeric( data.getString(1, c)))
      {
        addOut(data.getColumnTitle(c), "float");
      } else { 
        addOut(data.getColumnTitle(c), "String");
      }
    }
  }

  void display() {
    super.display();
    pushStyle();
    fill(FG);
    noStroke();
    textFont(ui.datafont);
    text(type, loc.x+4, loc.y+24);
    if (filename!=null) {
      text(filename, loc.x+4, loc.y+36);
    }
    popStyle();
  }
}///LOADER



//////DATUM
class Datum
{
  Table data;
  String type;
  //should this be input and output?
  //when the data comes in it should be cloned out
  //so that we are not messing with the original
  //when it comes out it needs to be nulled.
  color COLOUR;
  Book parent_book;
  PVector loc;
  float w, h;
  color BG = #FFFFFF;
  color FG = #222222;
  int id;

  //ui shit
  boolean clicked;
  float xMove, yMove;

  ///Port
  DatumPortManager dpm;


  Datum(Book b_)
  {
    parent_book = b_;
    w = 100; 
    h = 40;
    loc = new PVector(-125, random(200));
    b_.addDatum(this);
    dpm = new DatumPortManager(this);
  }

  Datum() {
    //empty for selected call
  }


  JSONObject saveDatum()
  {

    JSONObject dat = new JSONObject();

    dat.setString("type", type);
    dat.setFloat("x", loc.x);
    dat.setFloat("y", loc.y);
    dat.setFloat("w", w);
    dat.setFloat("h", h);
    dat.setInt("COLOUR", COLOUR);
    dat.setInt("id", id);


    return dat;
  }

  void addOut(String new_out, String data_type_)
  {
    dpm.addOut(new_out, data_type_);
    dpm.updateSize();
  }


  void clearOuts()
  {
    dpm.outs.clear();
    dpm.updateSize();
  }


  void setWidth(float new_width)
  {
    w = new_width;
  }

  //void addOut(String out_name)
  //{
  //  dpm.addOut(new_out);
  //}

  color getColour() {
    return COLOUR;
  }

  void addIn(String new_in, String data_type_) { 
    dpm.addIn(new_in, data_type_);
    dpm.updateSize();
  }

  void updateDisplay() {
    dpm.updateDisplay();
  }

  void updateData() {
    dpm.update();
  }

  void display() {
    pushStyle();
    fill(BG);
    rect(loc.x, loc.y, w, h);
    fill(FG);
    noStroke();
    textFont(ui.datafont);
    text(type, loc.x+4, loc.y+12);
    popStyle();


    dpm.display();
  }

  void setLoc(float x, float y)
  {
    loc.set(x, y);
  }

  void addID(int id_) {
    id = id_;
  }

  void click()
  {
    clicked = true;    
    parent_book.selected_datum = this;
  }

  void unclick()
  {
    clicked = false;
    dpm.unclick();
  }

  boolean mouseOver() {

    if (
      mouseX>= parent_book.translateMaster.x+loc.x
      &&mouseX<= parent_book.translateMaster.x+loc.x+w
      &&mouseY>= parent_book.translateMaster.y+loc.y
      &&mouseY<= parent_book.translateMaster.y+loc.y+h)
    {
      return true;
    } else {
      return false;
    }
  }///mouseover
}
//////DATUM/////////////////////






class ColourDatum extends Datum
{

  float border = 10;

  ColourDatum(Book b_)
  {
    super(b_);
    type = "Colour";
    randomise();
    addOut("colour", "colour");
  }

  void display() {

    super.display();
    noStroke();
    fill(COLOUR);
    rect(loc.x+border, loc.y+border, w-(border*2), h-(border*2));
  }

  void randomise() {

    COLOUR = color(random(255), random(255), random(255));
    updateData();
    updateDisplay();
  }
}////COLOUR
