
float sankey_master_yStep = MAX_FLOAT;

class Sankey extends Graph
{
  StringList column_names;
  float column_spacing = 0;
  float column_width = 0;
  float block_spacing = 10;
  ArrayList<Column> columns;
  boolean use_master_yStep;
  boolean displayColumnTitles;

  Sankey(Page p_, int x_, int y_, int w_, int h_)
  {
    super(p_, x_, y_, w_, h_);
    type = "Sankey";
    column_names = new StringList();
    columns = new ArrayList<Column>();
  }

  void useMasterYStep()
  {
    use_master_yStep = true;
  }
  
  void toggleColumnTitles()
  {
    displayColumnTitles = ! displayColumnTitles;
  }



  void addCol(String column_name, String [] blocks_to_display )
  {
    column_names.append(column_name);
    IntDict column_tallys = data.getTally(column_name);
    column_tallys.remove(null);
    //column_tallys.sortValuesReverse();
    Column column = new Column(column_name, column_tallys, block_spacing, blocks_to_display);
    columns.add(column);
  }

  void addCol(String column_name)
  {
    column_names.append(column_name);
    IntDict column_tallys = data.getTally(column_name);
    column_tallys.remove(null);
    //column_tallys.sortValuesReverse();
    Column column = new Column(column_name, column_tallys, block_spacing);
    columns.add(column);
  }


