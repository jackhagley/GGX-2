///functions that return tables


///for a Function, find the median of each of the sectors, then display them in ranked order
void invertDataValues(Table input, String col_name)
{
  //String [] columnTitles = input.getColumnTitles();
  //Table output = new Table();

  input.setColumnType(col_name, Table.FLOAT);
  
  for (int r = 0; r<input.getRowCount(); r++)
  {
    float value = input.getFloat(r,col_name);
    
    input.setFloat(r,col_name,-value);
    
  }
  

  //return output;
}

Table sortByTwoColumns(Table input, String a, String b)
{

  ////take off the column titles
  String [] columnTitles = input.getColumnTitles();
  Table output = new Table();

  input.setColumnType(a, Table.FLOAT); /// otherwise minus numbers aren’t sorted correctly
  input.setColumnType(b, Table.FLOAT); /// otherwise minus numbers aren’t sorted correctly

  input.sortReverse(a); /// sort by a first

  ArrayList<Table>  splitdata = new ArrayList<Table>();

  ///split up the data by column a
  float current_value = input.getFloat(0, a);
  Table current_table = new Table();
  current_table.setColumnTitles(columnTitles);
  output.setColumnTitles(columnTitles);
  splitdata.add(current_table);

  ////split the data
  for (int r = 0; r<input.getRowCount(); r++)
  {
    float test_value = input.getFloat(r, a);
    ////pull out the row
    TableRow row = input.getRow(r);

    ////if it is the same, 
    if (test_value == current_value)
    {
      /////put it in the current Table
      splitdata.get(splitdata.size()-1).addRow(row);

      //println(test_value+" //// size = "+splitdata.get(splitdata.size()-1).getRowCount());
    } else /// if it is not the same
    {
      //println("making a new table");
      ////make a new table
      Table new_table = new Table();
      new_table.setColumnTitles(columnTitles);
      ///add the table to the end of the list
      splitdata.add(new_table);
      ///add this to the new table
      splitdata.get(splitdata.size()-1).addRow(row);
      ///update the current value
      current_value = test_value;
    }
  }

  ////sort the data by b
  for (int i = 0; i<splitdata.size(); i++)
  {
    Table split_table = splitdata.get(i);   
    split_table.sortReverse(b);
  }

  ////rejoin the data
  for (int i = 0; i<splitdata.size(); i++)
  {
    Table sorted_table = splitdata.get(i);
    for (int r = 0; r<sorted_table.getRowCount(); r++)
    {
      TableRow row = sorted_table.getRow(r);
      output.addRow(row);
    }
  }
  //output.print();
  return output;
}




float returnMaxFloat(Table data, String column_name)
{
  return data.getFloatList(column_name).max();
}

float returnMinFloat(Table data, String column_name)
{
  return data.getFloatList(column_name).min();
}

Table AddATotalColumn(Table data, String [] column_names, String new_col_name)
{
  data.addColumn(new_col_name);

  for (int r = 0; r<data.getRowCount(); r++)
  {
    float total_value = 0f;

    for (int c = 0; c< column_names.length; c++)
    {
      float value = data.getFloat(r, column_names[c]);
      total_value+=value;
    }

    data.setFloat(r, new_col_name, total_value);
  }

  return data;
}


Table ReplaceNumberWithCodeFromIndex(Table data, String data_col_name, Table index, String index_col_code, String index_col_name, String new_col_name)
{
  ///uses an index table
  ///looks up the value from the data in the index table
  ///adds a new column, puts in the value there
  data.addColumn(new_col_name);
  for (int r = 0; r<data.getRowCount(); r++)
  {
    int code_value = data.getInt(r, data_col_name);
    TableRow code = index.findRow(code_value+"", index_col_code);
    if (code==null)
    {
      println("code_value="+code_value);
    } else
    {
      String code_name = code.getString(index_col_name);
      data.setString(r, new_col_name, code_name);
    }
  }
  return data;
}



Table getBiggestChange(Table data, String values_column1_name, String values_column2_name, String keys_column_name, int n)
{
  String [] columnTitles = data.getColumnTitles(); 
  //returns the top n in a column
  Table t = new Table(); 

  FloatDict values1 = data.getFloatDict(keys_column_name, values_column1_name); 
  FloatDict values2 = data.getFloatDict(keys_column_name, values_column2_name); 

  FloatDict changes = new FloatDict(); 

  for (int r = 0; r<n-1; r++)
  {
    String rowKey1 = values1.key(r); 
    String rowKey2 = values2.key(r); 

    if (rowKey1.equals(rowKey2))
    {

      float v1 = data.getFloat(r, values_column1_name); 
      float v2 = data.getFloat(r, values_column2_name); 

      float change = percentageChange(v1, v2); 

      changes.add(rowKey1, change);
    }
  }

  changes.sortValuesReverse(); 
  changes.remove(null); 

  for (int i = 0; i<n-1; i++)
  {
    String rowKey = changes.key(i); 
    TableRow tr = data.findRow(rowKey, keys_column_name); 
    t.addRow(tr);
  }


  t.setColumnTitles(columnTitles); 
  return t;
}


