//lists of the objects
ArrayList<Rect> r= new ArrayList<Rect>();
ArrayList<Ellipse> e= new ArrayList<Ellipse>();
ArrayList<Line> l= new ArrayList<Line>();
int x1, x2, y1, y2; //used for creating new shapes
boolean newshape=false;
int selection; //used when choosing what shape to add
//keeps track of the 10 last values of the tracked pixel
IntList cursorXvalues;
IntList cursorYvalues;
//average of theese values to increase sensitivity
int X, Y;


import processing.video.*;
Capture video;

void setup() {
  size(640, 480);
  video = new Capture(this, 640, 480);
  video.start();
  cursorXvalues= new IntList();
  cursorYvalues= new IntList();
}

//the "interface", draws three boxes from which you can choose what shape to draw
void drawInterface() {
  noFill();
  stroke(0);
  if (selection==1) stroke(0, 255, 0);
  rect(78, 1, 75, 75);
  stroke(0);
  if (selection==2) stroke(0, 255, 0);
  rect(155, 1, 75, 75);
  stroke(0);
  if (selection==3) stroke(0, 255, 0);
  rect(1, 1, 75, 75);
  stroke(0);
  fill(#EDA0A0);
  line(3, 3, 72, 72);
  rect(82, 5, 67, 67);
  fill(#75CE84);
  ellipse(192, 38, 70, 70);
}

//class for the ellipse
class Ellipse {
  int x, y, w, h;
  boolean locked, rotate, scale;
  float angle;
  Ellipse(int x, int y, int w, int h ) {
    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;
    angle=0.0;
    locked=false;
    rotate=false;
    scale=false;
  }
  void update() {
    if (locked) {
      x=X;
      y=Y;
    }
    if (scale) {
      w=X-x/2;
      h=Y-y/2;
    }
    if (rotate) {
      angle=X*0.01*PI;
    }
  }
  void draw() {
    fill(#75CE84);
    pushMatrix();
    translate(x, y);
    rotate(angle);
    ellipse(0, 0, w, h);
    popMatrix();
  }
}
//rect class
class Rect {
  int x, y, w, h;
  boolean locked, rotate, scale;
  float angle;
  Rect(int x, int y, int w, int h) {
    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;
    angle=0.0;
    locked=false;
    rotate=false;
    scale=false;
  }
  void update() {
    if (locked) {
      x=X-w/2;
      y=Y-h/2;
    }
    if (scale) {
      w=X-x;
      h=Y-y;
    }
    if (rotate) {
      angle=X*0.01*PI;
    }
  }
  void draw() {
    fill(#EDA0A0);
    pushMatrix();
    translate(x+w/2, y+h/2);
    rotate(angle);
    rect(0-w/2, 0-h/2, w, h);
    popMatrix();
  }
}
//line class, note: no methods implemented, just thought it would be fun to draw lines aswell
class Line {
  int x1, y1, x2, y2;
  Line(int x1, int y1, int x2, int y2) {
    this.x1=x1;
    this.y1=y1;
    this.x2=x2;
    this.y2=y2;
  }
  void draw() {
    line(x1, y1, x2, y2);
  }
}

void draw() {
  background(255);
  //updates "cursor" position
  updateCursor();
  //loops through the lists to update and draw each shape
  for (Rect rect : r) {
    rect.update();
    rect.draw();
  }
  for (Ellipse ellipse : e) {
    ellipse.update();
    ellipse.draw();
  }
  for (Line line : l) {
    line.draw();
  }
  //draws temporary shapes if user is drawing a new one which is not yet complete
  if (newshape && selection==1) {
    fill(#EDA0A0);
    if (x1<X) {
      rect(x1, y1, abs(x1-X), abs(y1-Y));
    } else if (x1>X) {
      rect(X, Y, abs(x1-X), abs(y1-Y));
    }
    fill(255);
  }
  if (newshape && selection==2) {
    fill(#75CE84);
    if (x1<X) {
      ellipse(x1+(X-x1)/2, y1+(Y-y1)/2, abs(x1-X), abs(y1-Y));
    } else if (x1>X) {
      ellipse(X+(x1-X)/2, Y+(y1-Y)/2, abs(x1-X), abs(y1-Y));
    }
    fill(255);
  }
  if (newshape && selection==3) {
    line(x1, y1, X, Y);
  }
  drawInterface();
  fill(0);
  ellipse(X, Y, 10, 10);//the cursor as a black dot
}

//checks if the given x and y coordinates are on a rect
boolean checkRect(int x, int rectX, int rectW, int y, int rectY, int rectH) {
  if ((x>rectX && x<(rectX+rectW)) && (y>rectY && y<(rectY+rectH))) {
    return true;
  } else return false;
}
//checks if the given x and y coordinates are on an ellipse
boolean checkEllipse(int x, int ellipseX, int ellipseW, int y, int ellipseY, int ellipseH) {
  if (((x>ellipseX && x<(ellipseX+ellipseW/2)) || (x<ellipseX && x>(ellipseX-ellipseW/2)))
    && ((y>ellipseY && y<(ellipseY+ellipseH/2)) || (y<ellipseY && y>(ellipseY-ellipseH/2)))) {
    return true;
  } else return false;
}


void keyPressed() {
  if (key == CODED) {
    //alt used for scaling
    if (keyCode==ALT) {
      for (Rect rect : r) {
        if (checkRect(X, rect.x, rect.w, Y, rect.y, rect.h)) {
          rect.scale=true;
        }
      }  
      for (Ellipse ellipse : e) {
        if (checkEllipse(X, ellipse.x, ellipse.w, Y, ellipse.y, ellipse.h)) {  
          ellipse.scale=true;
        }
      }
    }
    //control for rotation
    if (keyCode==CONTROL) {
      for (Rect rect : r) {
        if (checkRect(X, rect.x, rect.w, Y, rect.y, rect.h)) {
          rect.rotate=true;
        }
      }  
      for (Ellipse ellipse : e) {
        if (checkEllipse(X, ellipse.x, ellipse.w, Y, ellipse.y, ellipse.h)) {  
          ellipse.rotate=true;
        }
      }
    }
    //shift is overall "selection" button (as leftcklick on mouse)
    if (keyCode==SHIFT) {
      for (Rect rect : r) {
        if (checkRect(X, rect.x, rect.w, Y, rect.y, rect.h)) {
          rect.locked=true;
        }
      }
      for (Ellipse ellipse : e) {
        if (checkEllipse(X, ellipse.x, ellipse.w, Y, ellipse.y, ellipse.h)) {  
          ellipse.locked=true;
        }
      }
      if (!newshape && selection!=0) { 
        x1=X;
        y1=Y;
        newshape=true;
      }
      if ((X>78 && X<153) && (Y>1 && Y<76)) {
        selection=1;
      }
      if ((X>155 && X<230) && (Y>1 && Y<76)) {
        selection=2;
      }
      if ((X>1 && X<76) && (Y>1 && Y<76)) {
        selection=3;
      }
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode==ALT) {
      for (Rect rect : r) {
        if (rect.scale) {
          rect.scale=false;
        }
      }
      for (Ellipse ellipse : e) {
        if (ellipse.scale) {
          ellipse.scale=false;
        }
      }
    }
    if (keyCode==CONTROL) {
      for (Rect rect : r) {
        if (rect.rotate) {
          rect.rotate=false;
        }
      }
      for (Ellipse ellipse : e) {
        if (ellipse.rotate) {
          ellipse.rotate=false;
        }
      }
    }
    if (keyCode==SHIFT) {
      for (Rect rect : r) {
        if (rect.locked) {
          rect.locked=false;
        }
      }
      for (Ellipse ellipse : e) {
        if (ellipse.locked) {
          ellipse.locked=false;
        }
      }
      if (newshape) {
        fill(#EDA0A0);
        x2=X;
        y2=Y;
        if (selection==1) {
          createRect(x1, x2, y1, y2);
        }
        if (selection==2) {
          createEllipse(x1, x2, y1, y2);
        }
        if (selection==3) {
          createLine(x1, x2, y1, y2);
        }
      }
      newshape=false;
    }
  }
}

//creates a new Rect object and adds it to the list
void createRect(int x1, int x2, int y1, int y2) {
  if (x1<x2) {
    r.add(new Rect(x1, y1, abs(x1-x2), abs(y1-y2)));
  } else if (x1>x2) {
    r.add(new Rect(x2, y2, abs(x1-x2), abs(y1-y2)));
  }
  selection= 0;
}

//creates a new Ellipse object and adds it to the list
void createEllipse(int x1, int x2, int y1, int y2) {
  if (x1<x2) {
    e.add(new Ellipse(x1+(x2-x1)/2, y1+(y2-y1)/2, abs(x1-x2), abs(y1-y2)));
  } else if (x1>x2) {
    e.add(new Ellipse(x2+(x1-x2)/2, y2+(y1-y2)/2, abs(x1-x2), abs(y1-y2)));
  }
  selection= 0;
}

//creates a new Line object and adds it to the list
void createLine(int x1, int x2, int y1, int y2) {
  l.add(new Line(x1, y1, x2, y2));
  selection=0;
}

void updateCursor() {
  if (video.available()) {
    colorMode(HSB);
    video.read();
    int redX = 0; 
    int redY = 0; 
    float redValue = 0; 
    video.loadPixels();
    int index = 0;
    //loops through all the pixels in order to find the most "red" value, pixels compared using HSB
    for (int y = 0; y < video.height; y++) {
      for (int x = 0; x < video.width; x++) {
        int pixelValue = video.pixels[index];
        float pixelRed = hue(pixelValue);
        if (pixelRed > redValue) {
          redValue = pixelRed;
          redY = y;
          redX = width-x;
        }
        index++;
      }
    }
    //calculate average X and Y value for the last 10 x&y's to increase stability
    cursorXvalues.append(redX);
    cursorYvalues.append(redY);
    if (cursorXvalues.size()>9) {
      cursorXvalues.remove(0);
    }
    if (cursorYvalues.size()>9) {
      cursorYvalues.remove(0);
    }
    int xtot=0;
    int ytot=0;
    for (int i=0; i<cursorXvalues.size ()-1; i++) {
      xtot+=cursorXvalues.get(i);
      ytot+=cursorYvalues.get(i);
    }
    //averaged X and Y values
    X=xtot/10;
    Y=ytot/10;
    colorMode(RGB);
  }
}

