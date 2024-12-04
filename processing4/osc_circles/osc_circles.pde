import oscP5.*;
import netP5.*;

OscP5 oscP5;
float[][] keypoints; // Para armazenar os 33 pontos do corpo (MediaPipe retorna 33 pontos)

void setup() {
  size(640, 480);
  oscP5 = new OscP5(this, 12000); // Porta usada no Python
  keypoints = new float[33][2];  // Cada ponto tem X e Y
}

void draw() {
  background(0);

  // Desenhar um círculo de 30px em torno de cada keypoint
  fill(255, 255, 255, 255); // Cor de preenchimento do círculo com transparência
  noStroke(); // Sem contorno
  for (int i = 0; i < keypoints.length; i++) {
    if (keypoints[i][0] > 0 && keypoints[i][1] > 0) { // Garantir pontos válidos
      float x = keypoints[i][0] * width;  // Converter para coordenadas da tela
      float y = keypoints[i][1] * height;
      ellipse(x, y, 30, 30); // Círculo de 30px
    }
  }
}

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/pose")) {
    for (int i = 0; i < 33; i++) {
      keypoints[i][0] = msg.get(i * 2).floatValue();     // X
      keypoints[i][1] = msg.get(i * 2 + 1).floatValue(); // Y
    }
  }
}
