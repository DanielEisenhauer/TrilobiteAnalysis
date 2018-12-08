class dropdown { //Unchanged from X3CC; don't look too closely
  String field;
  ArrayList<String> options;
  int x, y, boxW, boxH, selected, hover, typeSel, scrollFactor, scrollY, totalHeight, windH;
  int scrollHeight;
  boolean open, isBlank = false, isTyping = false, hasScroll, opensDown, isLoadScreen;
  color fillCol, selCol, hoverCol, blankCol, wrongCol, oneOpCol;
  ArrayList<String> blank = new ArrayList<String>();
  ArrayList<String> optionsNormal = new ArrayList<String>();
  ArrayList<Character> chars = new ArrayList<Character>();
  String typed;
  String accept = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,/':;-=+!@#$%^&*()_[]{}\\|?><`~\"";
  PGraphics box;

  dropdown(String name, int xPos, int yPos, int hei, int wid, ArrayList<String> list) {
    field = name;
    x = xPos;
    y = yPos;
    boxW = wid;
    boxH = hei;
    options = list;
    selected = -1;
    open = false;
    fillCol = color(255);
    selCol = color(0, 255, 0, 100);
    hoverCol = color(0, 0, 255, 100);
    blankCol = color(220);
//    blankCol = color(235);
    wrongCol = color(255, 0, 0, 100);
    oneOpCol = color(100, 100, 100, 100);
    blank.add("");
    optionsNormal = options;
  }

  String getSel() {
    if (selected == -1) {
      return "";
    }
    return optionsNormal.get(selected);
  }

  ArrayList<String> getOptions() {
    ArrayList<String> tempOptions = new ArrayList<String>();
    for (String option : options) {
      String upOpt = option.toUpperCase();
      String upOptShort;
      if (typed.length() < upOpt.length()) {
        upOptShort = upOpt.substring(0, typed.length());
      } else {
        upOptShort = upOpt;
      }
      if (upOptShort.equals(typed.toUpperCase())) {
        tempOptions.add(option);
      }
    }
    return tempOptions;
  }

  int convOption(int i) {
    for (int a = 0; a < optionsNormal.size(); a++) {
      if (optionsNormal.get(a).equals(options.get(i))) {
        return a;
      }
    }
    return -1;
  }

  int revConvOption(int i) {
    for (int a = 0; a < options.size(); a++) {
      if (options.get(a).equals(optionsNormal.get(i))) {
        return a;
      }
    }
    return -1;
  }

  boolean inWindow(int a, int b) {
    if (open) {
      if (opensDown) {
        return(a > x && a < x+boxW && b > y+boxH && b < y+boxH+windH);
      } else {
        return(a > x && a < x+boxW && b > y-windH && b < y);
      }
    } else {
      return false;
    }
  }

  boolean onScroll(int a, int b) {
    if (open) {
      if (opensDown) {
        return(a > x+boxW-boxH && a < x+boxW && b > y+boxH+scrollY && b < y+boxH+windH+scrollY+scrollHeight);
      } else {
        return(a > x+boxW-boxH && a < x+boxW && b > y-windH+scrollY && b < y-windH+scrollY+scrollHeight);
      }
    } else {
      return false;
    }
  }

  boolean opensDown() {
    if (y + boxH * (options.size()+1) < height) {
      return true;
    } else if (options.size() * boxH < y) {
      return false;
    } else if (height - y - boxH > y) {
      return true;
    } else {
      return false;
    }
  }

  void setSel(String sel) {
    selected = -1;
    /*    if(sel.equals("")){
     return;
     }*/
    for (int i = 0; i < optionsNormal.size(); i++) {
      if (optionsNormal.get(i).equals(sel)) {
        selected = i;
      }
    }
  }

  void display(int yPos) {
    y = yPos;
    typed = "";
    options = optionsNormal;
    if (!open) {
      chars = new ArrayList<Character>();
      hover = -1;
      windH = 0;
    }
    for (int i = 0; i < chars.size(); i++) {
      typed += chars.get(i);
    }
    if (!typed.equals("")) {
      options = getOptions();
    }
    //Determine whether a scrollbar is needed, and whether to open the window upwards or downwards
    if (yPos + boxH * (options.size()+1) < height) {
      opensDown = true;
      hasScroll = false;
    } else if (options.size() * boxH < yPos) {
      opensDown = false;
      hasScroll = false;
    } else if (height - yPos - boxH > yPos) {
      if (!hasScroll) {
        scrollY = 0;
      }
      opensDown = true;
      hasScroll = true;
    } else {
      if (!hasScroll) {
        scrollY = 0;
      }
      opensDown = false;
      hasScroll = true;
    }
    //Determine the height of the open window
    if (!hasScroll) {
      windH = options.size()*boxH;
    } else if (opensDown) {
      windH = height - yPos - (4*boxH)/3;
    } else {
      windH = yPos - 4*boxH/3;
    }

    if (!hasScroll) {
      scrollFactor = 0;
      scrollHeight = 0;
      scrollY = 0;
    }
    if (isBlank) {
      fill(blankCol);
      stroke(0);
      rect(x, yPos, boxW, boxH);
    } else {
      fill(fillCol);
      if (options.size() == 1) {
        fill(blankCol);
      }
      stroke(0);
      rect(x, yPos, boxW, boxH);
      if (selected == -1) {
        fill(blankCol);
        noStroke();
        triangle(x+boxW - 0.6*boxH, yPos+0.3*boxH, x+boxW - 0.1*boxH, yPos+0.3*boxH, x+boxW - 0.35*boxH, yPos+0.7*boxH);
      }
      fill(0);
      textSize(boxH*0.8);
      if (selected >= 0 && typed.equals("")) {
        text(options.get(selected), x+0.1*boxH, yPos+0.8*boxH);
      } else if (typed.equals("")) {
        text(field, x+0.1*boxH, yPos+0.8*boxH);
      } else {
        text(typed, x+0.1*boxH, yPos+0.8*boxH);
      }
      if (options.size() == 1) {
        selected = 0;
      }
      if (open) {
        box = createGraphics(boxW+1, windH+1);
        box.beginDraw();
        box.fill(fillCol);
        box.textSize(boxH*0.8);
        box.stroke(0);
        box.rect(0, 0, boxW, windH);
        if (hasScroll) {
          box.fill(220);
          box.stroke(0);
          box.rect(boxW-30, 0, boxH, windH);
          totalHeight = options.size()*boxH;
          scrollHeight = int(windH*windH*1.0/totalHeight);
          box.fill(180);
          box.rect(boxW-30, scrollY, 30, scrollHeight);
          float scrollPortion = (scrollY)*1.0/(windH - scrollHeight);
          int extraHeight = totalHeight - windH;
          scrollFactor = int(extraHeight*scrollPortion);
        }
        box.fill(0);
        for (int i = 0; i < options.size(); i++) {
          box.text(options.get(i), 0.1*boxH, ((i+0.8)*boxH)-scrollFactor);
        }

        if (mouseMoving) {
          hover = -1;
        }
        if (inWindow(mouseX, mouseY) && mouseMoving) {
          if (opensDown) {
            hover = (mouseY - yPos - boxH + scrollFactor)/ boxH;
          } else {
            hover = ((mouseY-(y-windH)+scrollFactor) / boxH);
          }
        }
        if (hover > -1) {
          box.fill(hoverCol);
          box.noStroke();
          if (hasScroll) {
            box.rect(0, (hover)*boxH-scrollFactor, boxW-boxH, boxH);
          } else {
            box.rect(0, (hover)*boxH-scrollFactor, boxW, boxH);
          }
        }
        if (selected >= 0) {
          box.noStroke();
          box.fill(selCol);
          int tempSel = revConvOption(selected);
          if (tempSel > -1) {
            if (hasScroll) {
              box.rect(0, (tempSel)*boxH-scrollFactor, boxW-boxH, boxH);
            } else {
              box.rect(0, (tempSel)*boxH, boxW, boxH);
            }
          }
        }
        box.endDraw();
        if (opensDown) {
          image(box, x, y+boxH);
        } else {
          image(box, x, y-windH);
        }
      }
    }
  }
}