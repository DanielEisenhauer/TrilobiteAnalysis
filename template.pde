wayPoint axisTop, axisBottom, borderBottomCenter, borderInnerLat, ALCornerTop, ALCornerLat, axisTopLat, axisBottomLat, axisLastFurrow, scaleA, scaleB, outerBorderBez1, outerBorderBez2, innerBorderBez1, innerBorderBez2, CPAxisTop, CPAxisBottom, CPAntLat;
wayPoint axisFirstFurrow, axisRingTop, axisRingLat;
template coryPygid;
class template { //This is such a mess. Works right now, but adding cranidial templates will be a pain in the pygidium.
  String name;
  ArrayList<wayPoint> wayPoints;
  ArrayList<textBox> textBoxes;
  ArrayList<dropdown> dropdowns;
  ArrayList<String> countNames;
  ArrayList<Integer> countVals;
  ArrayList<String> qualNames;
  ArrayList<String> qualVals;

  template(String n) {
    name = n;
    wayPoints = new ArrayList<wayPoint>();
    textBoxes = new ArrayList<textBox>();
    dropdowns = new ArrayList<dropdown>();
    countNames = new ArrayList<String>();
    qualVals = new ArrayList<String>();
    qualNames = new ArrayList<String>();
    countVals = new ArrayList<Integer>();
  }


  void display() {
    pushMatrix();
    translate(translateX, translateY); //Translate to the position of CPAxisTop
    rotate(cumulativeRotation); //Rotate about CPAxisTop
    for (wayPoint wp : wayPoints) {
      wp.update();
    }

    connect(CPAxisTop, axisBottom, color(255));  //Draw all the lines
    connect(CPAxisTop, axisRingTop, color(255));
    connect(axisBottom, borderBottomCenter, color(255));
    connect(axisTopLat, ALCornerTop, color(255));
   // connect(ALCornerTop, ALCornerLat, color(255));
    connect(axisTopLat, axisBottomLat, color(255));

    connect(axisBottomLat, axisLastFurrow, color(255));
    connect(axisTopLat, CPAxisTop, color(255));
    connect(ALCornerLat, borderInnerLat, color(255));
    connect(axisFirstFurrow, borderInnerLat, color(255));
    //  connect(ALCornerLat,borderBottomCenter);
    noFill();
    connectArc(borderBottomCenter, outerBorderBez1, outerBorderBez2, ALCornerLat, color(135,206,250));
    connectArc(axisBottom, innerBorderBez1, innerBorderBez2, borderInnerLat, color(0, 255, 0));
    stroke(0);
    if(displayLeft){  //I said ALL THE LINES
      stroke(0);
      strokeWeight(4);
      arc(axisBottom.xPos, axisBottomLat.yPos, 2*(axisBottom.xPos - axisBottomLat.xPos), 2*(axisBottom.yPos - axisBottomLat.yPos), HALF_PI, PI);
      arc(0,axisRingLat.yPos,-2*axisRingLat.xPos,2*(axisRingLat.yPos - axisRingTop.yPos),PI,3*HALF_PI);
      arc(ALCornerTop.xPos, ALCornerLat.yPos,2*(ALCornerTop.xPos - ALCornerLat.xPos),2*(ALCornerLat.yPos - ALCornerTop.yPos),PI,3*HALF_PI);
      stroke(255);
      strokeWeight(2);
      arc(axisBottom.xPos, axisBottomLat.yPos, 2*(axisBottom.xPos - axisBottomLat.xPos), 2*(axisBottom.yPos - axisBottomLat.yPos), HALF_PI, PI);
      arc(0,axisRingLat.yPos,-2*axisRingLat.xPos,2*(axisRingLat.yPos - axisRingTop.yPos),PI,3*HALF_PI);
      arc(ALCornerTop.xPos, ALCornerLat.yPos,2*(ALCornerTop.xPos - ALCornerLat.xPos),2*(ALCornerLat.yPos - ALCornerTop.yPos),PI,3*HALF_PI);
    }
    if(displayRight){
      stroke(0);
      strokeWeight(4);
      arc(axisBottom.xPos, axisBottomLat.yPos, 2*(axisBottom.xPos - axisBottomLat.xPos), 2*(axisBottom.yPos - axisBottomLat.yPos),0,HALF_PI);
      arc(0,axisRingLat.yPos,-2*axisRingLat.xPos,2*(axisRingLat.yPos - axisRingTop.yPos),-HALF_PI,0);
      arc(-ALCornerTop.xPos, ALCornerLat.yPos,2*(ALCornerTop.xPos - ALCornerLat.xPos),2*(ALCornerLat.yPos - ALCornerTop.yPos),-HALF_PI,0);
      stroke(255);
      strokeWeight(2);
      arc(axisBottom.xPos, axisBottomLat.yPos, 2*(axisBottom.xPos - axisBottomLat.xPos), 2*(axisBottom.yPos - axisBottomLat.yPos), 0,HALF_PI);
      arc(0,axisRingLat.yPos,-2*axisRingLat.xPos,2*(axisRingLat.yPos - axisRingTop.yPos),-HALF_PI,0);
      arc(-ALCornerTop.xPos, ALCornerLat.yPos,2*(ALCornerTop.xPos - ALCornerLat.xPos),2*(ALCornerLat.yPos - ALCornerTop.yPos),-HALF_PI,0);
    }
    for(int i = 0; i < tem.wayPoints.size(); i++){
      if(tem.wayPoints.get(i).name.length() > 15 && tem.wayPoints.get(i).name.substring(0,16).equals("AxisFurrowCenter")){
        connect(tem.wayPoints.get(i),tem.wayPoints.get(i+1),color(255));
       // i++;
      }
      if(tem.wayPoints.get(i).name.length() > 12 && tem.wayPoints.get(i).name.substring(0,12).equals("pleuralInner")){
        connect(tem.wayPoints.get(i),tem.wayPoints.get(i+1),color(255));
      //  i++;
      }
      if(tem.wayPoints.get(i).name.length() > 12 && tem.wayPoints.get(i).name.substring(0,12).equals("spineBaseAnt")){
        connect(tem.wayPoints.get(i),tem.wayPoints.get(i+2),color(255));
        connect(tem.wayPoints.get(i+3),tem.wayPoints.get(i+2),color(255));
        connect(tem.wayPoints.get(i+3),tem.wayPoints.get(i+1),color(255));
      }
    }
    stroke(0);
    for (wayPoint wp : wayPoints) {//There's probably a reason I have them all update twice? I don't remember what it is. I'll screw with this later and see if I need it.
      //    wp.update();
      if (!wp.isScale) {
        wp.update();
      }
    }

    popMatrix();
    for(int i = 0; i < 3; i++){
      qualVals.set(i, dropdowns.get(i).getSel());
    }
    fill(0, 0, 255);
  }
}

