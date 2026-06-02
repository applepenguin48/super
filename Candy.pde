class Candy {
  int type;
  float x, y;
  float targetX, targetY;
  float scale = 1.0;
  boolean isMatched = false;

  Candy(int type, float startX, float startY) {
    this.type = type;
    this.x = startX;
    this.y = startY;
    this.targetX = startX;
    this.targetY = startY;
  }

  void setTarget(float tx, float ty) {
    this.targetX = tx;
    this.targetY = ty;
  }

  boolean isMoving() {
    return dist(x, y, targetX, targetY) > 0.5; 
  }

  boolean isShrinking() {
    return isMatched && scale > 0;
  }

  void update() {
    // 1. If it's a match, smoothly shrink it down to zero
    if (isMatched && scale > 0) {
      scale -= 0.1; // Animation speed for breaking
      if (scale < 0) scale = 0;
    }

    // 2. Smoothly slide towards the target location
    if (isMoving()) {
      x = lerp(x, targetX, 0.2); // 0.2 is the slide speed
      y = lerp(y, targetY, 0.2);
    } else {
      x = targetX; // Snap exactly into place when close
      y = targetY;
    }
  }

  void display(float size) {
    if (scale <= 0) return; // Don't draw if fully crushed

    pushMatrix();
    translate(x, y); // Move to the candy's actual animated location
    scale(scale);    // Apply the shrinking effect

    noStroke();
    if (type == 0) fill(255, 50, 50);       // Red
    else if (type == 1) fill(50, 100, 255); // Blue
    else if (type == 2) fill(50, 200, 50);  // Green
    else if (type == 3) fill(255, 215, 0);  // Yellow
    else if (type == 4) fill(150, 50, 200); // Purple
    
    ellipse(0, 0, size, size); 
    popMatrix();
  }
}
