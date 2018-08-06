// This works, but is slow
import java.util.ArrayDeque;

ArrayDeque<Circle> circles;
int hue;
Point center;

void setup() {
  size(200, 200);
  frameRate(30);
  colorMode(HSB);
  circles = new ArrayDeque<Circle>();
  hue = 0;
  center = new Point(100, 100);
}

void draw() {
  int start = millis();
  for(Circle c : circles) {
    c.draw();  
  }
  center = walk(center);
  Point b = new Point(center.x + 5, center.y + 5);
  circles.add(new Circle(center, color(hue, 255, 255)));
  circles.add(new Circle(b, color(hue, 255, 255)));
  if (circles.size() > 50) {
    circles.remove();  
  }
  hue = (hue + 1 & 0xFF);
  int end = millis();
  if (end - start > 1000 / frameRate) {
    print("Frame took too long");  
  }
}

Point walk(Point p) {
  return new Point(p.x + random(-2, 2), p.y + random(-2, 2));  
}

class Circle {
  Point center;
  float diameter;
  color c;
  
  Circle(Point center, color c) {
    this.center = center;
    this.c = c;
    this.diameter = 1;
  }
  
  void draw() {
    this.diameter += 5;
    fill(this.c);
    noStroke();
    ellipse(center.x, center.y, this.diameter, this.diameter);
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
