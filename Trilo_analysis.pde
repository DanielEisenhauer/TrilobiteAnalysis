ArrayList<wayPoint> wayPoints = new ArrayList<wayPoint>();
int nAxisFurrows = 8, nAxisFurrowsOld = nAxisFurrows;
int nPleuralFurrows = 9, nPleuralFurrowsOld = nPleuralFurrows;
int nSpines = 0, nSpinesOld = nSpines;
float centerX;
PImage curImg = null, tempImg;
PGraphics tempG = null;
ArrayList<textBox> textBoxes = new ArrayList<textBox>();
ArrayList<dropdown> dropDowns = new ArrayList<dropdown>();
dropdown openDropdown;
textBox openTextBox;
boolean boxOpen = false, openShouldBe = false, openOpensDown = true, mouseMoving = false;
int mouseStartX, mouseStartY, imgStartX = 0, imgStartY = 0, imgStartXOld, imgStartYOld, widthOld, heightOld;
boolean shiftPressed, draggingImage, hasTempImg;
float zoomLevel = 1.0, zoomLevelOld = 1.0;
textBox zoom;
textBox axisFurrows;
boolean displayLeft = true, displayRight = false;
template tem;
float translateX = 1000, translateY = 100;
float cumulativeRotation = 0;
float mouseXOld = 0, mouseYOld = 0;
int scrollFactor = 0;
String curImgPath, curProjName = "ICS 10024", curImgName, curImgPathOld, scaleUnits = "mm";
ArrayList<String> YNOptions = new ArrayList<String>();
ArrayList<String> ornamentationOptions = new ArrayList<String>();
boolean movedScale = false;
boolean addAxisFurrows = true, purgeAxisFurrows = false, addPleuralFurrows = true, purgePleuralFurrows = false, addSpines = true, purgeSpines = false;
boolean updateWayPointsNextFrame = false;
int saveFill = 0;
TableRow curRow;

//TODO: Cephalon templates, customizable projects, dynamic template creation?


void setup() {
  // size(3000, 2000);
  size(2000, 1500);
  background(255);
  //   surface.setResizable(true);
  // selectInput("Select image to analyze", "loadNewImage");
  loadTemplates();    //Creates templates; there is only one template at the moment:
  tem = coryPygid;    //This one
  getAxisFurrows(nAxisFurrows);    //generates the initial number of axial furrows
  getPleuralFurrows(nPleuralFurrows);  //likewise pleural furrows
  getSpines(nSpines);  //likewise spines
  zoom = new textBox("zoom", width-100, 110, 30, 100, true);
  textBoxes.add(zoom);
  for (textBox b : tem.textBoxes) {    //So that all templates and dropdowns can be accessed by the cursor from one list
    textBoxes.add(b);
  }
  for (dropdown dd : tem.dropdowns) {
    dropDowns.add(dd);
  }
  tempImg = new PImage(width, height);
  //   new project(curProjName);      //This has to be run every time a new file is wanted. Will delete all data saved to an existing project with the same name. Use with caution.
  loadProject(curProjName);  //Hardcoded to ICS-10024 for now, since that's the only project I'm working on
  YNOptions.add("Yes");  //Generating lists for dropdowns
  YNOptions.add("No");
  YNOptions.add("Partial");
  YNOptions.add("Unclear");
  ornamentationOptions.add("None");
  ornamentationOptions.add("Concentric terrace lines");
  ornamentationOptions.add("Scattered fine pits");
  ornamentationOptions.add("Granular ornamentation");
  ornamentationOptions.add("Unclear");
  registerMethod("pre", this);
  // println(str(nAxisFurrows));
}

