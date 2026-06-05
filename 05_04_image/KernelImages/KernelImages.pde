PImage bird;
PImage output;
int currentKernel;
int mode = 1; // 1 = Cropping, 2 = Duplicating, 3 = Wrapping

String[] names;
Kernel[] kernels;

void setup(){
  size(1370,800);
  bird = loadImage("bird.jpg");
  output = bird.copy();
  
  // FIXED: Start on 1 (Blur) instead of 0 (Identity) so you can actually see it working immediately!
  currentKernel = 1; 
  
  names = new String[]{
    "Identity", "Blur", "Sharpen",
    "Outline", "Left Sobel", "Right Sobel",
    "Top Sobel", "Emboss"
  };

  kernels = new Kernel[] {
    new Kernel( new float[][] {{0, 0, 0}, {0, 1, 0}, {0, 0, 0}}) ,
    new Kernel( new float[][] {{.111, .111, .111}, {.111, .111, .111}, {.111, .111, .111}}) ,
    new Kernel( new float[][] {{0, -1, 0}, {-1, 5, -1}, {0, -1, 0}}) ,
    new Kernel( new float[][] {{-1, -1, -1}, {-1, 8, -1}, {-1, -1, -1}}) ,
    new Kernel( new float[][] {{1, 0, -1}, {2, 0, -2}, {1, 0, -1}}) ,
    new Kernel( new float[][] {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}}) ,
    new Kernel( new float[][] {{1, 2,  1}, {0, 0, 0}, {-1, -2, -1}}),
    new Kernel( new float[][] {{-2, -1,  0}, {-1, 1, 1}, {0, 1, 2}})
  };
}

void draw(){
  background(0);
  
  // Apply kernel and draw images
  kernels[currentKernel].apply(bird, output, mode);
  image(bird, 0, 0);
  image(output, bird.width, 0);
}

// FIXED: Moved keyPressed out of the Kernel class and into the main tab where Processing can see it
void keyPressed(){
  if (key == '1') mode = 1;
  else if (key == '2') mode = 2;
  else if (key == '3') mode = 3;
  
  if (key == CODED) {
    if (keyCode == RIGHT) {
      currentKernel = (currentKernel + 1) % kernels.length;
    } else if (keyCode == LEFT) {
      currentKernel = (currentKernel - 1 + kernels.length) % kernels.length;
    }
  }
}
