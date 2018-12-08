void setup(){
  String path = "C:/Users/jeeda/OneDrive/Documents/Processing/sketches/Trilo_analysis/projects/ICS 10024.csv";
  Table tab = loadTable(path, "header");
  Table output = new Table();
  for(int i = 0; i < tab.getRowCount(); i++){
    TableRow in = tab.getRow(i);
    TableRow r = output.addRow();
    r.setString(output.checkColumnIndex("id"),in.getString("id"));
    float scaleDist = dist(in.getFloat("scaleA_xPos"),in.getFloat("scaleA_yPos"),in.getFloat("scaleB_xPos"),in.getFloat("scaleB_yPos"));
    float mmPerPixel = in.getInt("scaleDist")*1.0/scaleDist;
    float size = mmPerPixel * in.getFloat("borderBottomCenter_yPos");
    float scale = in.getFloat("borderBottomCenter_yPos");
    r.setInt(output.checkColumnIndex("axialFurrows"),in.getInt("axisFurrows"));
    r.setInt(output.checkColumnIndex("pleuralFurrows"),in.getInt("pleuralFurrows"));
    r.setInt(output.checkColumnIndex("spines"),in.getInt("spines"));
    r.setFloat(output.checkColumnIndex("length"),size);
    r.setFloat(output.checkColumnIndex("width"),abs(in.getFloat("ALCornerLat_xPos")/scale));
    r.setFloat(output.checkColumnIndex("axialLength"),abs(in.getFloat("axisBottom_yPos")/scale));
    r.setFloat(output.checkColumnIndex("axialWidth"),abs(in.getFloat("axisTopLat_xPos")/scale));
    r.setFloat(output.checkColumnIndex("axialShape"),in.getFloat("axisTopLat_xPos")/in.getFloat("axisBottomLat_xPos"));
    r.setFloat(output.checkColumnIndex("axialEnd"),(in.getFloat("axisBottom_yPos")-in.getFloat("axisBottomLat_yPos"))/(in.getFloat("axisBottomLat_xPos")));
    r.setFloat(output.checkColumnIndex("anteriorBulge"),(in.getFloat("ALCornerTop_yPos")/scale));
    if(in.getString("ip_furrows").equals("Yes")){ r.setInt(output.checkColumnIndex("ip_furrows"),0);}
    if(in.getString("ip_furrows").equals("Partial")){ r.setInt(output.checkColumnIndex("ip_furrows"),1);}
    if(in.getString("ip_furrows").equals("No")){ r.setInt(output.checkColumnIndex("ip_furrows"),2);}
    if(in.getString("ip_furrows").equals("Unclear")){ r.setInt(output.checkColumnIndex("ip_furrows"),1);}
    r.setFloat(output.checkColumnIndex("cornerSlope"),(in.getFloat("ALCornerTop_xPos")-in.getFloat("ALCornerLat_xPos"))/(in.getFloat("ALCornerTop_yPos")-in.getFloat("ALCornerLat_yPos")));
  }
  saveTable(output,"C:/Users/jeeda/Desktop/clustering/ICS10024_data.csv");
}
  