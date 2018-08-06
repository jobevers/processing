/*
Draws a bunch of balls, each randomly placed, with a random velocity and a random blue-ish color.
When the ball goes off the screen a new one is randomly created to take its place.
*/
import java.util.LinkedList;
import java.util.Iterator;

LinkedList<Vector> vs;
float velocity;
Point base;
int nBalls;
int nBallsPerStep;
float hue;

void setup() {
  size(800, 600);
  frameRate(30);
  colorMode(HSB, 360, 100, 100);
  velocity = 1;
  nBalls = int(sqrt(height * width));
  hue = random(0, 360);
  base = new Point(width / 2, height / 2);
  nBallsPerStep = int(nBalls / ((height / 2) / velocity));
  vs = new LinkedList<Vector>();
  for(int i=0; i<nBallsPerStep; i++) {
     vs.add(randomVector(base, hue));
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

Vector randomVector(Point p, float hue) {
  return new Vector(p.x, p.y, random(0, 2*PI), velocity, color(hue, 100, 100));
}

void draw() {
  int start = millis();
  clear();
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
  base.x = reflect(base.x + random(-2, 2), 0, width);
  base.y = reflect(base.y + random(-2, 2), 0, height);
  hue = (hue + 1) % 360;
  for(int i = 0; i < removed; i++){
    vs.add(randomVector(base, hue)); 
  }
  if (vs.size() < nBalls - nBallsPerStep) {
    for(int i=0; i<nBallsPerStep; i++) {
       vs.add(randomVector(base, hue));
    }
  }
  int end = millis();
  if (end - start > 1000 / frameRate) {
    print("Frame took too long");  
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
     this.dx = v*sin(theta);
     this.dy = v*cos(theta);
     this.c = c;
   }
   
   void update() {
     this.x += this.dx;
     this.y += this.dy;
   }
   
   void draw() {
     fill(this.c);
     stroke(this.c);
     ellipse(this.x, this.y, 7, 7);
   }
}
