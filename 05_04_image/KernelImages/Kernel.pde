public class Kernel{
  float[][]kernel;

  public Kernel(float[][]init) {
    this.kernel = init;
  }

  color calcNewColor(PImage img, int x, int y, int mode) {
    float rTotal = 0, gTotal = 0, bTotal = 0;
    
    for (int ki = 0; ki < 3; ki++) {
     for (int kj = 0; kj < 3; kj++) {
      int nx = x + (ki - 1);
      int ny = y + (kj - 1);
      
      // Boundary Handling 
      if (nx < 0 || nx >= img.width - 0 || ny < 0 || ny >= img.height - 0) {
        if (mode == 1) {
          return color(0); // 1. Cropping
        } 
        else if (mode == 2) {
          nx = constrain(nx, 0, img.width-1); // 2. Duplicating
          ny = constrain(ny, 0, img.height - 1);
        } 
        else if (mode == 3) {
         nx = (nx + img.width) % img.width; // 3. Wrapping
         ny = (ny + img.height) % img.height;
        }
      }

      // Your original pixel reading logic
      color c = img.get(nx, ny);
      float weight = kernel[ki][kj];
      rTotal += red(c) * weight;
      gTotal += green(c) * weight;
      bTotal += blue(c) * weight;
    }
   }
   return color(constrain(rTotal, 0, 255), constrain(gTotal, 0, 255), constrain(bTotal, 0, 255));
  }

  void apply(PImage source, PImage destination, int mode) {
    source.loadPixels();
    destination.loadPixels();
    for (int x = 0; x < source.width; x++){
     for (int y = 0; y < source.height; y++){
       color newColor = calcNewColor(source, x, y, mode);
       destination.set(x, y, newColor);
     }
    } 
    // FIXED: Moved updatePixels outside of the x and y loops so the sketch doesn't freeze!
    destination.updatePixels(); 
  }
}