void pre() {    //I hate this function. It exists because I was having thread problems when deleting spines. It makes everything else worse.
  // println("pre");
  // println(purgePleuralFurrows);
  ArrayList<Integer> toKill = new ArrayList<Integer>();
  if (purgeAxisFurrows) {    //Removes axial furrows
    for (int i = 0; i < tem.wayPoints.size(); i++) {
      if (tem.wayPoints.get(i).type == "axial") {
        toKill.add(i);
      }
    }
    for (int i = 0; i < toKill.size(); i++) {
      tem.wayPoints.remove(toKill.get(i) - i);
    }
    toKill.clear();
    addAxisFurrows = true;
    purgeAxisFurrows = false;
  }
  if (purgePleuralFurrows) {    //Likewise pleural furrows
    for (int i = 0; i < tem.wayPoints.size(); i++) {
      if (tem.wayPoints.get(i).type == "pleural") {
        toKill.add(i);
      }
    }
    //   println(toKill.size());
    //   println(tem.wayPoints.size());
    for (int i = 0; i < toKill.size(); i++) {
      tem.wayPoints.remove(toKill.get(i) - i);
    }
    //  println(tem.wayPoints.size());
    toKill.clear();
    addPleuralFurrows = true;
    purgePleuralFurrows = false;
  }
  if (purgeSpines) { //Likewise spines
    for (int i = 0; i < tem.wayPoints.size(); i++) {
      if (tem.wayPoints.get(i).type == "spine") {
        toKill.add(i);
      }
    }
    for (int i = 0; i < toKill.size(); i++) {
      tem.wayPoints.remove(toKill.get(i) - i);
    }
    toKill.clear();
    addSpines = true;
    purgeSpines = false;
  }
}

void loadNewImage(File s) {    //Three guesses what this does
  curImgPath = s.toString();
  if (s != null) {
    curImg = loadImage(s.toString());
  }
  hasTempImg = false;
  scaleA = new wayPoint("scaleA", 300, 100, "scale");    //Hard reset of the scale bar; absolutely do not want to accidentally confuse the scale from one img with the next
  scaleB = new wayPoint("scaleB", 200, 100, "scale");
  scaleA.isScale = true;
  scaleB.isScale = true;
  movedScale = false;
  zoomLevel = 1;  //reset zoom too
  zoom.chars.clear();
  imgStartX = 0;
  imgStartY = 0;
  tem.textBoxes.get(4).chars.clear();    //reset the ID of the image
  tem.textBoxes.get(2).chars.clear();    //reset the scale distance
  for (dropdown dd : tem.dropdowns) {    //clear all dropdowns
    dd.selected = -1;
  }
  curRow = tab.findRow(curImgPath, "filepath");
  TableRow r = curRow;
  if (r != null) { // if this image has saved waypoints associated with it; looking at the image filepath
    zoomLevel = r.getFloat("zoom"); //set everything to what's been saved
    zoomLevelOld = zoomLevel;
    cumulativeRotation = r.getFloat("rotation");
    translateX = r.getFloat("translate_x");
    translateY = r.getFloat("translate_y");
    imgStartX = r.getInt("imgX");
    imgStartY = r.getInt("imgY");
    nAxisFurrows = r.getInt("axisFurrows");
    nPleuralFurrows = r.getInt("pleuralFurrows");
    nSpines = r.getInt("spines");
    //  getAxisFurrows(nAxisFurrows);
    //  getPleuralFurrows(nPleuralFurrows);
    //  getSpines(nSpines);
    purgeAxisFurrows = true; //BURN THE FURROWS
    purgePleuralFurrows = true;
    purgeSpines = true;
    nAxisFurrowsOld = nAxisFurrows;
    nPleuralFurrowsOld = nPleuralFurrows;
    nSpinesOld = nSpines;
    zoom.chars.clear();
    // loadTemplates();
    //  tem = coryPygid;
    scaleA.xPos = r.getFloat("scaleA_xPos");
    scaleA.yPos = r.getFloat("scaleA_yPos");
    scaleB.xPos = r.getFloat("scaleB_xPos");
    scaleB.yPos = r.getFloat("scaleB_yPos");
    displayLeft = boolean(r.getString("dispL"));
    displayRight = boolean(r.getString("dispR"));  
    movedScale = true;
    tem.textBoxes.get(0).setText(str(nAxisFurrows));
    tem.textBoxes.get(1).setText(str(nPleuralFurrows));
    zoom.setText(str(zoomLevel));
    tem.textBoxes.get(5).setText(str(nSpines));  //Set all options to whatever they were
    tem.textBoxes.get(2).setText(str(r.getFloat("scaleDist")));
    tem.textBoxes.get(4).setText(r.getString("id"));
    tem.dropdowns.get(0).setSel(r.getString("ip_furrows"));
    tem.dropdowns.get(1).setSel(r.getString("exfoliated"));
    tem.dropdowns.get(2).setSel(r.getString("ornamentation"));
    updateWayPointsNextFrame = true;  //This is because of the aforementioned bloody thread issues
  }
  // println(textBoxes.size());
}

