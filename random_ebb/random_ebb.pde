int[] hues;

void setup() {
  size(400, 400);
  frameRate(30);
  colorMode(HSB);
  hues = new int[width * height];
  int hue = 0;
  loadPixels();
  for (int i = 0; i < width * height; i++) {
    hue = int(random(0, 360));
    pixels[i] = color(hue, 255, 255);
    hues[i] = hue;
    hue = incHue(hue);
  }
  updatePixels();
}

void draw() {
  int start = millis();
  loadPixels();
  int hue;
  for (int i = 0; i < width * height; i++) {
    int delta;
    if ((frameCount % 60) < 10) {
      delta = int(random(1, 3));
    } else {
      delta = 2;
    }
    hue = incHue(hues[i], delta);
    hues[i] = hue;
    pixels[i] = color(hue, 255, 255);
  }
  updatePixels();  
  int end = millis();
  if (end - start > 1000 / frameRate) {
    print("Frame took too long");  
  }
}

int incHue(int hue) {
  return incHue(hue, 1);
}

int incHue(int hue, int delta) {
  return (hue + delta) & 0xFF; 
}
