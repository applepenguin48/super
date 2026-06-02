class Tile {
  // 1. The Core Instance Variables
  private int r;               // Maps to your row index
  private int c;               // Maps to your column index
  private float x;             // Maps to your pixel X coordinate
  private float y;             // Maps to your pixel Y coordinate
  private float size;          // Maps to your tile size
  private Candy candy;         // Maps to your current candy object
  private boolean isSelected;  // Maps to your selection state

  // 2. The Constructor
  Tile(int r, int c, float x, float y, float size) {
    this.r = r;
    this.c = c;
    this.x = x;
    this.y = y;
    this.size = size;
    this.candy = null;
    this.isSelected = false;
  }

  // 3. The Unified Display Method
  // This uses your original styled colors (dark slate theme) but retains the candy-drawing check
    public void display() {
    // If selected, give it a bright yellow border. Otherwise, a subtle white border.
     if (isSelected) {
      stroke(255, 255, 0); // Bright Yellow
      strokeWeight(3);     // Thick border
     } else {
      stroke(255, 50);     // Faint White
      strokeWeight(1);     // Thin border
    }
    
    fill(45, 45, 55); // Your nice dark-mode background color
    rect(x, y, size, size, 8); // Clean rounded corners
  }

  // 4. The Bridge Methods (Getters and Setters for your Board class)
  // These convert the naming styles cleanly so your Board can talk to this tab without errors
  public int getMatrixRow() { return this.r; }
  public int getMatrixCol() { return this.c; }
  public Candy getCandy()   { return this.candy; }
  
  public void setCandy(Candy c){ 
    this.candy = c; 
  }
  public void setSelected(boolean b){ 
    this.isSelected = b; 
  }
}
