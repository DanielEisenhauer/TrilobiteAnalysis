Table tab;
project curProj;
class project { //I'll do more with projects later. Right now I'm not really using them, and only one should ever exist: ICS-10024
  String name;
  String path;

  project(String n) {
    //    String saveFile = "";
    name = n;
    String[] savedProjects = null;
    if (loadStrings("projects.txt") != null) {
      savedProjects = loadStrings("projects.txt");
    }
    path = "projects/" + name + ".csv";
    String[] toSave = {name};
    if (savedProjects != null) {
      savedProjects = concat(savedProjects, toSave);
      saveStrings("projects.txt", savedProjects);
    } else {
      saveStrings("projects.txt", toSave);
    }

    tab = new Table();
    tab.addColumn("id", Table.STRING);
    tab.addColumn("filepath", Table.STRING);
    tab.addColumn("template", Table.STRING);
    tab.addColumn("imgX", Table.INT);
    tab.addColumn("imgY", Table.INT);
    tab.addColumn("zoom", Table.FLOAT);
    tab.addColumn("scaleA_xPos", Table.FLOAT);
    tab.addColumn("scaleA_yPos", Table.FLOAT);
    tab.addColumn("scaleB_xPos", Table.FLOAT);
    tab.addColumn("scaleB_yPos", Table.FLOAT);
    tab.addColumn("scaleDist", Table.FLOAT);
    tab.addColumn("scaleUnits", Table.STRING);
    saveTable(tab, path);
  }
}

void loadProject(String proj) {    //Three guesses what this does
  String path = "projects/" + proj + ".csv";
  tab = loadTable(path, "header");
}

void saveTemplate() {    //Saves the picture
  if (tab != null && curImg != null) {
 //   tab.trim();
    TableRow r;
  //  int a = tab.findRowIndex(curImgPath, "filepath");
  //  println(a);
   // r = tab.getRow(a);
     r = tab.findRow(curImgPath,"filepath");
    if (r == null) {
      r = tab.addRow();
    }else{  //I need to make it blank the row if it's saving over prior data. Otherwise, if it's saving a lower number of furrows or spines, the old data stays in the cells.
  //    tab.removeRow(a);    //It isn't misleading given that I'm not doing anything with that data ATM, but should change in the future
  //    r = tab.addRow();
    }
    r.setFloat(tab.checkColumnIndex("rotation"), cumulativeRotation);
    r.setFloat(tab.checkColumnIndex("translate_x"), translateX);
    r.setFloat(tab.checkColumnIndex("translate_y"), translateY);
    r.setString("id", tem.textBoxes.get(4).getText());
    r.setFloat("imgX", imgStartX);
    r.setFloat("imgY", imgStartY);
    r.setString("filepath", curImgPath);
    r.setString("template", tem.name);
    r.setFloat("scaleA_xPos", scaleA.xPos);  //Save all the things
    r.setFloat("scaleA_yPos", scaleA.yPos);
    r.setFloat("scaleB_xPos", scaleB.xPos);
    r.setFloat("scaleB_yPos", scaleB.yPos);
    r.setString("scaleUnits", scaleUnits);
    r.setFloat("zoom", zoomLevel);
    r.setFloat("scaleDist", float(tem.textBoxes.get(2).getText()));
/*    for (int i = 0; i < tem.countNames.size(); i++) {
      r.setInt(tab.checkColumnIndex(tem.countNames.get(i)), tem.countVals.get(i));
    }*/
    r.setFloat(tab.checkColumnIndex("axisFurrows"),nAxisFurrows);
    r.setFloat(tab.checkColumnIndex("pleuralFurrows"),nPleuralFurrows);
    r.setFloat(tab.checkColumnIndex("spines"),nSpines);
    r.setString(tab.checkColumnIndex("dispL"),str(displayLeft));
    r.setString(tab.checkColumnIndex("dispR"),str(displayRight));
    
    for (int i = 0; i < tem.qualNames.size(); i++) {
      r.setString(tab.checkColumnIndex(tem.qualNames.get(i)), tem.qualVals.get(i));
    }
    for (wayPoint wp : tem.wayPoints) {
      r.setFloat(tab.checkColumnIndex(wp.name + "_xPos"), wp.xPos);
      r.setFloat(tab.checkColumnIndex(wp.name + "_yPos"), wp.yPos);  //SAVE ALL THE THINGS
      r.setString(tab.checkColumnIndex(wp.name + "_certain"),str(wp.certain));
      if(wp.arcPinned){
        r.setFloat(tab.checkColumnIndex(wp.name + "_pin"),wp.arcPin);
      }
    }
    String path = "projects/" + curProjName + ".csv";
    saveTable(tab, path);
    tab = loadTable(path, "header");
    println("Saved: " + tem.textBoxes.get(4).getText());
    saveFill = 20; //To make the box change color, to provide confirmation that something happened
  }
}