void draw() {
  background(255);
  stroke(0);
  strokeWeight(1);
  // println(tem.countVals.get(1));
  //  println(degrees(cumulativeRotation));
  //println(zoomLevel);
  // addPleuralFurrows = false;
  if (zoom.getText().equals("")) {
    zoomLevel = 1;
  } else {
    zoomLevel = float(zoom.getText());
  }
  if (zoomLevel != zoomLevelOld) {
    hasTempImg = false;
    zoomLevelOld = zoomLevel;
  }
  if (widthOld != width || heightOld != height) {
    hasTempImg = false;
    widthOld = width;
    heightOld = height;
  }
  if (curImg != null && draggingImage) {  //Only create a new small image if necessary, for performance
    image(curImg, imgStartX, imgStartY, zoomLevel*width, zoomLevel*curImg.height*(width*1.0/curImg.width));
  }
  if (curImg != null && !draggingImage && hasTempImg) {
    image(tempImg, 0, 0);
  }
  if (curImg != null && !draggingImage && !hasTempImg) {  //The trilobite pictures are huge. Using a smaller version, just what's show on screen, for performance reasons
    image(curImg, imgStartX, imgStartY, zoomLevel*width, zoomLevel*curImg.height*(width*1.0/curImg.width));
    loadPixels();
    tempImg = new PImage(width, height);
    tempImg.loadPixels();
    for (int i = 0; i < width*height; i++) {
      tempImg.pixels[i] = pixels[i];
      if (i % 1000 == 0) {
      }
    }
    tempImg.updatePixels();
    image(tempImg, 0, 0);
    hasTempImg = true;
  }

  if (!tem.textBoxes.get(0).getText().equals("")) {  //Make sure all the furrows and spines are still as they should be
    nAxisFurrows = int(tem.textBoxes.get(0).getText());
  }
  if (!tem.textBoxes.get(1).getText().equals("")) {
    nPleuralFurrows = int(tem.textBoxes.get(1).getText());
    //   println(int(tem.textBoxes.get(1).getText()));
  }
  if (!tem.textBoxes.get(5).getText().equals("")) {
    nSpines = int(tem.textBoxes.get(5).getText());
  }
  if (nAxisFurrows != nAxisFurrowsOld) {
    //  getAxisFurrows(nAxisFurrows);
    nAxisFurrowsOld = nAxisFurrows;
    purgeAxisFurrows = true;
  }
  if (nPleuralFurrows != nPleuralFurrowsOld) {
    //   getPleuralFurrows(nPleuralFurrows);
    nPleuralFurrowsOld = nPleuralFurrows;
    purgePleuralFurrows = true;
  }
  if (nSpines != nSpinesOld) {
    //  getSpines(nSpines);
    nSpinesOld = nSpines;
    purgeSpines = true;
  }
  fill(200);    //Draw the UI
  rect(width-100, 0, 100, 30);
  fill(150);
  if(saveFill > 0){
    rect(width-100,0,5*saveFill,30);
    saveFill--;
  }
  textSize(24);
  fill(0);
  text("Save", width-97, 24);
  fill(200);
  rect(width-100, 30, 100, 30);
  textSize(24);
  fill(0);
  text("Load", width-97, 54);
  getAxisFurrows(nAxisFurrows);
  getPleuralFurrows(nPleuralFurrows);
  getSpines(nSpines);
  if (displayLeft) {
    fill(200);
  } else {
    fill(255);
  }
  rect(width-100, 60, 50, 50);
  if (displayRight) {
    fill(200);
  } else {
    fill(255);
  }
  rect(width-50, 60, 50, 50);
  fill(0);
  textSize(44);
  text("L", width-95, 104);
  text("R", width-45, 104);
  textSize(24);
  fill(200);
  strokeWeight(1);
  rect(0, height-60, 200, 30);
  rect(0, height-30, 200, 30);
  rect(0, height-90, 100, 30);
  rect(0, height-120, 200, 30);
  rect(300, height-90, 300, 30);
  rect(300, height-60, 300, 30);
  rect(300, height-30, 300, 30);
  rect(0, 0, 100, 30);
  rect(300, height-120, 100, 30);
  fill(0);
  text("Axial furrows:", 3, height-36);
  text("Pleural furrows:", 3, height-6);
  text("Scale:", 3, height-66);
  text("Specimen ID:", 3, height-96);
  text("Interpleural furrows:", 303, height-66);
  text("Exfoliation:", 303, height-36);
  text("Surface ornamentation:", 303, height-6);
  text("Reset", 3, 24);
  text("Spines:", 303, height-96);

  for (textBox tb : textBoxes) {  //Display the interactables
    tb.display(tb.y);
  }
  for (dropdown dd : dropDowns) {
    dd.display(dd.y);
  }
  //  float CROld = cumulativeRotation;
  //  cumulativeRotation = 0;
  //  tem.display();
  //  cumulativeRotation = CROld;
  if (updateWayPointsNextFrame) {  //If we just loaded a saved image
    for (wayPoint wp : tem.wayPoints) {    //Set all the waypoints to where they were
      wp.xPos = curRow.getFloat(wp.name + "_xPos");  //This has to happen on the next frame to give a chance to generate axial furrows in pre(), but I hate it
      wp.yPos = curRow.getFloat(wp.name + "_yPos");
      wp.certain = boolean(curRow.getString(wp.name + "_certain"));
      if (wp.arcPinned) {
        wp.arcPin = curRow.getFloat(wp.name + "_pin");
      }
      wp.justMovedControl = true; //Control points move other waypoints when they move
    }
    updateWayPointsNextFrame = false;
  }
  int axial = 0;
  int pleural = 0;
  int spine = 0;
  for (wayPoint wp : tem.wayPoints) { //Umm, I don't think I'm using this anymore, but it was useful to make sure I had the right number of meristic characters generated
    if (wp.type == "axial") axial++;
    if (wp.type == "pleural") pleural++;
    if (wp.type == "spine") spine++;
  }
  // println(pleural);
  if (axial == 2*(nAxisFurrows - 2) && pleural == 2*(nPleuralFurrows - 1) && spine == 4*nSpines) {
    tem.display();
  }
  // for(wayPoint wp : tem.wayPoints){
  //   wp.drawDot(wp.xPos + 1000, wp.yPos + 100);
  // }
  connect(scaleA, scaleB, color(255));  //The scale bar is inviolate
  scaleA.update();
  scaleB.update();
}