void loadTemplates() {//Don't look too hard at this
  coryPygid = new template("Corynexochid pygidium");
  coryPygid.countNames.add("axisFurrows");
  coryPygid.countVals.add(nAxisFurrows);
  coryPygid.countNames.add("pleuralFurrows");
  coryPygid.countNames.add("spines");
  coryPygid.countVals.add(nPleuralFurrows);
  coryPygid.countVals.add(nSpines);
  coryPygid.textBoxes.add(new textBox("axialFurrows", 200, height - 60, 30, 100, true));
  coryPygid.textBoxes.get(0).setText(str(nAxisFurrows));
  coryPygid.textBoxes.add(new textBox("pleuralFurrows",200,height - 30,30,100,true));
  coryPygid.textBoxes.get(1).setText(str(nPleuralFurrows));
 // coryPygid.textBoxes.get(1).fillCol = color(255,0,0);
  coryPygid.textBoxes.add(new textBox("NONE",100,height - 90,30,100,true));
  coryPygid.textBoxes.add(new textBox("scaleUnits",200,height - 90,30,100,false));
 // coryPygid.textBoxes.get(3).chars.add('m');
 // coryPygid.textBoxes.get(3).chars.add('m');
 coryPygid.textBoxes.get(3).setText("mm");
  coryPygid.textBoxes.add(new textBox("NONE",200,height - 120,30,100,true));
  coryPygid.textBoxes.add(new textBox("spines",400,height-120,30,100,true));//All the interactables
  coryPygid.textBoxes.get(5).setText(str(nSpines));
  coryPygid.qualNames.add("ip_furrows");
  coryPygid.qualNames.add("exfoliated");
  coryPygid.qualNames.add("ornamentation");
  coryPygid.qualVals.add("");
  coryPygid.qualVals.add("");
  coryPygid.qualVals.add("");
  coryPygid.dropdowns.add(new dropdown("Not specified",600,height-90,30,400,YNOptions));
  coryPygid.dropdowns.add(new dropdown("Not specified",600,height-60,30,400,YNOptions));
  coryPygid.dropdowns.add(new dropdown("Not specified",600,height-30,30,400,ornamentationOptions));
  CPAxisTop = new wayPoint("CPAxisTop", 1000, 100, "control");//Generate all the waypoints
  axisBottom = new wayPoint("axisBottom", 1000, 1050, "standard");
  CPAxisBottom = new wayPoint("CPAxisBottom", 1000, 1200, "control");
  CPAntLat = new wayPoint("CPAntLat", 100, 100, "control");
  borderBottomCenter = new wayPoint("borderBottomCenter", 1000, 1100, "standard");
  ALCornerTop = new wayPoint("ALCornerTop", 200, 200, "standard");
  ALCornerTop.horizBar = true;
  ALCornerLat = new wayPoint("ALCornerLat", 100, 300, "standard");
  ALCornerLat.vertBar = true;
  axisTopLat = new wayPoint("axisTopLat", 850, 100, "standard");
  axisBottomLat = new wayPoint("axisBottomLat", 900, 950, "standard");
  axisLastFurrow = new wayPoint("axisLastFurrow", 1000, 950, "standard");
  borderInnerLat = new wayPoint("borderInnerLat", 150, 350, "standard");
  scaleA = new wayPoint("scaleA", 300, 100, "scale");
  scaleB = new wayPoint("scaleB", 200, 100, "scale");
  scaleA.isScale = true;
  scaleB.isScale = true;
  outerBorderBez1 = new wayPoint("outerBorderBez1", 347, 1106, "bezier");
  outerBorderBez2 = new wayPoint("outerBorderBez2", 119, 621, "bezier");
  innerBorderBez1 = new wayPoint("innerBorderBez1", 517, 1115, "bezier");
  innerBorderBez2 = new wayPoint("innerBorderBez2", 150, 651, "bezier");
  axisFirstFurrow = new wayPoint("axisFirstFurrow", 0, 0, "standard");
  axisRingTop = new wayPoint("axisRingTop", 1000, 50, "center");
  axisRingLat = new wayPoint("axisRingLat", 0,0,"standard");
  innerBorderBez1.col = color(0, 255, 0);
  innerBorderBez2.col = color(0, 255, 0);
  outerBorderBez1.col = color(135,206,250);
  outerBorderBez2.col = color(135,206,250);
  coryPygid.wayPoints.add(CPAxisTop);
  coryPygid.wayPoints.add(CPAxisBottom);
  coryPygid.wayPoints.add(CPAntLat);
  coryPygid.wayPoints.add(axisBottom);
  coryPygid.wayPoints.add(borderBottomCenter);
  coryPygid.wayPoints.add(ALCornerTop);
  coryPygid.wayPoints.add(ALCornerLat);//Continue generating all the waypoints
  coryPygid.wayPoints.add(axisTopLat);
  coryPygid.wayPoints.add(axisBottomLat);
  coryPygid.wayPoints.add(axisLastFurrow);
  coryPygid.wayPoints.add(borderInnerLat);
  coryPygid.wayPoints.add(axisFirstFurrow);
  coryPygid.wayPoints.add(axisRingTop);
  coryPygid.wayPoints.add(axisRingLat);
  pin(axisFirstFurrow, axisTopLat, axisBottomLat, 0.1);
  // pin(axisRingTop,CPAxisTop,CPAxisBottom);
  pin(axisLastFurrow, CPAxisTop, axisBottom);
  pin(axisBottom, CPAxisTop, CPAxisBottom);
  pin(borderBottomCenter, CPAxisTop, CPAxisBottom);
  pin(axisRingLat,CPAxisTop,axisTopLat,0.7);
//  axisLastFurrow.col = color(0);
  //  coryPygid.wayPoints.add(scaleA);
  // coryPygid.wayPoints.add(scaleB);
  coryPygid.wayPoints.add(outerBorderBez1);
  coryPygid.wayPoints.add(outerBorderBez2);
  coryPygid.wayPoints.add(innerBorderBez1);
  coryPygid.wayPoints.add(innerBorderBez2);
  CPAntLat.col = color(255, 0, 0);
  CPAxisTop.col = color(255, 0, 0);
  axisBottom.col = color(0, 255, 0);
  CPAxisBottom.col = color(255, 0, 0);

  for (wayPoint wp : coryPygid.wayPoints) { //Really generate all the waypoints
    wp.totalControl = CPAxisTop;
    wp.xControl = CPAntLat;
    wp.yControl = CPAxisBottom;
    wp.rControl = CPAxisBottom;
    wp.xPos -= 1000;
    wp.yPos -= 100;
  }
}