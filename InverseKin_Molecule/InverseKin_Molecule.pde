ArrayList<Joint> joints = new ArrayList<Joint>();
PVector target;
float stiffness = 1.0; // attraction strength

void setup() {
  size(800, 600);
  target = new PVector(width/2, height/2);

  // Input joint lengths
  float[] lengths = {40, 30, 40, 30, 40, 30};  // you can make this dynamic
  PVector origin = new PVector(width/2, height/2);

  // Create joints as particles
  joints.add(new Joint(origin.copy(), 0));
  for (float len : lengths) {
    Joint prev = joints.get(joints.size() - 1);
    PVector pos = prev.pos.copy().add(len, 0);
    joints.add(new Joint(pos, len));
  }
}

void draw() {
  background(255);

  // Move target with mouse
  target.set(mouseX, mouseY);

  // Inverse Kinematics via molecular-style attraction
  applyForces();
  updateJoints();

  // Draw arm
  stroke(0);
  fill(0);
  for (int i = 0; i < joints.size() - 1; i++) {
    Joint a = joints.get(i);
    Joint b = joints.get(i + 1);
    line(a.pos.x, a.pos.y, b.pos.x, b.pos.y);
    ellipse(a.pos.x, a.pos.y, 6, 6);
  }
  // Draw end effector
  Joint end = joints.get(joints.size() - 1);
  ellipse(end.pos.x, end.pos.y, 10, 10);
  fill(255, 0, 0);
  ellipse(target.x, target.y, 10, 10);
}

void applyForces() {
  // End effector feels attraction toward the target
  Joint end = joints.get(joints.size() - 1);
  PVector attraction = PVector.sub(target, end.pos).mult(stiffness);
  end.pos.add(attraction);
}

void updateJoints() {
  // Backward pass: preserve lengths like bond constraints
  for (int i = joints.size() - 2; i >= 0; i--) {
    Joint current = joints.get(i);
    Joint next = joints.get(i + 1);
    float len = next.length;

    PVector dir = PVector.sub(current.pos, next.pos).normalize().mult(len);
    current.pos = PVector.add(next.pos, dir);
  }

  // Forward pass: anchor the base
  joints.get(0).pos.set(width/2, height/2);
  for (int i = 1; i < joints.size(); i++) {
    Joint prev = joints.get(i - 1);
    Joint current = joints.get(i);
    float len = current.length;

    PVector dir = PVector.sub(current.pos, prev.pos).normalize().mult(len);
    current.pos = PVector.add(prev.pos, dir);
  }
}

class Joint {
  PVector pos;
  float length;

  Joint(PVector pos, float len) {
    this.pos = pos;
    this.length = len;
  }
}