  void drawElement(PGraphics g)
  {
    if (data!=null) 
    {
      g.beginDraw();
      g.pushMatrix();
      g.translate(xx, yy);
      

      if (!isNullOrBlank(title) )
      {
        g.fill(0);
        //g.textFont(titleFont);
        g.textAlign(LEFT, TOP);
        g.text(title, 0, 0);
      }


      yStep = 0;

      float find_yStep = 0 ;//////BROKEN!!

      for (int c = 0; c<columns.size(); c++)
      {
        Column column = columns.get(c);

        float value = column.total_value;
        //println(value);

        if (value>find_yStep)
        {
          find_yStep=value;
        }
      }

      yStep = .25;

      //if ( use_master_yStep && yStep<sankey_master_yStep )
      //{
      //  sankey_master_yStep = yStep;
      //}

      ////ins and outs for curves!/////
      for (int c = 0; c<columns.size()-1; c++)
      {
        Column left_column =  columns.get(c);
        Column right_column =  columns.get(c+1);

        //if (c==0) {
        //  println(left_column.name +" to " + right_column.name);
        //}

        left_column.clearSubBlocks();
        right_column.clearSubBlocks();

        //if (c==0) {
        //  for (int k = 0; k<right_column.blocks.size(); k++ )
        //  {
        //    Block block = right_column.blocks.get(k);
        //    println(block.name +" has1 " + block.ins.size() + " ins");
        //  }
        //}

        for (int r = 0; r<data.getRowCount(); r++)
        {
          String out = data.getString(r, left_column.name);
          String in = data.getString(r, right_column.name);


          if ( ! isNullOrBlank(out) && ! isNullOrBlank(in) )
          {

            if (left_column.containsBlock(out) && right_column.containsBlock(in)  )
            {
              Block left_block = left_column.getBlock(out);
              Block right_block = right_column.getBlock(in);

              ///add subs
              //if (c==1) {
              right_block.addIn(out);
              left_block.addOut(in);
              //}
            }
          }
        }
        //if (c==0) {
        //  for (int k = 0; k<right_column.blocks.size(); k++ )
        //  {
        //    Block block = right_column.blocks.get(k);
        //    println(block.name +" has2 " + block.ins.size() + " ins");
        //  }
        //}


        left_column.orderOuts(right_column);
        right_column.orderIns(left_column);
      }
      //}

      ///set up subs
      xStep = ww/ columns.size();


      //for (int c = 0; c<columns.size(); c++)
      //{
      //  Column test_col = columns.get(c);

      //  for (int b = 0; b<test_col.blocks.size(); b++ )
      //  {
      //    Block test_block = test_col.blocks.get(b);

      //    if (c==1) {
      //      println(test_block.name +" has3 " + test_block.ins.size() + " ins");
      //    }
      //  }
      //}


      for (int c = 0; c<columns.size(); c++)
      {
        Column column =  columns.get(c);
        float column_x = xStep*(c) + ((xStep-column_width)/2);
        
        if(displayColumnTitles)
        {
        g.fill(0);
        g.textAlign(CENTER, BOTTOM);
        g.textFont(big_label_font);
        g.text(column.name, column_x+(column_width/2), 0);
        }


        float block_yOff = 0;
        for (int b = 0; b<column.blocks.size(); b++ )
        {
          Block block =  column.blocks.get(b);


          if (c==1) {
            //println(block.name +" has " + block.ins.size() + " ins");
          }

          float block_height = (use_master_yStep)  ?   block.value * sankey_master_yStep : block.value*yStep;

          block.addLoc(column_x, block_yOff);

          g.fill(0, 0, 200, 50);
          g.noStroke();
          g.fill(0);
          g.textAlign(CENTER, CENTER);
          g.textFont(big_label_font);
          g.text(block.name, column_x+(column_width/2), block_yOff + (block_height/2) );


          float sb_in_yOff = block_yOff;


          for (int j = 0; j<block.ins.size(); j++)
          {

            SubBlock sb2 =  block.ins.get(j);
            float sb_height = (use_master_yStep)  ?   sb2.value*sankey_master_yStep : sb2.value*yStep;
            sb2.addXYV(column_x, sb_in_yOff + (sb_height/2));
            sb_in_yOff+=sb_height;
            //g.fill(200, 0, 200);
            //g.noStroke();
            //g.ellipse(sb2.x-5, sb2.y, 3, 3);
          }


          float sb_out_yOff = block_yOff;
          //float sb_out_yOff = 0;
          for (int i = 0; i<block.outs.size(); i++)
          {
            SubBlock sb1 =  block.outs.get(i);
            float sb_height = (use_master_yStep)  ?   sb1.value*sankey_master_yStep : sb1.value*yStep;
            sb1.addXYV(column_x+column_width, sb_out_yOff + (sb_height/2) );
            sb_out_yOff+=sb_height;
            //g.fill(0, 200, 200);
            //g.noStroke();
            //g.ellipse(sb1.x+5, sb1.y, 3, 3);
          }
          block_yOff+=block_height;
          block_yOff+=block_spacing;

          //}///blocks_to_display

          Collections.sort(block.ins, new SubBlockComp());
        }
      }//add sub-blocks

      //for (int c = 0; c<columns.size(); c++)
      //{
      //  Column column =  columns.get(c);

      //  //println(column.name);

      //  if (column.blocks.size()<1)
      //  {
      //    println(column.name +" is empty");
      //  }
      //  for (int b = 0; b<column.blocks.size(); b++)
      //  {
      //    Block block =  column.blocks.get(b);

      //    if (block.ins.size()==0 && c==1)
      //    {
      //      println("p"+this.getPageNumber()+", "+ title+":"+column.name +" c="+c+", Block "+block.name+" ins are empty at check");
      //    }

      //    //if (block.outs.size()==0 && c!=columns.size()-1)
      //    //{
      //    //  println("p"+this.getPageNumber()+", "+ title+":"+column.name +", Block "+block.name+" outs are empty");
      //    //}
      //  }
      //}


      for (int c = 1; c<columns.size(); c++)
      {
        Column left_column =  columns.get(c-1);
        Column right_column =  columns.get(c);

        for (int b1 = 0; b1<left_column.blocks.size(); b1++ )
        {
          Block left_block =  left_column.blocks.get(b1);
          for (int lbo = 0; lbo<left_block.outs.size(); lbo++)
          {
            SubBlock left_subBlock = left_block.outs.get(lbo);
            for (int b2 = 0; b2<right_column.blocks.size(); b2++ )
            {
              Block right_block =  right_column.blocks.get(b2);
              for (int rbi = 0; rbi<right_block.ins.size(); rbi++)
              {
                SubBlock right_subBlock = right_block.ins.get(rbi);

                ///check the left column blocks for outs that match the right column ins
                if (left_subBlock.name.equals(right_block.name) && right_subBlock.name.equals(left_block.name) )
                {
                  
                  
                  color CURVE = (!ColourIsSet) ? makeAColour (b1, left_column.blocks.size()) : COLOUR;
                  
                  g.stroke(CURVE);
                  g.strokeCap(SQUARE); 
                  g.noFill();
                  float thickness = (use_master_yStep)  ?   right_subBlock.value*sankey_master_yStep : right_subBlock.value*yStep;

                  g.strokeWeight(thickness);
                  g.bezier(left_subBlock.x, left_subBlock.y, 
                    left_subBlock.x+(xStep/3), left_subBlock.y, 
                    right_subBlock.x-(xStep/3), right_subBlock.y, 
                    right_subBlock.x, right_subBlock.y);
                }
              }
            }
          }
        }
      }


      ///////////////////////////goes at bottom///////////////////////////
      //} else {
      //  println("sankey needs at least 2 columns");
      //}
      g.popMatrix();
      g.endDraw();
    }
  }///draw
}///Sankey






class Column
{
  String name;
  float total_value;
  ArrayList<Block> blocks;
  StringList blocks_to_display;
  boolean has_display_blocks = false;
  
  
  

