class wayPoint {
  String name;
  float xPos, yPos, refX, refY;
  boolean isDragging = false, pinned = false, certain = true, justMovedControl = false, isScale = false, arcPinned = false, hasMoved = false, draggingRef = false;
  wayPoint pinA = null, pinB = null, totalControl, xControl, yControl, rControl, bezA, bezB;
  float pinAXOld, pinAYOld, pinBXOld, pinBYOld, arcPin;
  float dispX, dispY, dispRefX, dispRefY;
  float tControlXOld = -100, tControlYOld, xControlXOld, yControlYOld, xControlYOld, yControlXOld, rControlXOld, rControlYOld, oldRotation = 0;
  String type;
  color col;
  boolean vertBar = false, horizBar = false;

  wayPoint(String n, float x, float y, String t) {
    name = n;
    xPos = x;
    yPos = y;
    type = t;
    col = color(255);
  }

  float getX() {
    return xPos;
  }
  float getY() {
    return yPos;
  }

  void update() {
    if (!isScale) {
      dispX = xPos*cos(cumulativeRotation) - yPos*sin(cumulativeRotation) + translateX;//Scale waypoints don't move and are displayed independently
      dispY = xPos*sin(cumulativeRotation) + yPos*cos(cumulativeRotation) + translateY;
    } else {
      dispX = xPos;
      dispY = yPos;
    }
    if (hasMoved) {
      hasMoved = false;
    }
    if (tControlXOld == -100 && totalControl != null) {
      //  println(name);
      //  println(totalControl.name);
      tControlXOld = totalControl.xPos;
      tControlYOld = totalControl.yPos;  //if CPAxisTop has moved, move everything else with it
      xControlXOld = xControl.xPos;
      xControlYOld = xControl.yPos;
      yControlYOld = yControl.yPos;
      yControlXOld = yControl.xPos;
    }
    if ((!pinned && !arcPinned) && pinA != null) {
      arcPinned = true;
      pinAXOld = pinA.xPos;//This isn't how I'm handling pins anymore, but I think a couple WPs still use it. Could change later, but meh
      pinAYOld = pinA.yPos;
      pinBXOld = pinB.xPos;
      pinBYOld = pinB.yPos;
      bezA = pinA;
      bezB = pinB;
      arcPin = dist(xPos, yPos, pinA.xPos, pinA.yPos)/dist(pinA.xPos, pinA.yPos, pinB.xPos, pinB.yPos);
    }
    if(justMovedControl){
      tControlXOld = totalControl.xPos;  //Because all the other control points also got moved, and I don't need to count them twice
      tControlYOld = totalControl.yPos;
      xControlXOld = xControl.xPos;
      yControlYOld = yControl.yPos;
      yControlXOld = yControl.xPos;
      xControlYOld = xControl.yPos;
      rControlXOld = rControl.xPos;
      rControlYOld = rControl.yPos;
    }
    if (totalControl != null && (totalControl.xPos != tControlXOld || totalControl.yPos != tControlYOld) && !totalControl.equals(this) && !isScale) {
      xPos += (totalControl.xPos - tControlXOld);
      yPos += (totalControl.yPos - tControlYOld); //if CPAxisTop moves
      tControlXOld = totalControl.xPos;
      tControlYOld = totalControl.yPos;
      xControlXOld = xControl.xPos;
      yControlYOld = yControl.yPos;
      yControlXOld = yControl.xPos;
      xControlYOld = xControl.yPos;
      rControlXOld = rControl.xPos;
      rControlYOld = rControl.yPos;
      justMovedControl = true;
    }

    if (xControl != null && (xControl.xPos != xControlXOld || xControl.yPos != xControlYOld) && !xControl.equals(this) && !isScale && !justMovedControl) {
      float distChange = (totalControl.xPos - xControl.xPos) / (totalControl.xPos - xControlXOld);
      xPos = totalControl.xPos - (totalControl.xPos - xPos)*distChange;
      xControlXOld = xControl.xPos; //If CPAntLat moves
      xControlYOld = xControl.yPos;
      justMovedControl = true;
    }
    if (yControl != null && (yControl.yPos != yControlYOld || yControl.xPos != yControlXOld) && !yControl.equals(this) && !isScale && !justMovedControl) {
      float distChange = (totalControl.yPos - yControl.yPos) / (totalControl.yPos - yControlYOld);
      yPos = totalControl.yPos - (totalControl.yPos - yPos)*distChange;
      yControlYOld = yControl.yPos;
      yControlXOld = yControl.xPos;
      justMovedControl = true; //if CPAxisBottom moves
    }

    float mouseTempX = mouseX;
    float mouseTempY = mouseY;
    //   if (draggingRef) {
    // mouseTempX = ((translateX - mouseX) + mouseY*sin(cumulativeRotation))/cos(cumulativeRotation);
    // mouseTempY = (translateY - mouseY - mouseX*sin(cumulativeRotation))/cos(cumulativeRotation);
    //   }
    if(pinned){
      println("pinned"); //Nothing is pinned anymore. Converted entirely to arcPins for consistency. All code referencing pin could be deleted, but I haven't bothered
    }
    if (isDragging || draggingRef) {
   //   println(name);
      hasMoved = true;
      if (pinned) {//Nothing is anymore, but screw it
        if (abs(pinA.dispX - pinB.dispX) >= abs(pinA.dispY - pinB.dispY)) {
          if ((mouseTempX > pinA.dispX && mouseTempX < pinB.dispX) || (mouseTempX < pinA.dispX && mouseTempX > pinB.dispX)) {
            dispX = mouseTempX;
            dispY = pinA.dispY + (dispX - pinA.dispX)/(pinB.dispX - pinA.dispX)*(pinA.dispY - pinB.dispY);
          }
        } else {
          if ((mouseTempY > pinA.dispY && mouseTempY < pinB.dispY) || (mouseTempY < pinA.dispY && mouseTempY > pinB.dispY)) {
            dispY = mouseTempY;
            dispX = pinA.dispX - (dispY - pinA.dispY)/(pinB.dispY - pinA.dispY)*(pinA.dispX - pinB.dispX);
          }
        }
        xPos = (dispX - translateX)*cos(-cumulativeRotation) - (dispY - translateY)*sin(-cumulativeRotation);
          yPos = (dispY - translateY)*cos(-cumulativeRotation) + (dispX - translateX)*sin(-cumulativeRotation);
      } else if (arcPinned) {
        FloatList dists = new FloatList();
        for (float i = 0; i <= 1; i+=0.005) {//I might work on increasing resolution here without trashing performance.
          if (isDragging) {
            dists.append(dist(mouseTempX, mouseTempY, ((pow((1 - i), 3)*pinA.dispX) + (3*sq(1-i)*i*bezA.dispX) +(3*(1-i)*sq(i)*bezB.dispX + (pow(i, 3)*pinB.dispX))), ((pow((1 - i), 3)*pinA.dispY) + (3*sq(1-i)*i*bezA.dispY) +(3*(1-i)*sq(i)*bezB.dispY + (pow(i, 3)*pinB.dispY)))));
          } else {
            dists.append(dist(mouseTempX, mouseTempY, ((pow((1 - i), 3)*pinA.refX) + (3*sq(1-i)*i*bezA.refX) +(3*(1-i)*sq(i)*bezB.refX + (pow(i, 3)*pinB.refX))), ((pow((1 - i), 3)*pinA.refY) + (3*sq(1-i)*i*bezA.refY) +(3*(1-i)*sq(i)*bezB.refY + (pow(i, 3)*pinB.refY)))));
          }
          for (int f = 0; f < dists.size(); f++) {
            if (dists.get(f) == dists.min()) {
              arcPin = (f*0.005); //Move the point to the closest possible place on the line to the cursor
            }
          }
          dispX = (pow((1 - arcPin), 3)*pinA.dispX) + (3*sq(1-arcPin)*arcPin*bezA.dispX) +(3*(1-arcPin)*sq(arcPin)*bezB.dispX + (pow(arcPin, 3)*pinB.dispX));
          dispY = (pow((1 - arcPin), 3)*pinA.dispY) + (3*sq(1-arcPin)*arcPin*bezA.dispY) +(3*(1-arcPin)*sq(arcPin)*bezB.dispY + (pow(arcPin, 3)*pinB.dispY));
          xPos = (dispX - translateX)*cos(-cumulativeRotation) - (dispY - translateY)*sin(-cumulativeRotation); //Screw Bezier and his formulas
          yPos = (dispY - translateY)*cos(-cumulativeRotation) + (dispX - translateX)*sin(-cumulativeRotation);
        }
      } else {
        if (isDragging) {
          dispX = mouseTempX;
          dispY = mouseTempY; //Isn't this so easy when things aren't pinned
          xPos = (dispX - translateX)*cos(-cumulativeRotation) - (dispY - translateY)*sin(-cumulativeRotation);//I hope this is finally the right display formula
          yPos = (dispY - translateY)*cos(-cumulativeRotation) + (dispX - translateX)*sin(-cumulativeRotation);
        } else {
          refX = mouseTempX; //Same thing except for the right side of the trilobite
          refY = mouseTempY;
          xPos = -((refX - translateX)*cos(-cumulativeRotation) - (refY - translateY)*sin(-cumulativeRotation));
          yPos = (refY - translateY)*cos(-cumulativeRotation) + (refX - translateX)*sin(-cumulativeRotation);
        }
        if (this.equals(CPAxisBottom)) { //CPAxisBottom controls rotation about CPAxisTop
          cumulativeRotation = -atan((translateX - mouseX)/(translateY - dispY));
          xPos = 0;
          yPos = dist(0, 0, mouseTempX-translateX, mouseTempY-translateY);
        }
        if (this.equals(CPAntLat)) {
          yPos = 0; //So that it doesn't move itself, since it's its own control point
          xPos = -dist(0, 0, mouseTempX-translateX, mouseTempY-translateY);
        }
        if (this.equals(CPAxisTop)) {
          xPos = 0; //It ALWAYS lives at 0,0. TranslateX and translateY put it where it goes on the screen. This means all trilo coordinates are relative to it
          yPos = 0;

          translateX = mouseX;
          translateY = mouseY;
        }
        if (this.isScale){
          xPos = dispX;
          yPos = dispY;
        }
      }
    }




    if ((pinned || arcPinned) && justMovedControl) {
      pinAXOld = pinA.xPos;
      pinBXOld = pinB.xPos;
      pinAYOld = pinA.yPos;
      pinBYOld = pinB.yPos;
    }
    if (pinned && (pinA.xPos != pinAXOld || pinA.yPos != pinAYOld || pinB.xPos != pinBXOld || pinB.yPos != pinBYOld)) { //Pinned WPs move with their pins
      float downPercent = dist(xPos, yPos, pinAXOld, pinAYOld)*1.0/dist(pinAXOld, pinAYOld, pinBXOld, pinBYOld);
      xPos = pinA.xPos + downPercent*(pinB.xPos - pinA.xPos);
      yPos = pinA.yPos + downPercent*(pinB.yPos - pinA.yPos);
      pinAXOld = pinA.xPos;
      pinAYOld = pinA.yPos;
      pinBXOld = pinB.xPos;
      pinBYOld = pinB.yPos;
      hasMoved = true;
    }
    if (arcPinned && (pinA.hasMoved || pinB.hasMoved || bezA.hasMoved || bezB.hasMoved)) { //Arcpins are pinned to a Bezier curve, not to a straight line
      xPos = (pow((1 - arcPin), 3)*pinA.xPos) + (3*sq(1-arcPin)*arcPin*bezA.xPos) +(3*(1-arcPin)*sq(arcPin)*bezB.xPos + (pow(arcPin, 3)*pinB.xPos));
      yPos = (pow((1 - arcPin), 3)*pinA.yPos) + (3*sq(1-arcPin)*arcPin*bezA.yPos) +(3*(1-arcPin)*sq(arcPin)*bezB.yPos + (pow(arcPin, 3)*pinB.yPos));
      hasMoved = true;
    }
    if(type == "center"){ //For WPs on the line between CPAxisTop and CPAxisBottom
      xPos = 0;
    }
    refX = -xPos*cos(cumulativeRotation) - yPos*sin(cumulativeRotation) + translateX;
    refY = -xPos*sin(cumulativeRotation) + yPos*cos(cumulativeRotation) + translateY;


    drawDot(xPos, yPos);//Display the WP
    justMovedControl = false;
    if (totalControl != null) {
      xControlXOld = xControl.xPos;
      xControlYOld = xControl.yPos;
      yControlXOld = yControl.xPos;
      yControlYOld = yControl.yPos;
      rControlXOld = rControl.xPos;
      rControlYOld = rControl.yPos;
      tControlXOld = totalControl.xPos;
      tControlYOld = totalControl.yPos;
    }
  }

