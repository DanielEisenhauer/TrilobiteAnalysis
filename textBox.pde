class textBox { //Unchanged from X3CC; don't look too closely
  int x, y, boxW, boxH, cursor = 0, hlStart, hlEnd, time = 0;
  ArrayList<Character> chars = new ArrayList<Character>();
  color fillCol, selCol, hlCol;
  boolean open, hasHL;
  String accept, name;
  PGraphics box;
  float cursorWidth;

  textBox(String field, int xPos, int yPos, int hei, int wid, boolean ints) {
    x = xPos;
    name = field;
    y = yPos;
    boxW = wid;
    boxH = hei;
    fillCol = color(255);
    selCol = color(0, 255, 0, 100);
    hlCol = color(0, 0, 255, 100);
    if (ints) {
      accept = "0123456789.";
    } else {
      accept = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,/':;-=+!@#$%^&*()_[]{}\\|?><`~\"";
    }
    //  accept = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
  }

  void display(int yPos) {
    y = yPos;
    box = createGraphics(boxW+1, boxH+1);
    box.beginDraw();
    box.fill(fillCol);
    box.stroke(0);
    box.rect(0, 0, boxW, boxH);
    box.fill(0);
    box.textSize(boxH*0.8);
    String current = "";
    for (int i = 0; i < chars.size(); i++) {
      current += str(chars.get(i));
    }
    if (!open) {
      hlStart = 0;
      hlEnd = 0;
      hasHL = false;
    }
    if (open) {
      box.fill(selCol);
      box.noStroke();
      // box.rect(0, 0, boxW, boxH);
      box.stroke(0);
      box.strokeWeight(2);
      cursorWidth = 0;
      if (cursor > chars.size()) {
        cursor = chars.size();
      }
      String tempWidth = "";
      for (int i = 0; i < cursor; i++) {
        tempWidth += chars.get(i);
      }
      //   print(cursor);
      cursorWidth = textWidth(tempWidth);
      box.line(0.2*boxH + cursorWidth, 0.1*boxH, 0.2*boxH + cursorWidth, 0.9*boxH);
      box.strokeWeight(1);
      if (hlStart != hlEnd) {
        hasHL = true;
        box.fill(hlCol);
        box.noStroke();
        if (hlStart < hlEnd) {
          float hlWidth = textWidth(current.substring(hlStart, hlEnd));
          box.rect(0.1*boxH + textWidth(current.substring(0, hlStart)), 0.1*boxH, hlWidth, 0.8*boxH);
        } else {
          float hlWidth = textWidth(current.substring(hlEnd, hlStart));
          box.rect(0.1*boxH + textWidth(current.substring(0, hlEnd)), 0.1*boxH, hlWidth, 0.8*boxH);
        }
      }
    }
    box.fill(0);
    box.stroke(0);
    box.text(current, (0.1*boxH), 0.8*boxH);
    if (current.equals("") && !open) {
      box.text(name, (0.1*boxH), 0.8*boxH);
    }
    box.endDraw();
    image(box, x, y);
  }

  String getText() {
    String current = "";
    for (int i = 0; i < chars.size(); i++) {
      current += str(chars.get(i));
    }
    return current;
  }

  boolean inBox (int a, int b) {
    return (a > x && a < x + boxW && b > y && b < y + boxH);
  }

  void setText(String toSet) {
    chars.clear();
    if (toSet != "") {
      for (int i = 0; i < toSet.length(); i++) {
        chars.add(toSet.charAt(i));
      }
    }
    //   println(toSet.charAt(0));
  }

  void updateCursor() {
    String tempWidth = "";
    if (chars.size() == 0 || mouseX < x + 0.1*boxH) {
      cursor = 0;
      hlStart = cursor;
      hlEnd = cursor;
      return;
      //  print("UpdateCursor1");
    }
    for (int i = 0; i <= chars.size(); i++) {
      if (mouseX >= x + 0.1*boxH + textWidth(tempWidth)) {
        cursor = i;
      } else if (mouseX - (x + 0.1*boxH + textWidth(tempWidth.substring(0, tempWidth.length()-1))) > (x + 0.1*boxH + textWidth(tempWidth) - mouseX)) {
        cursor = i;
        hlStart = cursor;
        hlEnd = cursor;
        //    print("UpdateCursor2");
      }
      if (i < chars.size()) {
        tempWidth += (chars.get(i));
      }
    }
    //  print(5);
  }

  int getCursor() {
    String tempWidth = "";
    int toReturn = 0;
    if (chars.size() == 0 || mouseX < x + 0.1*boxH) {
      return 0;
    }
    for (int i = 0; i <= chars.size(); i++) {
      if (mouseX >= x + 0.1*boxH + textWidth(tempWidth)) {
        toReturn = i;
      } else if (mouseX - (x + 0.1*boxH + textWidth(tempWidth.substring(0, tempWidth.length()-1))) > (x + 0.1*boxH + textWidth(tempWidth) - mouseX)) {
        toReturn = i;
      }
      if (i < chars.size()) {
        tempWidth += (chars.get(i));
      }
    }
    return toReturn;
  }
}