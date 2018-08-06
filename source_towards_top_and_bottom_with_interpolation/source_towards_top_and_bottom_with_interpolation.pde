/*
Draws a bunch of balls, each randomly placed, with a random velocity and a random blue-ish color.
When the ball goes off the screen a new one is randomly created to take its place.
*/
import java.util.LinkedList;
import java.util.Iterator;

//LinkedList<Vector> vs;
float velocity;
//Point base;
//int nBalls;
//int nBallsPerStep;
//float hue;
//Triangle wave;
//float targetY = 0;
LinkedList<PointWithTrail> trails;

void setup() {
  size(200, 200);
  frameRate(30);
  colorMode(HSB, 360, 100, 100);
  velocity = 1;
  trails = new LinkedList<PointWithTrail>();
  trails.add(new PointWithTrail());
}

void draw() {
  int start = millis();
  clear();
  for(PointWithTrail trail : trails) {
    trail.draw();
  }
  int end = millis();
  if (end - start > 1000 / frameRate) {
    print("Frame took too long");  
  }
}

class Point {
  float x;
  float y;
  Point(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

interface Wave {
  float step();  
}

class Triangle implements Wave {
  float lastY;
  float dy;
  float minY;
  float maxY;
  
  Triangle(float dy, float minY, float maxY) {
    this.dy = dy;
    this.minY = minY;
    this.maxY = maxY;
    this.lastY = minY;
  }
  
  float step() {
    lastY += dy;
    if (lastY > maxY) {
      lastY = maxY - (lastY - maxY);
      dy *= -1;
    } else if (lastY < minY) {
      lastY = minY + (minY - lastY); 
      dy *= -1;
    }
    return lastY;  
  }
}

Vector randomVector(Point p, float hue, float theta) {
  return new Vector(p.x, p.y, theta, velocity, color(hue, 100, 100));
}

class PointWithTrail {
  LinkedList<Vector> vs;
  Point base;
  int nBalls;
  int nBallsPerStep;
  float hue;
  Triangle wave;
  FloatList targetYs;
  
  PointWithTrail() {
    this.targetYs = new FloatList();
    targetYs.append(0);
    targetYs.append(height);
    wave = new Triangle(1, 0, width);
    nBalls = int(sqrt(height * width));
    hue = 0; //random(0, 360);
    base = new Point(width / 2, height / 2);
    nBallsPerStep = width / 1;
    vs = new LinkedList<Vector>();
    for(int i=0; i<nBallsPerStep; i++) {
       float targetX = wave.step();
       for (float targetY : targetYs) {
         float dy = targetY - base.y;
         float dx = targetX - base.x;
         float theta = atan2(dy, dx);
         vs.add(randomVector(base, hue, theta));
       }
    }    
  }
  
  void draw() {
    loadPixels();
    Iterator<Vector> iter = vs.iterator();
    int removed = 0;
    int n = 0;
    while (iter.hasNext()) {
      n++;
      Vector v = iter.next();
      v.update();
      v.draw();
      if (v.x < 0 || v.y < 0 || v.x > width || v.y > height) {
          iter.remove();
          removed += 1;
      }
    }
    updatePixels();
    base.x = reflect(base.x + random(-2, 2), 0, width);
    base.y = reflect(base.y + random(-2, 2), 0, height);
    hue = (hue + 1) % 360;
    for(int i=0; i<nBallsPerStep; i++) {
       float targetX = wave.step();
       for (float targetY : targetYs) {
         float dy = targetY - base.y;
         float dx = targetX - base.x;
         float theta = atan2(dy, dx);
         vs.add(randomVector(base, hue, theta));
       }
    }    
  }
}

float reflect(float val, float min, float max) {
   if (val < min) {
     return min + (min - val);
   } else if (val > max) {
     return max - (val - max);
   } else {
      return val;
   }
}


class Vector {
   float x;
   float y;
   float dx;
   float dy;
   color c;
   
   Vector(float x, float y, float theta, float v, color c) {
     this.x = x;
     this.y = y;
     this.dx = v*cos(theta);
     this.dy = v*sin(theta);
     this.c = c;
   }
   
   void update() {
     this.x += this.dx;
     this.y += this.dy;
   }
   
   void draw() {
     if (this.x < 0 || this.y < 0 || this.x >= width || this.y >= height) {
       return;  
     }
     pixels[int(this.y)*width + int(this.x)] = this.c;
   }
}