  Column(String column_name_, IntDict column_tallys, float spacing, String [] blocks_to_generate )
  {
    this.name = column_name_;
    blocks = new ArrayList<Block>();
    blocks_to_display = new StringList(blocks_to_generate);
    total_value = 0;

    for (int i = 0; i< blocks_to_display.size(); i++)
    {
      String block_name = blocks_to_display.get(i);

      if (column_tallys.hasKey(block_name) )
      {

        float block_value = column_tallys.get(block_name);
        total_value+=block_value;
        //total_value+=spacing;
        Block block = new Block (block_name, block_value);
        //if (block_value>excludeThreshold)
        //{
          blocks.add(block);
        //}
      }
    }
  }
  
  Column(String column_name, Table data)
  {
    
    
  }

  Column(String column_name_, IntDict column_tallys, float spacing)
  {
    this.name = column_name_;
    blocks = new ArrayList<Block>();
    blocks_to_display = new StringList();
    total_value = 0;
    for (int i = 0; i< column_tallys.size(); i++)
    {
      String block_name = column_tallys.key(i);
      float block_value = column_tallys.get(block_name);
      total_value+=block_value;
      //total_value+=spacing;
      Block block = new Block (block_name, block_value);
      //if (block_value>excludeThreshold)
      //{
        blocks.add(block);
      //}//
    }
  }

  void orderOuts(Column target)
  {
    StringList orderOut = new StringList();

    for (Block block : target.blocks)
    {
      orderOut.append(block.name);
    }

    for (Block block : blocks)
    {

      ArrayList<SubBlock> temp_outs =  new ArrayList<SubBlock>();

      for (String s : orderOut)
      {
        SubBlock sb = block.getOut(s);

        if (sb!=null)
        {
          temp_outs.add(sb);
        }
      }
      block.outs = temp_outs;
    }
  }

  void orderIns(Column target)
  {
    StringList orderIn = new StringList();

    for (Block block : target.blocks)
    {
      orderIn.append(block.name);
    }

    for (Block block : blocks)
    {

      ArrayList<SubBlock> temp_ins =  new ArrayList<SubBlock>();

      for (String s : orderIn)
      {
        SubBlock sb = block.getIn(s);

        if (sb!=null)
        {
          temp_ins.add(sb);
        }
      }
      block.ins = temp_ins;
    }
  }

  void clearSubBlocks()
  {
    for (Block block : blocks)
    {
      block.outs.clear();
      block.ins.clear();

      block.outs = new ArrayList<SubBlock>();
      block.ins = new ArrayList<SubBlock>();
    }
  }

  boolean containsBlock(String s)
  {
    for (Block b : blocks)
    {
      if (s.equals(b.name))
      {
        return true;
      }
    }
    return false;
  }

  Block getBlock(String s)
  {
    for (Block b : blocks)
    {
      if (s.equals(b.name))
      {
        return b;
      }
    }
    println(s+": no such block in "+name);
    return null;
  }
}

class Block
{
  String name;
  float value;
  ArrayList<SubBlock>ins;
  ArrayList<SubBlock>outs;
  float x, y;



  Block(String name_, float value_)
  {
    this.name = name_;
    this.value = value_;

    ins = new ArrayList<SubBlock>();
    outs = new ArrayList<SubBlock>();
  }

  void addLoc(float x_, float y_)
  {
    this.x = x_;
    this.y = y_;
  }

  SubBlock getOut(String s)
  {
    for (SubBlock sb : outs)
    {
      if (sb.name.equals(s))
      {
        return sb;
      }
    }
    return null;
  }

  SubBlock getIn(String s)
  {
    for (SubBlock sb : ins)
    {
      if (sb.name.equals(s))
      {
        return sb;
      }
    }
    return null;
  }


  void addIn(String s)
  {
    boolean contains = false;
    for (SubBlock sb : ins)
    {
      if (sb.name.equals(s))
      {
        sb.inc();
        contains = true;
      }
    }

    if (!contains)
    {
      ins.add(new SubBlock(s));
    }
  }

  void addOut(String s)
  {
    boolean contains = false;
    for (SubBlock sb : outs)
    {
      if (sb.name.equals(s))
      {
        sb.inc();
        contains = true;
      }
    }

    if (!contains)
    {
      outs.add(new SubBlock(s));
    }
  }
}

class SubBlock
{
  String name;
  float value;
  float x, y;


  SubBlock(String s)
  {
    this.name = s;
    value = 1;
  }

  void addXYV(float x_, float y_)
  {
    this.x = x_;
    this.y = y_;
  }

  void inc() 
  {
    value++;
  }
}


class SubBlockComp implements Comparator <SubBlock> {

  int compare(SubBlock sb1, SubBlock sb2)
  {

    if (sb1.value == sb2.value)
    {
      return 0;
    } 

    if (sb1.value > sb2.value)
    {
      return -1;
    }

    if (sb1.value < sb2.value)
    {
      return 1;
    } 

    return int(sb1.value - sb2.value);
  }
}
