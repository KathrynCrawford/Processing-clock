

FractalRoot pentagon;
float _strutFactor = 0.2;
int _maxlevels = 4;
int _numSides = 4;

void setup() {
  size(1000, 900); 
  smooth();
  pentagon = new FractalRoot(0);
  pentagon.drawShape();
}

void draw() {
  background(0);
    if (hour() < 13){
  } else if (hour() >= 13) {
    _numSides = (hour()-12*2);
  } 
    pentagon = new FractalRoot(second());
  pentagon.drawShape();
}    


//================================================ objects

class Point {
  float x, y;
  Point(float ex, float why) {
    x = ex; 
    y = why;
  }
}


class FractalRoot {
  Point[] pointArr = {
  };
  Branch rootBranch;

  FractalRoot(float startAngle) {
    float centX = width/2;
    float centY = height/2;
    float angleStep = 360.0f/_numSides;                  
    for (float i = 0; i<360; i+=angleStep) {
      float x = centX + (400 * cos(radians(startAngle + i)));
      float y = centY + (400 * sin(radians(startAngle + i)));
      pointArr = (Point[])append(pointArr, new Point(x, y));
    }
    rootBranch = new Branch(0, 0, pointArr);
  }

  void drawShape() {
    rootBranch.drawMe();
  }
}


class Branch {
  int level, num;
  Point[] outerPoints = {
  };
  Point[] midPoints = {
  };
  Point[] projPoints = {
  };
  Branch[] myBranches = {
  };

  Branch(int lev, int n, Point[] points) {
    level = lev;
    num = n;
    outerPoints = points;
    midPoints = calcMidPoints();
    projPoints = calcStrutPoints();

    // next generation
    if ((level+1) < _maxlevels) {
      Branch childBranch = new Branch(level+1, 0, projPoints);
      myBranches = (Branch[])append(myBranches, childBranch);

      // fill other pentagons
      for (int k = 0; k < outerPoints.length; k++) {
        int nextk = k-1;
        if (nextk < 0) { 
          nextk += outerPoints.length;
        }
        Point[] newPoints = {  
          projPoints[k], midPoints[k], outerPoints[k], midPoints[nextk], projPoints[nextk]
        };
        childBranch = new Branch(level+1, k+1, newPoints);
        myBranches = (Branch[])append(myBranches, childBranch);
      }
    }
  }

  Point[] calcMidPoints() {
    Point[] mpArray = new Point[outerPoints.length];
    for (int i = 0; i < outerPoints.length; i++) {
      int nexti = i+1;
      if (nexti == outerPoints.length) { 
        nexti = 0;
      }
      Point thisMP = calcMidPoint(outerPoints[i], outerPoints[nexti]);
      mpArray[i] = thisMP;
    } 
    return mpArray;
  }

  Point[] calcStrutPoints() {
    Point[] strutArray = new Point[midPoints.length];
    for (int i = 0; i < midPoints.length; i++) {
      int nexti = i+3;
      if (nexti >= midPoints.length) { 
        nexti -= midPoints.length;
      }
      Point thisSP = calcProjPoint(midPoints[i], outerPoints[nexti]);  
      // draw from midpoint to opposite point on outer shape
      strutArray[i] = thisSP;
    } 
    return strutArray;
  }

  Point calcMidPoint(Point end1, Point end2) {
    float mx, my;
    if (end1.x > end2.x) {
      mx = end2.x + ((end1.x - end2.x)/2);
    } 
    else {
      mx = end1.x + ((end2.x - end1.x)/2);
    }
    if (end1.y > end2.y) {
      my = end2.y + ((end1.y - end2.y)/2);
    } 
    else {
      my = end1.y + ((end2.y - end1.y)/2);
    }
    return new Point(mx, my);
  }


  Point calcProjPoint(Point mp, Point op) {
    float px, py;
    // trig triangle, get opposite and adjacent
    float adj, opp;    
    if (op.x > mp.x) { 
      opp = op.x - mp.x;
    } 
    else {
      opp = mp.x - op.x;
    }
    if (op.y > mp.y) {
      adj = op.y - mp.y;
    } 
    else {
      adj = mp.y - op.y;
    }
    // project point
    if (op.x > mp.x) { 
      px = mp.x + (opp * _strutFactor);
    } 
    else {
      px = mp.x - (opp * _strutFactor);
    }
    if (op.y > mp.y) {
      py = mp.y + (adj * _strutFactor);
    } 
    else {
      py = mp.y - (adj * _strutFactor);
    }  
    return new Point(px, py);
  }


  void drawMe() {
    
    if(minute() < 16){
      stroke(255,0,0,(minute()*15));
    } else if(minute() > 15 && minute() < 31){
      stroke(255,0,255,((minute()-15)*15));
    } else if(minute() > 30 && minute() < 46){
      stroke(0,0,255,((minute()-30)*15));
    } else if(minute() > 45 && minute() < 61){
      stroke(0,255,255,((minute()-45)*15));
    }
    int myWeight = _maxlevels - level;
    strokeWeight(myWeight); 
    // draw outer shape
    for (int i = 0; i < outerPoints.length; i++) {
      int nexti = i+1;
      if (nexti == outerPoints.length) { 
        nexti = 0;
      }
      line(outerPoints[i].x, outerPoints[i].y, outerPoints[nexti].x, outerPoints[nexti].y);
    } 

    // draw children
    for (int k = 0; k < myBranches.length; k++) {
      myBranches[k].drawMe();
    }
  }
}

