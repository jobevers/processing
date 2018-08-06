/*
Draws a bunch of balls, each randomly placed, with a random velocity and a random blue-ish color.
 When the ball goes off the screen a new one is randomly created to take its place.
 */
import java.util.List;
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
Vector[] vectors;

void setup() {
  size(200, 200);
  frameRate(30);
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
  List<Point> targets;

  PointWithTrail() {
    this.targets = new ArrayList();
    for (int y = 0; y<height; y++) {
      this.targets.add(new Point(0, y));
      this.targets.add(new Point(width-1, y));
    }
    for (int x = 1; x<width-1; x++) {
      this.targets.add(new Point(x, 0));
      this.targets.add(new Point(x, height-1));
    }
    assert targets.size() == 2*height + 2*(width) - 4;
    hue = 0; //random(0, 360);
    base = new Point(width / 2, height / 2);
    vs = new LinkedList<Vector>();
    addNewVectors();
  }

  void addNewVectors() {
    for (Point target : targets) {
      float dy = target.y - base.y;
      float dx = target.x - base.x;
      // TODO: use slope
      float theta = atan2(dy, dx);
      vs.add(randomVector(base, hue, theta));
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
      if (v.x < -1 || v.y < -1 || v.x >= width + 1 || v.y >= height + 1) {
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
    walk();
    hue = (hue + 1) % 360;
    addNewVectors();
  }

  void walk() {
    base.x = reflect(base.x + random(-2, 2), 0, width);
    base.y = reflect(base.y + random(-2, 2), 0, height);
  }
}

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