  void drawDot(float x, float y) {
    strokeWeight(3);
    stroke(0);
    if (certain) {
      fill(col);
    } else {
      fill(100);
    }
    if(isScale){
      rect(x-5,y-5,10,10);
    }
    if (displayLeft) {
      if(vertBar && isDragging){ //VertBar and horizBar are for the anteriorlateral corner WPs, to make it more obvious where they should be placed
        line(x,y-200,x,y+200);
        line(x+5,y,x-5,y);
        strokeWeight(1);
        stroke(255);
        line(x,y-200,x,y+200);
        line(x+5,y,x-5,y);
        strokeWeight(3);
        stroke(0);
      }
      else if(horizBar && isDragging){
        line(x-200,y,x+200,y);
        line(x,y+5,x,y-5);
        strokeWeight(1);
        stroke(255);
        line(x-200,y,x+200,y);
        line(x,y+5,x,y-5);
        strokeWeight(3);
        stroke(0);
      }
      else{
        rect(x-5, y-5, 10, 10);   
      }
    }
    if (displayRight) {
      if(vertBar && draggingRef){
        line(-x,y-200,-x,y+200);
        line(-x+5,y,-x-5,y);
        strokeWeight(1);
        stroke(255);
        line(-x,y-200,-x,y+200);
        line(-x+5,y,-x-5,y);
        strokeWeight(3);
        stroke(0);
      }
      else if(horizBar && draggingRef){
        line(-x-200,y,-x+200,y);
        line(-x,y+5,-x,y-5);
        strokeWeight(1);
        stroke(255);
        line(-x-200,y,-x+200,y);
        line(-x,y+5,-x,y-5);
        strokeWeight(3);
        stroke(0);
      }
      else if(!isScale) {
        rect((-x)-5, y-5, 10, 10);
      }
    }
  }
}

