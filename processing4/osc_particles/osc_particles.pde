import oscP5.*;
import netP5.*;
import codeanticode.syphon.*; // Import Syphon library

OscP5 oscP5;
float[][] keypoints; // Array to store the 33 body points (MediaPipe returns 33 points)
ArrayList<Particle> particles; // List to store particles
SyphonServer syphon; // Syphon server

void setup() {
  size(640, 480, P2D); // P2D renderer required for Syphon
  oscP5 = new OscP5(this, 12000); // OSC server on port 12000
  keypoints = new float[33][2];  // Each keypoint has X and Y coordinates
  particles = new ArrayList<Particle>();
  syphon = new SyphonServer(this, "Pose Particles"); // Create Syphon server with name "Pose Particles"
}

void draw() {
  // Set up the background and prepare the Syphon frame
  background(0);

  // Update and display all particles
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    p.display();

    // Remove particles that have expired
    if (p.isDead()) {
      particles.remove(i);
    }
  }

  // Add new particles for each detected keypoint
  for (int i = 0; i < keypoints.length; i++) {
    if (keypoints[i][0] > 0 && keypoints[i][1] > 0) { // Ensure valid keypoints
      float x = keypoints[i][0] * width;  // Convert normalized coordinates to screen space
      float y = keypoints[i][1] * height;
      for (int j = 0; j < 5; j++) { // Generate 5 particles per keypoint
        particles.add(new Particle(x, y));
      }
    }
  }

  // Send the frame to Syphon
  syphon.sendScreen();
}

void oscEvent(OscMessage msg) {
  // Handle OSC messages containing pose keypoints
  if (msg.checkAddrPattern("/pose")) {
    for (int i = 0; i < 33; i++) {
      keypoints[i][0] = msg.get(i * 2).floatValue();     // X coordinate
      keypoints[i][1] = msg.get(i * 2 + 1).floatValue(); // Y coordinate
    }
  }
}

// Particle class to represent individual particles
class Particle {
  float x, y;       // Current position
  float xOrigin, yOrigin; // Origin position
  float xSpeed, ySpeed;   // Speed in X and Y directions
  float radius;     // Maximum radius for particle movement
  int life;         // Particle lifespan in frames

  // Constructor to initialize the particle
  Particle(float x, float y) {
    this.xOrigin = x;
    this.yOrigin = y;
    this.x = x;
    this.y = y;
    this.radius = random(20, 50); // Random radius between 20 and 50 pixels
    this.xSpeed = random(-1, 1); // Random horizontal speed
    this.ySpeed = random(-1, 1); // Random vertical speed
    this.life = int(random(60, 120)); // Lifespan of the particle (60 to 120 frames)
  }

  // Update particle position and check limits
  void update() {
    // Update position
    x += xSpeed;
    y += ySpeed;

    // Constrain movement within the radius
    float distance = dist(x, y, xOrigin, yOrigin);
    if (distance > radius) {
      float angle = atan2(y - yOrigin, x - xOrigin);
      x = xOrigin + cos(angle) * radius;
      y = yOrigin + sin(angle) * radius;
    }

    // Reduce lifespan
    life--;
  }

  // Display the particle on the screen
  void display() {
    fill(255, map(life, 0, 120, 0, 255)); // White color with transparency based on life
    noStroke();
    ellipse(x, y, 5, 5); // Draw particle as a small circle
  }

  // Check if the particle is dead
  boolean isDead() {
    return life <= 0;
  }
}
