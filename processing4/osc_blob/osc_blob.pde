import oscP5.*;
import netP5.*;
import codeanticode.syphon.*; // Import Syphon library

// OSC and keypoints
OscP5 oscP5;
float[] keypoints = new float[33 * 2]; // Assuming 33 landmarks, each with x and y

SyphonServer syphon; // Syphon server

void setup() {
  size(800, 800, P2D); // Canvas size
  oscP5 = new OscP5(this, 12000); // Listening on port 12000
  println("Waiting for OSC messages on port 12000...");
  strokeCap(ROUND); // Rounded line ends
  noFill(); // Disable fill for shapes
  
  syphon = new SyphonServer(this, "Pose Blob"); // Create Syphon server with name "Pose Blob"
}

void draw() {
  background(0); // Black background
  stroke(255);   // White stroke
  strokeWeight(20); // Default stroke thickness

  // Draw head
  drawHead();

  // Draw torso
  drawTorso();

  // Draw limbs
  drawLimbs();
  
  // Draw hands
  drawHands();
  
  // Send the frame to Syphon
  syphon.sendScreen();
}

void drawHead() {
  // Head points: nose (0), left ear (3), right ear (4)
  if (isValidLandmark(0) && isValidLandmark(3) && isValidLandmark(4)) {
    // Nose coordinates (center of ellipse)
    float noseX = keypoints[0 * 2] * width;
    float noseY = keypoints[0 * 2 + 1] * height;

    // Distance between ears to define width
    float earDist = dist(
      keypoints[3 * 2] * width, keypoints[3 * 2 + 1] * height,
      keypoints[4 * 2] * width, keypoints[4 * 2 + 1] * height
    );

    // Head height (1/3 greater than width)
    float headWidth = earDist; // Horizontal limit: distance between ears
    float headHeight = headWidth * 1.33; // Vertical limit: 1/3 larger than the width

    // Draw the filled ellipse
    fill(255);
    noStroke();
    ellipse(noseX, noseY, 4*headWidth, 4*headHeight);
  }
}

void drawTorso() {
  // Torso points: left shoulder (11), right shoulder (12), left hip (23), right hip (24)
  if (isValidLandmark(11) && isValidLandmark(12) && isValidLandmark(23) && isValidLandmark(24)) {
    // Calculate the center of the torso
    float centerX = (keypoints[11 * 2] + keypoints[12 * 2] + keypoints[23 * 2] + keypoints[24 * 2]) / 4 * width;
    float centerY = (keypoints[11 * 2 + 1] + keypoints[12 * 2 + 1] + keypoints[23 * 2 + 1] + keypoints[24 * 2 + 1]) / 4 * height;

    // Define expansion factor (e.g., 5% larger)
    float expansionFactor = 1.10; // Adjust to 1.10 for 10%

    // Calculate expanded coordinates
    float[] expandedX = new float[4];
    float[] expandedY = new float[4];
    int[] torsoIndices = {11, 23, 24, 12}; // Points for the torso in sequence

    for (int i = 0; i < torsoIndices.length; i++) {
      int idx = torsoIndices[i];
      float originalX = keypoints[idx * 2] * width;
      float originalY = keypoints[idx * 2 + 1] * height;

      // Expand the point outward relative to the center
      expandedX[i] = centerX + (originalX - centerX) * expansionFactor;
      expandedY[i] = centerY + (originalY - centerY) * expansionFactor;
    }

    // Draw the expanded torso
    fill(255); // White fill
    noStroke(); // No stroke
    beginShape();
    for (int i = 0; i < expandedX.length; i++) {
      vertex(expandedX[i], expandedY[i]);
    }
    endShape(CLOSE);
  }
}


void drawLimbs() {
  // Draw limbs with thick strokes
  drawLimb(11, 13); // Left upper arm
  drawLimb(13, 15); // Left lower arm
  drawLimb(12, 14); // Right upper arm
  drawLimb(14, 16); // Right lower arm
  drawLimb(23, 25); // Left upper leg
  drawLimb(25, 27); // Left lower leg
  drawLimb(24, 26); // Right upper leg
  drawLimb(26, 28); // Right lower leg
}

void drawLimb(int startIdx, int endIdx) {
  if (isValidLandmark(startIdx) && isValidLandmark(endIdx)) {
    float x1 = keypoints[startIdx * 2] * width;
    float y1 = keypoints[startIdx * 2 + 1] * height;
    float x2 = keypoints[endIdx * 2] * width;
    float y2 = keypoints[endIdx * 2 + 1] * height;
    stroke(255);
    strokeWeight(60); // Thicker stroke for limbs
    line(x1, y1, x2, y2);
  }
}

void drawHands() {
  // Draw left hand
  drawHand(19, 15); // Left hand index (center), left wrist (reference)
  
  // Draw right hand
  drawHand(20, 16); // Right hand index (center), right wrist (reference)
}

void drawHand(int handIdx, int wristIdx) {
  // Ensure the landmarks are valid
  if (isValidLandmark(handIdx) && isValidLandmark(wristIdx)) {
    // Coordinates of the hand index (center of the ellipse)
    float handX = keypoints[handIdx * 2] * width;
    float handY = keypoints[handIdx * 2 + 1] * height;

    // Coordinates of the wrist (used to calculate size)
    float wristX = keypoints[wristIdx * 2] * width;
    float wristY = keypoints[wristIdx * 2 + 1] * height;

    // Calculate the size of the ellipse based on the distance between wrist and hand index
    float size = dist(handX, handY, wristX, wristY); // Multiply to scale the ellipse

    // Draw the ellipse
    fill(255); // White fill
    noStroke(); // No stroke
    ellipse(handX, handY, size, size);
  }
}


// Check if a landmark is valid
boolean isValidLandmark(int idx) {
  return keypoints[idx * 2] > 0 && keypoints[idx * 2 + 1] > 0;
}

// Handle incoming OSC messages
void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/pose")) { // Expecting messages with address /pose
    for (int i = 0; i < keypoints.length; i++) {
      keypoints[i] = msg.get(i).floatValue(); // Store received keypoints
    }
  }
}