void getAxisFurrows(int n) {  //Generates new axial furrows
  if (addAxisFurrows) {     //But no longer destroys them; that happens in pre()
    String name = "";
    float axisLength = axisLastFurrow.yPos - CPAxisTop.yPos;
    for (int i = 0; i < n - 2; i++) {
      name = "AxisFurrowCenter" + i;
      tem.wayPoints.add(new wayPoint(name, CPAxisTop.xPos, CPAxisTop.yPos + (i+1)*(axisLength/(n-1)), "axial"));
      wayPoint wp = getWayPoint(name, tem.wayPoints);
      pin(wp, CPAxisTop, axisBottom);
      name = "AxisFurrowLat" + i;
      tem.wayPoints.add(new wayPoint(name, axisTopLat.xPos + (i+1)*(axisBottomLat.xPos - axisTopLat.xPos)/(n-1), CPAxisTop.yPos + (i+1)*(axisLength/(n-1)), "axial"));
      wp = getWayPoint(name, tem.wayPoints);
      pin(wp, axisTopLat, axisBottomLat);
      for (wayPoint w : coryPygid.wayPoints) {
        w.totalControl = CPAxisTop;
        w.xControl = CPAntLat;
        w.yControl = CPAxisBottom;
        w.rControl = CPAxisBottom;
      }
    }
  }
  addAxisFurrows = false;
}
void getPleuralFurrows(int n) {    //Likewise pleural furrows
  if (addPleuralFurrows) {
    addPleuralFurrows = false;
    String name = "";
    for (int i = 0; i < n - 1; i++) {
      name = "pleuralInner" + i;
      tem.wayPoints.add(new wayPoint(name, 0, 0, "pleural"));
      wayPoint wp = getWayPoint(name, tem.wayPoints);
      pin(wp, axisTopLat, axisBottomLat, (i+1.0)/n);
      name = "pleuralOuter" + i;
      tem.wayPoints.add(new wayPoint(name, 0, 0, "pleural"));
      wp = getWayPoint(name, tem.wayPoints);
      arcpin(wp, borderInnerLat, axisBottom, innerBorderBez2, innerBorderBez1, (i+1.0) / n);
      for (wayPoint w : tem.wayPoints) {
        w.totalControl = CPAxisTop;
        w.xControl = CPAntLat;
        w.yControl = CPAxisBottom;
        w.rControl = CPAxisBottom;
      }
    }
  }
  addPleuralFurrows = false;
}
void getSpines(int n) {    //Likewise spines
  if (addSpines) {
    String name = "";
    for (int i = 0; i < n; i++) {
      name = "spineBaseAnt" + i;
      tem.wayPoints.add(new wayPoint(name, 0, 0, "spine"));
      wayPoint wp = getWayPoint(name, tem.wayPoints);
      arcpin(wp, ALCornerLat, borderBottomCenter, outerBorderBez2, outerBorderBez1, (i)/(n+1.0));
      name = "spineBasePost" + i;
      tem.wayPoints.add(new wayPoint(name, 0, 0, "spine"));
      wp = getWayPoint(name, tem.wayPoints);
      arcpin(wp, ALCornerLat, borderBottomCenter, outerBorderBez2, outerBorderBez1, 0.1+(i)/(n+1.0));
      name = "spineTipAnt" + i;
      tem.wayPoints.add(new wayPoint(name, tem.wayPoints.get(tem.wayPoints.size()-2).xPos, tem.wayPoints.get(tem.wayPoints.size()-2).yPos+200, "spine"));
      name = "spineTipPost" + i;
      tem.wayPoints.add(new wayPoint(name, tem.wayPoints.get(tem.wayPoints.size()-3).xPos, tem.wayPoints.get(tem.wayPoints.size()-3).yPos+200, "spine"));
      for (wayPoint w : coryPygid.wayPoints) {
        w.totalControl = CPAxisTop;
        w.xControl = CPAntLat;
        w.yControl = CPAxisBottom;
        w.rControl = CPAxisBottom;
      }
    }
  }
  addSpines = false;
}