wayPoint getWayPoint (String name, ArrayList<wayPoint> wps) { //Another one of those three guesses functions
  //  println(name);
  for (wayPoint wp : wps) {
    if (wp.name.equals(name)) {
      return wp;
    }
  }
  return null;
}

void pin(wayPoint a, wayPoint b, wayPoint c) { //Pinning lots of things in various ways. Nothing is actually pinnned; all of these arcpin.
  float dist = 0;  //This one pins the point to where it already is on-screen
  FloatList dists = new FloatList();
  for (float i = 0; i <= 1; i+=0.005) {
    dists.append(dist(a.xPos, a.yPos, ((pow((1 - i), 3)*b.xPos) + (3*sq(1-i)*i*b.xPos) +(3*(1-i)*sq(i)*c.xPos + (pow(i, 3)*c.xPos))), ((pow((1 - i), 3)*b.yPos) + (3*sq(1-i)*i*b.yPos) +(3*(1-i)*sq(i)*c.yPos + (pow(i, 3)*c.yPos)))));
  }
  for (int f = 0; f < dists.size(); f++) {
    if (dists.get(f) == dists.min()) {
      dist = (f*0.005);
    }
  }
  pin(a, b, c, dist);
}
void pin(wayPoint a, wayPoint b, wayPoint c, float dist) { //For pinning to a straight line, only need to define the endpoints
  arcpin(a, b, c, b, c, dist); //This one lets you specify a distance to pin it at
}
void arcpin(wayPoint toPin, wayPoint a, wayPoint b, wayPoint c, wayPoint d, float dist) {
  toPin.arcPinned = true; //This one really arcpins. If a/b and c/d are the same, it effectively pins to a straight line.
  toPin.arcPin = dist;
  toPin.pinA = a;
  toPin.pinB = b;
  toPin.bezA = c;
  toPin.bezB = d;
  toPin.pinAXOld = a.xPos;
  toPin.pinAYOld = a.yPos;
  toPin.pinBXOld = b.xPos;
  toPin.pinBYOld = b.yPos;
  toPin.xPos = (pow((1 - toPin.arcPin), 3)*toPin.pinA.xPos) + (3*sq(1-toPin.arcPin)*toPin.arcPin*toPin.bezA.xPos) +(3*(1-toPin.arcPin)*sq(toPin.arcPin)*toPin.bezB.xPos + (pow(toPin.arcPin, 3)*toPin.pinB.xPos));
  toPin.yPos = (pow((1 - toPin.arcPin), 3)*toPin.pinA.yPos) + (3*sq(1-toPin.arcPin)*toPin.arcPin*toPin.bezA.yPos) +(3*(1-toPin.arcPin)*sq(toPin.arcPin)*toPin.bezB.yPos + (pow(toPin.arcPin, 3)*toPin.pinB.yPos));
}


