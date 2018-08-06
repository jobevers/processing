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
import java.util.List;
import java.util.Map;
import org.javatuples.Pair;

int hue = 128;

void setup() {
  // 198, 109 is the smallest size we can use. Check layout/parse_layout.py for the calculation
  size(198, 109);
  colorMode(HSB);
  background(255);
  try {
    // TODO: read this in from a command line argument
    setupOpc("/Users/jobevers/projects/rayactivation/Processing/layout/layout.json");
  }
  catch (IOException e) {
    print("File not found");
    exit();
  }
}

void draw() {
  loadPixels();
  for (int x=0; x<width; x++) {
    for (int y=0; y<height; y++) {
      int h = (hue + x + y) & 0x0000FF;
      pixels[x + width*y] = color(  h, 255, 255);
    }
  }
  updatePixels();
  hue = (hue + 1) & 0x0000FF;
}

static String readFile(String path, Charset encoding) 
  throws IOException 
{
  byte[] encoded = Files.readAllBytes(Paths.get(path));
  return new String(encoded, encoding);
}

/* Parse the json layout file and create the corresponding OPC clients.
 * 
 * The layout file needs to be an array of objects. Each object contains
 * the keys: host, port, point
 * [{host: "127.0.0.1", port: 7890, point: [2, 3, 0]}, ...]
 * The order of the points is important and needs to correspond to the ordering
 * of the pixels on each OPC server.
 */
void setupOpc(String jsonLayoutFile) throws IOException {
    String layoutJson = readFile(jsonLayoutFile, StandardCharsets.UTF_8);
    JsonArray arr = new JsonParser().parse(layoutJson).getAsJsonArray();

    HashMap<Pair<String, Integer>, List<Point>> pointsByHostPort = new HashMap<Pair<String, Integer>, List<Point>>();
    float min_x = Float.MAX_VALUE;
    float min_y = Float.MAX_VALUE;
    float max_x = 0;
    float max_y = 0;
    for (int i=0; i<arr.size(); i++) {
      JsonObject o = arr.get(i).getAsJsonObject();
      Pair<String, Integer> hp = new Pair<String, Integer>(o.get("host").getAsString(), o.get("port").getAsInt());
      // TODO: use compute/computeIfAbsent
      if (!pointsByHostPort.containsKey(hp)) {
        pointsByHostPort.put(hp, new ArrayList<Point>());
      }
      List<Point> points = pointsByHostPort.get(hp);
      JsonArray point = o.get("point").getAsJsonArray();
      Point pt = new Point(point.get(0).getAsFloat(), point.get(1).getAsFloat());
      points.add(pt); 
      min_x = min(pt.x, min_x);
      min_y = min(pt.y, min_y);
      max_x = max(pt.x, max_x);
      max_y = max(pt.y, max_y);
    }
    float layout_width = max_x - min_x;
    float layout_height = max_y - min_y;
    HashMap<Pair<String, Integer>, OPC> opcByHostPort = new HashMap<Pair<String, Integer>, OPC>();
    for (Pair<String, Integer> hp : pointsByHostPort.keySet()) {
      opcByHostPort.put(hp, new OPC(this, hp.getValue0(), hp.getValue1()));
    }
    for (Map.Entry<Pair<String, Integer>, List<Point>> item : pointsByHostPort.entrySet()) {
      OPC opc = opcByHostPort.get(item.getKey());
      List<Point> points = item.getValue();
      for (int i=0; i<points.size(); i++) {
        Point pt = points.get(i);
        int x = int((pt.x - min_x) * (width - 1) / layout_width);
        int y = int((pt.y - min_y) * (height - 1) / layout_height);
        assert 0 <= x && x < width;
        assert 0 <= y && y < height;
        opc.led(i, x, y);
      }
      opc.showLocations(true);
    }  
}

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