void mousePressed() {
  mouseStartX = mouseX;
  mouseStartY = mouseY;
  imgStartXOld = imgStartX;
  imgStartYOld = imgStartY;
  boolean draggingOther = false;
  for (int i = tem.wayPoints.size() - 1; i >= 0; i--) { //If clicking on a waypoint, move it around
    wayPoint wp = tem.wayPoints.get(i);
    if (mouseX >= wp.dispX - 10 && mouseX <= wp.dispX + 10 && mouseY >= wp.dispY - 10 && mouseY <= wp.dispY + 10 && !draggingOther && displayLeft) {
      wp.isDragging = true;
      draggingOther = true;
    }//Likewise if on its reflection
    if (mouseX >= wp.refX - 10 && mouseX <= wp.refX + 10 && mouseY >= wp.refY - 10 && mouseY <= wp.refY + 10 && !draggingOther && displayRight) {
      wp.draggingRef = true;
      draggingOther = true;
    }
  }//Even if it's the scale bar
  if (mouseX >= scaleA.xPos - 10 && mouseX <= scaleA.xPos + 10 && mouseY >= scaleA.yPos - 10 && mouseY <= scaleA.yPos + 10 && !draggingOther) {
    scaleA.isDragging = true;
    draggingOther = true;
    movedScale = true;
  }
  if (mouseX >= scaleB.xPos - 10 && mouseX <= scaleB.xPos + 10 && mouseY >= scaleB.yPos - 10 && mouseY <= scaleB.yPos + 10 && !draggingOther) {
    scaleB.isDragging = true;
    draggingOther = true;
    movedScale = true;
  }
  if (openTextBox != null) {  //Unchanged from X3CC
    openTextBox.updateCursor();
    openTextBox.hlStart = openTextBox.getCursor();
    openTextBox.hlEnd = openTextBox.hlStart;
    openTextBox.hasHL = true;
  }
}


