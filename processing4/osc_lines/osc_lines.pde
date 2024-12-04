import oscP5.*;
import netP5.*;

OscP5 oscP5;
float[][] keypoints; // To store the 33 points of the body (MediaPipe returns 33 points)

void setup() {
  size(640, 480);
  oscP5 = new OscP5(this, 12000); // Port used in Python
  keypoints = new float[33][2];  // Each point has X and Y
}

void draw() {
  background(0);

  // Desenhar um blob conectando os keypoints
  noFill();
  stroke(255, 100, 200);
  beginShape();
  for (int i = 0; i < keypoints.length; i++) {
    if (keypoints[i][0] > 0 && keypoints[i][1] > 0) { // Garantir pontos válidos
      float x = keypoints[i][0] * width;  // Converter para coordenadas da tela
      float y = keypoints[i][1] * height;
      vertex(x, y);
    }
  }
  endShape(CLOSE);
}

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/pose")) {
    for (int i = 0; i < 33; i++) {
      keypoints[i][0] = msg.get(i * 2).floatValue();     // X
      keypoints[i][1] = msg.get(i * 2 + 1).floatValue(); // Y
    }
  }
}
