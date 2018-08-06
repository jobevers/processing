import com.google.gson.Gson;
import com.google.gson.JsonParser;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import java.io.FileReader;
import java.io.FileNotFoundException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

class Point {
  float x;
  float y;

  Point(float x, float y) {
    this.x = x;
    this.y = y;
  }

  float getX() { 
    return this.x;
  }
  float getY() { 
    return this.y;
  }
}

void setup() {
  size(196, 127);
  colorMode(HSB);
  background(255);
  try {
    String layoutJson = readFile(
      "/Users/jobevers/projects/rayactivation/Processing/layout/layout.json", StandardCharsets.UTF_8);
    JsonArray arr = new JsonParser().parse(layoutJson).getAsJsonArray();
    OPC opc = new OPC(this, "127.0.0.1", 7890);
    ArrayList<Point> points = new ArrayList<Point>();
    float min_x = Float.MAX_VALUE;
    float min_y = Float.MAX_VALUE;
    float max_x = 0;
    float max_y = 0;
    for (int i=0; i<arr.size(); i++) {
      JsonObject o = arr.get(i).getAsJsonObject();
      JsonArray point = o.get("point").getAsJsonArray();
      print(point.get(0), point.get(1));
      Point pt = new Point(point.get(0).getAsFloat(), point.get(1).getAsFloat());
      points.add(pt); 
      min_x = min(pt.x, min_x);
      min_y = min(pt.y, min_y);
      max_x = max(pt.x, max_x);
      max_y = max(pt.y, max_y);
    }
    float layout_width = max_x - min_x;
    float layout_height = max_y - min_y;
    for (int i=0; i<points.size(); i++) {
      Point pt = points.get(i);
      int x = int((pt.x - min_x) * (width - 1) / layout_width);
      int y = int((pt.y - min_y) * (height - 1) / layout_height);
      assert 0 <= x && x < width;
      assert 0 <= y && y < height;
      opc.led(i, x, y);
    }
    opc.showLocations(false);
  }
  catch (IOException e) {
    print("File not found");
    exit();
  }
}

int hue = 128;
void draw() {
  background(color(hue, 255, 255));
  hue = (hue + 1) & 0x0000FF; 
}

static String readFile(String path, Charset encoding) 
  throws IOException 
{
  byte[] encoded = Files.readAllBytes(Paths.get(path));
  return new String(encoded, encoding);
}