void mouseDragged() {
  for (wayPoint wp : wayPoints) {
    if (wp.isDragging || wp.draggingRef) { //Does what it says on the box
      wp.update();
    }
  }
  if (openTextBox == null && shiftPressed) {  //Unchanged from X3CC
    imgStartX = mouseX + (imgStartXOld - mouseStartX);
    imgStartY = mouseY + (imgStartYOld - mouseStartY);
    if (movedScale) {
      scaleA.xPos = scaleA.xPos + imgStartX - imgStartXOld;
      scaleA.yPos = scaleA.yPos + imgStartY - imgStartYOld;
      scaleB.xPos = scaleB.xPos + imgStartX - imgStartXOld;
      scaleB.yPos = scaleB.yPos + imgStartY - imgStartYOld;
      imgStartXOld = imgStartX;
      imgStartYOld = imgStartY;
      mouseStartX = mouseX;
      mouseStartY = mouseY;
    }
    draggingImage = true;
    hasTempImg = false;
  }
  if (openTextBox != null) {//Highlighting is a pain
    if (openTextBox.hasHL) {
      openTextBox.hlEnd = openTextBox.getCursor();
      openTextBox.cursor = openTextBox.getCursor();
    }
  }
}

void mouseClicked() {
  openDropdown = null;
  openTextBox = null;
  if (mouseButton == LEFT) {
    if (mouseX > width - 100 && mouseY < 60 && mouseY > 30) {  //UI stuff
      selectInput("Select image to analyze", "loadNewImage");
    }
    if (mouseX > width - 100 && mouseY < 30) {
      saveTemplate();
    }
    if (mouseX > width - 100 && mouseX < width - 50 && mouseY > 60 && mouseY < 110) {
      displayLeft = !displayLeft;
    }
    if (mouseX > width - 50 &&  mouseY > 60 && mouseY < 110) {
      displayRight = !displayRight;
    }
    if (mouseX < 100 && mouseY < 30) {
      loadTemplates(); //hard reset everything
      tem = coryPygid;
      purgeAxisFurrows = true;
      purgePleuralFurrows = true;
      purgeSpines = true;
      zoom = new textBox("zoom", width-100, 110, 30, 100, true);
      textBoxes.clear();
      textBoxes.add(zoom);
      dropDowns.clear();
      translateX = 1000;
      translateY = 100;
      cumulativeRotation = 0;
      imgStartX = 0;
      imgStartY = 0;
      scaleA.xPos = 300;
      scaleA.yPos = 100;
      scaleB.xPos = 200;
      scaleB.yPos = 100;  //REALLY hard reset
      tem.textBoxes.get(4).chars.clear();
      tem.textBoxes.get(2).chars.clear();
      for (dropdown dd : tem.dropdowns) {
        dd.selected = -1;
      }
      movedScale = false;
      for (textBox b : tem.textBoxes) {
        textBoxes.add(b);
      }
      for (dropdown dd : tem.dropdowns) {
        dropDowns.add(dd);
      }
    }
    for (int a = 0; a < dropDowns.size(); a++) { //Unchanged from X3CC
      dropdown menu = dropDowns.get(a);
      if (mouseX > menu.x && mouseX < menu.x+menu.boxW && mouseY > menu.y && mouseY < menu.y+menu.boxH) {
        if (!menu.open && !boxOpen) { //  && !menu.isBlank
          menu.open = true;
          openDropdown = menu;
          openShouldBe = true;
          openOpensDown = menu.opensDown();
        }
      } else {
        if (menu.open) {
          if (menu.inWindow(mouseX, mouseY) && openOpensDown) {
            for (int r = 0; r < menu.optionsNormal.size(); r++) {
              if (menu.options.get(menu.hover).equals(menu.optionsNormal.get(r))) {
                menu.selected = r;
              }
            }
          }
          if (menu.inWindow(mouseX, mouseY) && !openOpensDown) {
            for (int r = 0; r < menu.optionsNormal.size(); r++) {
              if (menu.options.get(menu.hover).equals(menu.optionsNormal.get(r))) {
                menu.selected = r;
              }
            }
          }
          menu.open = false;
          openDropdown = null;
          openShouldBe = false;
        }
      }
    }
    for (textBox active : textBoxes) {
      if (active.inBox(mouseX, mouseY)) {
        if (active.open) {
          if (active.time > millis() - 500) {
            active.hasHL = true;
            active.hlStart = 0;
            active.hlEnd = active.chars.size();
          }
          active.time = millis();
        }
        if (!active.open && !boxOpen) {
          active.open = true;
          openShouldBe = true;
          active.cursor = active.chars.size();
        }
      } else if (active.open) {
        active.open = false;
        active = null;
        openShouldBe = false;
      }
    }
  } else {
    boolean justSwitched = false;
    for (wayPoint wp : tem.wayPoints) {
      if (mouseX >= wp.dispX - 10 && mouseX <= wp.dispX + 10 && mouseY >= wp.dispY - 10 && mouseY <= wp.dispY + 10) {
        wp.certain = !wp.certain;
        justSwitched = true;
      }
      if (mouseX >= wp.refX - 10 && mouseX <= wp.refX + 10 && mouseY >= wp.refY - 10 && mouseY <= wp.refY + 10 && !justSwitched) {
        wp.certain = !wp.certain;
      }
    }
  }
}

