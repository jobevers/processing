/*
Draws a bunch of balls, each randomly placed, with a random velocity and a random blue-ish color.
When the ball goes off the screen a new one is randomly created to take its place.
*/
import java.util.LinkedList;
import java.util.Iterator;

LinkedList<Vector> vs;

void setup() {
  size(200, 200);
  frameRate(30);
  colorMode(HSB, 360, 100, 100);
  vs = new LinkedList<Vector>();
  for(int i=0; i<300; i++) {
     vs.add(randomVector());
  }
}

Vector randomVector() {
  //
  return new Vector(random(0, 200), random(0, 200), random(0, 2*PI), random(.2, 3), color(random(180, 270), random(70, 100), random(70, 100)));
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
    if (v.x < 0 || v.y < 0 || v.x > 200 || v.y > 200) {
        iter.remove();
        removed += 1;
    }
  }
  for(int i = 0; i < removed; i++){
    vs.add(randomVector()); 
  }
  int end = millis();
  if (end - start > 1000 / frameRate) {
    print("Frame took too long");  
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
