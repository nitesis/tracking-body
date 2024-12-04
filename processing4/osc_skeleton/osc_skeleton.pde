import oscP5.*;
import netP5.*;

// OSC and keypoints
OscP5 oscP5;
NetAddress remoteLocation;
float[] keypoints = new float[33 * 2]; // Assuming 33 landmarks, each with x and y

// Skeleton connections (MediaPipe Pose format)
int[][] connections = {
  {0, 1}, {1, 2}, {2, 3}, {3, 7},  // Head and shoulders
  {0, 4}, {4, 5}, {5, 6}, {6, 8},  // Head and shoulders
  {9, 10}, {11, 12},               // Shoulders
  {11, 13}, {13, 15},              // Left arm
  {12, 14}, {14, 16},              // Right arm
  {15, 17}, {15, 19}, {15, 21},    // Left hand
  {16, 18}, {16, 20}, {16, 22},    // Right hand
  {11, 23}, {12, 24},              // Torso
  {23, 24}, {23, 25}, {25, 27},    // Left leg
  {24, 26}, {26, 28},              // Right leg
  {27, 29}, {27, 31},              // Left foot
  {28, 30}, {28, 32}               // Right foot
};

void setup() {
  size(800, 800); // Canvas size
  oscP5 = new OscP5(this, 12000); // Listening on port 12000
  println("Waiting for OSC messages on port 5005...");
}

void draw() {
  background(0); // Black background
  stroke(255);   // White color for the skeleton
  strokeWeight(20); // Stroke thickness

  // Draw skeleton
  for (int[] connection : connections) {
    int startIdx = connection[0];
    int endIdx = connection[1];
    if (isValidLandmark(startIdx) && isValidLandmark(endIdx)) {
      float x1 = keypoints[startIdx * 2] * width;
      float y1 = keypoints[startIdx * 2 + 1] * height;
      float x2 = keypoints[endIdx * 2] * width;
      float y2 = keypoints[endIdx * 2 + 1] * height;
      line(x1, y1, x2, y2);
    }
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