void keyPressed() {
  if (keyCode == SHIFT) {
    shiftPressed = true;
  }
  if (keyCode == CONTROL) {  //For getting pictures for demos; will replace with actual generator function if needed
    save(tem.textBoxes.get(4).getText() + ".jpg");
    println("screenshot");
  }
  for (int i = 0; i < textBoxes.size(); i++) {  //Unchanged from X3CC
    textBox box = textBoxes.get(i);
    if (box.open) {
      if (box.accept.contains(str(key))) {
        if (box.hasHL) {
          if (box.hlStart < box.hlEnd) {
            box.cursor = box.hlStart;
            box.hasHL = false;
            for (int e = box.hlStart; e < box.hlEnd; e++) {
              box.chars.remove(box.hlStart);
            }
            box.hlEnd = box.hlStart;
          } else {
            box.cursor = box.hlEnd;

            box.hasHL = false;
            for (int e = box.hlEnd; e < box.hlStart; e++) {
              box.chars.remove(box.hlEnd);
            }
            box.hlStart = box.hlEnd;
          }
        }
        box.chars.add(box.cursor, char(key));
        box.cursor++;
      }
      if (keyCode == BACKSPACE) {
        if (box.hasHL) {
          if (box.hlStart < box.hlEnd) {
            box.cursor = box.hlStart;
            box.hasHL = false;
            for (int q = box.hlStart; q < box.hlEnd; q++) {
              box.chars.remove(box.hlStart);
            }
            box.hlEnd = box.hlStart;
          } else {
            box.cursor = box.hlEnd;

            box.hasHL = false;
            for (int q = box.hlEnd; q < box.hlStart; q++) {
              box.chars.remove(box.hlEnd);
            }
            box.hlStart = box.hlEnd;
          }
        } else if (box.cursor > 0) {
          box.chars.remove(box.cursor-1);
          box.cursor--;
        }
      }
      if (keyCode == ENTER || keyCode == RETURN) {
        box.open = false;
        openShouldBe = false;
      }
      if (keyCode == LEFT && box.cursor > 0) {
        box.cursor--;
        box.hasHL = false;
        box.hlStart = box.cursor;
        box.hlEnd = box.cursor;
      }
      if (keyCode == RIGHT && box.cursor < box.chars.size()) {
        box.cursor++;
        box.hasHL = false;
        box.hlStart = box.cursor;
        box.hlEnd = box.cursor;
      }
    }
  }
  for (int i = 0; i < dropDowns.size(); i++) {
    dropdown menu = dropDowns.get(i);
    if (menu.open) {
      if (menu.accept.contains(str(key))) {
        menu.chars.add(char(key));
      }
      if (keyCode == BACKSPACE && menu.chars.size() > 0) {
        menu.chars.remove(menu.chars.size()-1);
      }
      boolean mouseHover;
      if (openOpensDown) {
        mouseHover = (mouseX > menu.x && mouseX < menu.x+menu.boxW && mouseY > menu.y+menu.boxH && mouseY < menu.y+(menu.options.size()+1)*menu.boxH);
      } else {
        mouseHover = (mouseX > menu.x && mouseX < menu.x+menu.boxW && mouseY < menu.y && mouseY > menu.y-(menu.options.size()*menu.boxH));
      }
      mouseHover = false;
      if (keyCode == UP && menu.hover > 0 && !mouseHover) {
        menu.hover--;
        //      println(menu.hover);
        mouseMoving = false;
      }
      if (keyCode == DOWN && menu.hover < menu.options.size()-1 && !mouseHover) {
        menu.hover++;
        //  println(menu.hover);
        mouseMoving = false;
        //     println("Down");
      }
      if (keyCode == ENTER || keyCode == RETURN) {
        if (menu.hover >= 0) {
          for (int r = 0; r < menu.optionsNormal.size(); r++) {
            if (menu.options.get(menu.hover).equals(menu.optionsNormal.get(r))) {
              menu.selected = r;
            }
          }
        }
        if (menu.options.size() == 1) {
          menu.selected = menu.convOption(0);
        }
        menu.open = false;
        openShouldBe = false;
      }
    }
  }
}

void keyReleased() {
  if (keyCode == SHIFT) {
    shiftPressed = false;
  }
}

void mouseReleased() {
  for (wayPoint wp : tem.wayPoints) {
    wp.isDragging = false;
    wp.draggingRef = false;
  }
  draggingImage = false;
  scaleA.isDragging = false;
  scaleB.isDragging = false;
}
void mouseMoved() {
  mouseMoving = true;
}