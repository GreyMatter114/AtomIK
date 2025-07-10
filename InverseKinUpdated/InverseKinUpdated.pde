ArrayList<Segment> segments = new ArrayList<Segment>();
ArrayList<Slider> sliders = new ArrayList<Slider>();
PVector target;

Button addButton;
Button removeButton;

void setup() {
  size(800, 800);
  target = new PVector(mouseX, mouseY);

  addButton = new Button(20, 20, 30, 30, "+");
  removeButton = new Button(60, 20, 30, 30, "−");

  addSegment(100);  // start with one segment
}

void draw() {
  background(255);
  target.set(mouseX, mouseY);

  // UI
  addButton.display();
  removeButton.display();
  text("Segments: " + segments.size(), 20, 70);

  // Update sliders
  for (Slider s : sliders) {
    s.display();
    s.update();
  }

  // Inverse kinematics logic
  if (segments.size() > 0) {
    segments.get(segments.size() - 1).follow(target);

    for (int i = segments.size() - 2; i >= 0; i--) {
      segments.get(i).follow(segments.get(i + 1).a);
    }

    segments.get(0).setA(new PVector(width/2, height/2));

    for (int i = 1; i < segments.size(); i++) {
      segments.get(i).setA(segments.get(i - 1).b);
    }
  }

  // Draw arm
  for (Segment s : segments) {
    s.display();
  }
}

void mousePressed() {
  if (addButton.over(mouseX, mouseY)) addSegment(80);
  if (removeButton.over(mouseX, mouseY)) removeSegment();
  for (Slider s : sliders) s.mousePressed(mouseX, mouseY);
}

void mouseReleased() {
  for (Slider s : sliders) s.mouseReleased();
}

void addSegment(float length) {
  Segment s = new Segment(length);
  segments.add(s);
  sliders.add(new Slider(20, 100 + sliders.size() * 40, 120, 20, length));
}

void removeSegment() {
  if (segments.size() > 0) {
    segments.remove(segments.size() - 1);
    sliders.remove(sliders.size() - 1);
  }
}

// ---------------- Classes ----------------

class Segment {
  PVector a, b;
  float len;
  float angle;
  color c;

  Segment(float len) {
    this.len = len;
    this.a = new PVector(0, 0);
    this.b = new PVector(0, 0);
    this.angle = 0;
    this.c = color(random(100, 255), random(100, 255), random(100, 255));
  }

  void follow(PVector target) {
    PVector dir = PVector.sub(target, a);
    angle = dir.heading();
    dir.setMag(len);
    a = PVector.sub(target, dir);
    b = target.copy();
  }

  void setA(PVector pos) {
    a = pos.copy();
    b = new PVector(a.x + cos(angle) * len, a.y + sin(angle) * len);
  }

  void display() {
    stroke(c);
    strokeWeight(10);
    line(a.x, a.y, b.x, b.y);
  }
}

class Button {
  float x, y, w, h;
  String label;

  Button(float x, float y, float w, float h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
  }

  void display() {
    fill(200);
    stroke(0);
    rect(x, y, w, h);
    fill(0);
    textAlign(CENTER, CENTER);
    text(label, x + w/2, y + h/2);
  }

  boolean over(float mx, float my) {
    return mx >= x && mx <= x + w && my >= y && my <= y + h;
  }
}

class Slider {
  float x, y, w, h;
  float minVal = 20;
  float maxVal = 200;
  float value;
  boolean dragging = false;

  Slider(float x, float y, float w, float h, float val) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.value = val;
  }

  void display() {
    fill(220);
    rect(x, y, w, h);
    float handleX = map(value, minVal, maxVal, x, x + w);
    fill(100);
    ellipse(handleX, y + h/2, h, h);
    fill(0);
    textAlign(LEFT, CENTER);
    text(nf(value, 1, 1), x + w + 10, y + h/2);
  }

  void update() {
    if (dragging) {
      float m = constrain(mouseX, x, x + w);
      value = map(m, x, x + w, minVal, maxVal);
      if (sliders.indexOf(this) < segments.size()) {
        segments.get(sliders.indexOf(this)).len = value;
      }
    }
  }

  void mousePressed(float mx, float my) {
    float handleX = map(value, minVal, maxVal, x, x + w);
    if (dist(mx, my, handleX, y + h/2) < h) {
      dragging = true;
    }
  }

  void mouseReleased() {
    dragging = false;
  }
}