void connect(wayPoint a, wayPoint b, color c) { //Draw lines
  stroke(0);
  strokeWeight(4);
  if (displayLeft || a.isScale) {
  //  println(nPleuralFurrows);
 //   println(a.name);
  //  println(b.name);
    line(a.xPos, a.yPos, b.xPos, b.yPos);
  }
  if (displayRight && !a.isScale) {
    line(-a.xPos, a.yPos, -b.xPos, b.yPos);
  }
  stroke(c);
  strokeWeight(2);
  if (displayLeft || a.isScale) {
    line(a.xPos, a.yPos, b.xPos, b.yPos);
  }
  if (displayRight && !a.isScale) {
    line(-a.xPos, a.yPos, -b.xPos, b.yPos);
  }
}
void connectArc(wayPoint a, wayPoint b, wayPoint c, wayPoint d, color col) { //Draw Bezier curves
  strokeWeight(4);
  stroke(0);
  if (displayLeft) {
    bezier(a.xPos, a.yPos, b.xPos, b.yPos, c.xPos, c.yPos, d.xPos, d.yPos);
  }
  if (displayRight) {
    bezier(-a.xPos, a.yPos, -b.xPos, b.yPos, -c.xPos, c.yPos, -d.xPos, d.yPos);
  }
  strokeWeight(2);
  stroke(col);
  if (displayLeft) {
    bezier(a.xPos, a.yPos, b.xPos, b.yPos, c.xPos, c.yPos, d.xPos, d.yPos);
  }
  if (displayRight) {
    bezier(-a.xPos, a.yPos, -b.xPos, b.yPos, -c.xPos, c.yPos, -d.xPos, d.yPos);
  }
}