Table getTop(Table data, String values_column_name, String keys_column_name, int n)
{ 
  String [] columnTitles = data.getColumnTitles(); 
  //returns the top n in a column
  Table t = new Table(); 
  ///will only work if there is one unique column to id the TableRow!!
  FloatDict values = data.getFloatDict(keys_column_name, values_column_name); 

  values.remove(null); 
  values.sortValuesReverse(); 

  for (int r = 0; r<n-1; r++)
  {
    String rowKey = values.key(r); 
    TableRow tr = data.findRow(rowKey, keys_column_name); 
    t.addRow(tr);
  }

  t.setColumnTitles(columnTitles); 
  return t;
}

//

Table getDataReadyForBar(Table data, String x, String y)
{
  Table t = new Table(); 

  t.addColumn("x"); 
  t.addColumn("y"); 


  return t;
}


Table removeEmptyRows(Table data, String column_name)
{
  IntList rows_to_remove = new IntList(); 
  Table dataCopy = cloneTable(data); 
  for (int r = 0; r<dataCopy.getRowCount(); r++)
  {
    String value_string = dataCopy.getString(r, column_name); 
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

  return dataCopy;
}



Table setColumnTypes(Table t)
{

  for (int c = 0; c<t.getColumnCount(); c++)
  {
    int numericCount = 0; 
    int stringCount = 0; 

    for (int r = 1; r<t.getRowCount(); r++)
    {
      if ( isNumeric(  t.getString(r, c) ) )
      {
        numericCount ++;
      } else
      {        
        stringCount++;
      }
    }

    if (stringCount>numericCount)
    {
      t.setColumnType(c, Table.STRING);
    } else
    {
      t.setColumnType(c, Table.FLOAT);
    }
  }


  return t;
}




Table sift(Table data, String colName, String what)
{

  String [] columnTitles = data.getColumnTitles(); 

  try
  {
    data.getColumnIndex(colName);
  }
  catch (IllegalArgumentException e)
  {
    println("Error in Table Sift: Table contains no column named "+colName); 
    return null;
  }

  Table t = new Table(data.findRows(what, colName) ); 

  t.setColumnTitles(columnTitles); 

  //println(columnTitles);

  return t;
}


Table siftByRegexp(Table data, String colName, String regexp)
{

  String [] columnTitles = data.getColumnTitles(); 

  try
  {
    data.getColumnIndex(colName);
  }
  catch (IllegalArgumentException e)
  {
    println("Error in Table Sift: Table contains no column named "+colName); 
    return null;
  }

  Table t = new Table(data.matchRows(regexp, colName) ); 

  t.setColumnTitles(columnTitles); 

  //println(columnTitles);

  return t;
}


Table exclude(Table data, String colName, String what)
{
  Table t = new Table(); 

  String [] columnTitles = data.getColumnTitles(); 

  try
  {
    data.getColumnIndex(colName);
  }
  catch (IllegalArgumentException e)
  {
    println("Error in Table Sift: Table contains no column named "+colName); 
    return null;
  }

  for (int r = 0; r<data.getRowCount(); r++)
  {
    String s = data.getString(r, colName); 
    if (!what.equals(s))
    {
      t.addRow(data.getRow(r));
    }
  }


  t.setColumnTitles(columnTitles); 

  //println(columnTitles);

  return t; 

  //return new Table(data.findRows(what, colName) );
}

Table medianByCategory(Table data, String valueCol, String catCol)
{
  Table t = new Table(); 
  int valColRef = 0; 
  int catColRef = 0; 

  try
  {
    valColRef = data.getColumnIndex(valueCol);
  }
  catch (IllegalArgumentException e)
  {
    println("Error in median calculation: Table contains no column named "+valueCol); 
    return null;
  }

  try
  {
    catColRef = data.getColumnIndex(catCol);
  }
  catch (IllegalArgumentException e)
  {
    println("Error in median calculation: Table contains no column named "+catCol); 
    return null;
  }

  //println(data.getColumnType(valColRef));
  //  println(data.getColumnType(catColRef));
  //saveTable(t,"filter.csv");

  String [] categoryNames = data.getUnique(catCol); 
  //println(categoryNames);

  ///for each of the categories, collect the values and return the median
  t.addColumn("Category"); 
  t.addColumn("Median"); 

  for (String s : categoryNames)
  {


    FloatList values = new FloatList(); 

    for (TableRow row : data.findRows(s, catCol) )
    {
      values.append( row.getFloat(valueCol) );
    }
    //println(s +"   "+ values);

    TableRow newRow = t.addRow(); 
    newRow.setString("Category", s); 
    newRow.setFloat("Median", getMedian(values));
  }


  return t;
}
