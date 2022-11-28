
int findRowIndexInMasterData(Table table, String input, String column_name)
{
  return table.findRowIndex(input, column_name);
}


color getUniqueColourFromTable(Table table, color[] colours, String input, String column_name)
{
  ///run generateHuesForEachEntry to get the colours input
  int r = findRowIndexInMasterData(table,input,column_name);
  
  return colours[r];
}


color[] generateHuesForEachEntry(Table input)
{
  int number_of_entries = input.getRowCount();

  color [] output = new color[number_of_entries];
  colorMode(HSB, number_of_entries, 100, 100);

  for (int i = 0; i<number_of_entries; i++)
  {
    output[i] = color(i, 80, 50);
  }

  colorMode(RGB, 255);

  return output;
}




color getPartyColour(String party)
{
  if ("republican".equalsIgnoreCase(party))
  {
    return   color(211, 10, 0);
  }

  if ("Democrats".equalsIgnoreCase(party))
  {
    return color(0, 10, 180);
  }

  if ("labour".equalsIgnoreCase(party))
  {
    return color(216, 27, 24);
  }

  if ("SNP".equalsIgnoreCase(party))
  {
    return color(254, 249, 135);
  }

  if ("Liberal Democrat".equalsIgnoreCase(party))
  {
    return color (#FAA61A);
  }

  if ("Tory".equalsIgnoreCase(party))
  {
    return color (#3333CC);
  }

  if ("LREM".equalsIgnoreCase(party))
  {
    return color (#FFD600);
  }

  if ("Socialist Party".equalsIgnoreCase(party))
  {
    return color (#D4D4D4);
  }

  if ("Business Community".equalsIgnoreCase(party))
  {
    return color (#73C420);
  }

  if ("agir".equalsIgnoreCase(party))
  {
    return color (#43519E);
  }

  if ("New Anticapitalist Party".equalsIgnoreCase(party))
  {
    return color (#E22122);
  }

  if ("CDU".equalsIgnoreCase(party))
  {
    return color (#FF9900);
  }

  if ("SPD".equalsIgnoreCase(party))
  {
    return color (#DF0114);
  }

  if ("SPD (left)".equalsIgnoreCase(party))
  {
    return color (#DF0114);
  }

  if ("SPD (right)".equalsIgnoreCase(party))
  {
    return color (#DF0114);
  }

  if ("The Greens Party".equalsIgnoreCase(party))
  {
    return color (#64A12D);
  }

  return color(100);
}


/////////////FUNCTIONS//////////////////////


//FloatDict binDataValues(Table t, String columnName, float binSize, float limit)
//{
//  FloatDict bins = new FloatDict();

//  int binSteps = int(limit/binSize);

//  for (int i = 0; i<binSteps; i++)
//  {
//    bins.set(i*binSize+"", 0);
//  }

//  return bins;
//}


PVector meanVector(ArrayList<PVector> input)
{
  float x = 0, y = 0, z=0;

  for (PVector pv : input)
  {
    x+=pv.x;
    y+=pv.y;
    z+=pv.z;
  }

  x/=input.size();
  y/=input.size();
  z/=input.size();

  return new PVector(x, y, z);
}


public int GCD(int a, int b) {
  ///gross common denominator
  if (b==0) return a;
  return GCD(b, a%b);
}



IntDict removeLowValues(IntDict id, int threshold)
{
  for ( String s : id.keys() )
  {
    if ( id.get(s)<threshold )
    {
      id.remove(s);
    }
  }

  return id;
}


IntList  binDataValues(Table t, String columnName, float binSize, float limit)
{
  int binSteps = int(limit/binSize);
  IntList il = new IntList(binSteps);
  FloatList fl = t.getFloatList(columnName);
  //print(il.size());

  for (int i = 0; i<binSteps; i++)
  {
    il.append(0);
  }

  if (fl.size()>0) {
    for (float f : fl)
    {
      int ref = int ( ( f - (f%binSize) ) / binSize );
      if (ref<il.size())
      {
        int v = il.get(ref)+1;
        il.set(ref, v);
      }

      //il.get(ref);
    }
    return il;
  }

  return null;
}



color makeAColour(float position, int total)
{
  float granularity = 100;

  colorMode(HSB, granularity);

  float reference = (position/(total+1))*granularity;
  ///
  //float reference = granularity*sin(position*(7/3));
  //println(reference);
  color c = color(reference, granularity, granularity*.6);

  colorMode(RGB, 255); 

  return c;
}

//float [] binDataValues(Table t, String columnName, float binSize, float limit)
//{
//  int binSteps = int(limit/binSize);
//  float [] values = new float[binSteps];


//  for (int r = 0; r<t.getRowCount(); r++)
//  {
//    float value = t.getFloat(r, "What is your total expected cash remuneration for the current year?");

//    int ref = int(value/binSize);
//    //println(ref+" of "+binSteps);

//    if (ref<binSteps)
//    {
//      values[ref]++;
//    }

//    ///go through the rows and see
//  }

//  return values;
//}

String [] removeEmpty(String[] input)
{
  StringList output = new StringList();

  for (int i = 0; i<input.length; i++)
  {
    if (isString(input[i]))
    {
      output.append(input[i]);
    }
  }
  return output.values();
}

private static boolean isNullOrBlank(String s)
{
  return (s==null || s.trim().equals(""));
}


private static boolean isString(String s)
{
  return !(s==null || s.trim().equals(""));
}

float getCircleDiameterFromValue(float v)
{
  return  2*sqrt(v/PI);
}

///BELONGS AS A FILTER DATUM  (FUNNEL)
void transpose (String[] args) {
  double[][] m = {{1, 1, 1, 1}, 
    {2, 4, 8, 16}, 
    {3, 9, 27, 81}, 
    {4, 16, 64, 256}, 
    {5, 25, 125, 625}};
  double[][] ans = new double[m[0].length][m.length];
  for (int rows = 0; rows < m.length; rows++) {
    for (int cols = 0; cols < m[0].length; cols++) {
      ans[cols][rows] = m[rows][cols];
    }
  }
  for (double[] i : ans) {//2D arrays are arrays of arrays
    //System.out.println(Arrays.toString(i));
  }
}

float percentageChange(float v1, float v2)
{
  return (v2-v1) / v1;
}

float findLabelXSize( StringList labels, PFont font)
{
  textFont(font);

  float size = MIN_FLOAT;
  for (String s : labels)
  {
    if (textWidth(s)>size)
    {
      size =  textWidth(s);
    }
  }

  return size;
}



void removeCable(Cable c_)
{
  c_.delete();

  book.currentPage.removeCable(c_);

  //println("number of cables: "+book.currentPage.cables.size());
}


boolean isNumeric(String inputData) {
  return inputData.matches("[-+]?\\d+(\\.\\d+)?");
}

float moneyBar(float value)
{
  return (value/2000)/mmpx;
}

float average(float a, float b) {
  return (a+b)*.5;
}

float getAverage(Table t, String column_name)
{
  FloatList list = t.getFloatList(column_name);

  FloatList list_copy = new FloatList();

  for (int i = 0; i<list.size(); i++)
  {
    float value = list.get(i);
    if (isNumeric(value+""))
    {
      list_copy.append(value);
    }
  }



  return list_copy.sum()/list_copy.size();
}


Table cloneTable(Table t1)
{
  Table t2 = new Table();
  String [] columnTitles = t1.getColumnTitles();
  //println(columnTitles);
  for (int c = 0; c<t1.getColumnCount(); c++) {

    //println(t1.getString(0,c));

    for (int r = 0; r<t1.getRowCount(); r++)
    {
      t2.setString(r, c, t1.getString(r, c));
    }
  }
  t2.setColumnTitles(columnTitles);
  //t2 = setColumnTypes(t2);
  return t2;
}

float getTriangleDiameter(float f)
{

  return sqrt(4 * f /(3 * sqrt (3) )) ;
}

float getMedian(Table t, String columnName)
{
  FloatList list = t.getFloatList(columnName);
  IntList to_remove = new IntList();
  for (int i = 0; i< list.size(); i++)
  {
    if (!isNumeric(list.get(i)+""))
    {
      to_remove.append(i);
    }
  }

  to_remove.reverse();

  for (int k = 0; k<to_remove.size(); k++)
  {
    int destroy = to_remove.get(k);
    list.remove(destroy);
  }

  if (list.size()>0)
  {
    list.sort();

    int ref;
    float v;

    if (list.size()%2==0)
    {
      //even
      ref = int(list.size()/2);
      v = average(list.get(ref), list.get(ref-1));
    } else
    {
      ref = int(list.size()/2);
      v = list.get(ref);
    }


    if (Float.isNaN(v))
    {
      //println("ERROR: getMedian returns NaN from "+columnName);
      return -1;
    } else {

      return v;
    }
  } else {
    //println("ERROR: getMedian has no values in "+columnName);
    return -1;
  }
}

float getMedian(FloatList input)
{
  FloatList list = input.copy();

  if (list.size()>0)
  {
    list.sort();

    int ref;
    float v;

    if (list.size()%2==0)
    {
      //even
      ref = int(list.size()/2);
      v = average(list.get(ref), list.get(ref-1));
    } else
    {
      ref = int(list.size()/2);
      v = list.get(ref);
    }


    if (Float.isNaN(v))
    {
      //println("ERROR: getMedian returns NaN");
      return -1;
    } else {

      return v;
    }
  } else {
    //println("ERROR: getMedian has no values");
    return -1;
  }
}



PVector normaliseVector(PVector p) {
  p.x = round(p.x);
  p.y = round(p.y);
  p.z = round(p.z);
  return p;
}

/////////////FUNCTIONS//////////////////////
