/*
Draws a bunch of balls, each randomly placed, with a random velocity and a random blue-ish color.
 When the ball goes off the screen a new one is randomly created to take its place.
 */
import java.util.List;
import java.util.LinkedList;
import java.util.Iterator;

import org.hsluv.HUSLColorConverter;

//LinkedList<Vector> vs;
float velocity;
//Point base;
//int nBalls;
//int nBallsPerStep;
//float hue;
//Triangle wave;
//float targetY = 0;
LinkedList<PointWithTrail> trails;
Vector[] vectors;

void setup() {
  size(200, 200);
  frameRate(30);
  //colorMode(RGB, 255, 255, 255);
  colorMode(HSB, 360, 100, 100);
  velocity = 1;
  vectors = new Vector[(height + 2)*(width + 2)];
  trails = new LinkedList<PointWithTrail>();
  trails.add(new PointWithTrail());
}

void draw() {
  int start = millis();
  clear();
  for (PointWithTrail trail : trails) {
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

class Slope {
  private float theta;
  float dx;
  float dy;

  Slope(float theta) {
    setTheta(theta);
  }

  void setTheta(float theta) {
    this.theta = theta;
    this.dx = cos(theta);
    this.dy = sin(theta);
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
  // Dammit, the HSLUV looks terrible :/
  //double[] rgb = HUSLColorConverter.hsluvToRgb(new double[]{hue, 100, 50});
  //print(rgb[0], rgb[1], rgb[2]);
  //int x = 1/0;
  //return new Vector(p.x, p.y, theta, velocity, color((int)(rgb[0] * 255), (int)(rgb[1]*255), (int)(rgb[2]*255)));
  return new Vector(p.x, p.y, theta, velocity, color(hue, 100, 100));
}

class PointWithTrail {
  LinkedList<Vector> vs;
  float length;
  Point base;
  Slope slope;
  int nBalls;
  int nBallsPerStep;
  float hue;
  Triangle wave;

  PointWithTrail() {
    hue = 0; //random(0, 360);
    base = new Point(width / 2, height / 2);
    slope = new Slope(0);
    length = 75;
    vs = new LinkedList<Vector>();
    addNewVectors();
  }

  void addNewVectors() {
    float startingTheta = slope.theta + PI/2;
    Point start = new Point(base.x + length / 2 * slope.dx, base.y + length / 2 * slope.dy);
    Point end = new Point(base.x - length / 2 * slope.dx, base.y - length / 2 * slope.dy);
    for (float i=-length / 2; i < length / 2; i+=.5) {
      Point pt = new Point(base.x + i * slope.dx, base.y + i * slope.dy);
      vs.add(randomVector(pt, hue, startingTheta));
      vs.add(randomVector(pt, hue, startingTheta + PI));
    }
    for (float offset=0; offset<PI; offset+=PI/180) {
      vs.add(randomVector(end, hue, startingTheta + offset));
      vs.add(randomVector(start, hue, startingTheta + PI + offset));
      //break;
    }
  }

  void draw() {
    background(0);
    // Be slightly bigger than the actual screen so that
    // interpolation of missing pixels at the edge is easier
    vectors = new Vector[(height + 2)*(width+2)];
    Iterator<Vector> iter = vs.iterator();
    while (iter.hasNext()) {
      Vector v = iter.next();
      v.update();
      v.draw();
      // The vector coordinates are in terms of the screen
      // And we want to keep one extra vector around the edge
      if ((v.x < -1 && v.dx < 0) ||
          (v.y < -1 && v.dy < 0) ||
          (v.x >= width + 1 && v.dx > 0) ||
          (v.y >= height + 1 && v.dy > 0)) {
        iter.remove();
      }
    }
    loadPixels();
    for (int x = 0; x<width; x++) {
      for (int y = 0; y<height; y++) {
        int idx = y*width + x;
        pixels[idx] = interpolate(x, y);
      }
    }
    updatePixels();
    
    //Point start = new Point(base.x + length / 2 * slope.dx, base.y + length / 2 * slope.dy);
    //Point end = new Point(base.x - length / 2 * slope.dx, base.y - length / 2 * slope.dy);
    //stroke(color(0, 0, 0));
    //line(start.x, start.y, end.x, end.y);
    //fill(color(0, 0, 0));
    //ellipse(start.x, start.y, 1, 1);
    //fill(color(0, 0, 0));
    //ellipse(end.x, end.y, 1, 1);
    
    walk();
    hue = (hue + 1) % 360;
    addNewVectors();
  }


  void walk() {
    base.x = reflect(base.x + baseXSpeed, 0, width);
    base.y = reflect(base.y + baseYSpeed, 0, height);
    slope.setTheta(slope.theta + thetaSpeed);
    length = 50;//reflect(length + lengthSpeed, 20, 150);
    baseXSpeed = reflect(baseXSpeed + random(-.02, .02) + ( width / 2 - base.x) * 0.00005, -.2, .2);
    baseYSpeed = reflect(baseYSpeed + random(-.02, .02) + (height / 2 - base.y) * 0.00005, -.2, .2);
    // This is not enough rotation change. I'd like to have something that changes direction
    // fairly often, but doesn't spend much time around zero
    //thetaSpeed = reflect(thetaSpeed + random(-.0005, .0005), -.02, .02);
    thetaSpeed = 0.6;// * sin(frameCount * PI / (12*frameRate));
    lengthSpeed = reflect(lengthSpeed + random(-.01, .01), -1, 1);
    // There is a relationship between length and maximum rotation speed
    // Lenght : Max Speed
    // 150 : 0.01
    // 100 : 0.02
    //  50 : 0.04
    //  25 : 0.1
  }
}

Point center;
float baseXSpeed = 0;
float baseYSpeed = 0;
float thetaSpeed = 0;
float lengthSpeed = 0;

private static final int[][] NEIGHBORS = {
  {-1, 0}, { 0, -1}, { 0, 1}, { 1, 0}, 
  { 1, 1}, {-1, 1}, { 1, -1}, {-1, -1}, 
  {-2, 0}, { 2, 0}, { 0, -2}, { 0, 2}, 
  {-2, 1}, {-2, -1}, { 2, -1}, { 2, 1}, 
  { 1, 2}, { 1, 2}
};

IntList getLevelOrder(int level) {
  IntList result = new IntList();
  for (int i=-level; i<=level; i++) {
    result.append(i);
  }
  return result;
  //result.append(0);
  //int offset = level;
  //while (offset > 0) {
  //  result.append(offset);
  //  offset *= -1;
  //  if (offset >= 0) {
  //    offset--;
  //  }
  //}
  //return result;
}

List<Point> getNeighbors(int level) {
  assert level >= 1;
  List<Point> result = new ArrayList<Point>();
  for (int x : getLevelOrder(level)) {
    for (int y : getLevelOrder(level)) {
      if (abs(x) != level && abs(y) != level) {
        continue;
      }
      result.add(new Point(x, y));
    }
  }
  //if (level > 1) { print(level, "\n"); }
  return result;
}

color interpolate(int x, int y) {
  x = x + 1;
  y = y + 1;
  //handle the common case (no interpolation) first
  int idx = y*(width+2) + x;
  Vector v = vectors[idx];
  if (v != null) {
    return v.c;
  }
  int level = 1;
  while (level <= 1) {
    for (Point p : getNeighbors(level)) {
      int xx = x + (int)p.x;
      int yy = y + (int)p.y;
      if (xx < 0 || yy < 0 || xx >= width + 2 || yy >= height + 2) {
        continue;
      }
      idx = yy*(width+2) + xx;
      v = vectors[idx];
      if (v != null) {
        return v.c;
      }
    }
    level++;
  }
  return color(0);
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
    if (this.x < -1 || this.y < -1 || this.x >= width + 1 || this.y >= height + 1) {
      return;
    }
    // the vectors array is offset one, so our index needs to change
    vectors[int(this.y + 1)*(width + 2) + int(this.x + 1)] = this;
  }
}
