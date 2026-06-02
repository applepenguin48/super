class Board {
  private int rows;
  private int cols;
  private Tile[][] grid;
  private float tileSize = 60;
  private float offsetX = 60, offsetY = 60;
  private Tile firstSelected = null;
  private int score = 0;

  // The State Machine: 0 = Playable, 1 = Crushing Animation, 2 = Dropping Animation
  private int gameState = 0; 

  Board(int r, int c) {
    this.rows = r;
    this.cols = c;
    grid = new Tile[rows][cols];
    initializeBoard();
  }

  public void updateAnimations() {
    boolean isAnythingShrinking = false;
    boolean isAnythingMoving = false;

    // 1. Update every candy's math
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (grid[i][j].candy != null) {
          grid[i][j].candy.update();
          if (grid[i][j].candy.isShrinking()) isAnythingShrinking = true;
          if (grid[i][j].candy.isMoving()) isAnythingMoving = true;
        }
      }
    }

    // 2. PHASE MANAGER
    if (gameState == 1 && !isAnythingShrinking) {
      // The breaking animation finished! Now clear them and trigger gravity
      removeMatches();
      applyGravity();
      refillBoard();
      gameState = 2; // Switch to drop phase
    } 
    else if (gameState == 2 && !isAnythingMoving) {
      // All pieces have landed! Check if they created a new chain reaction
      if (scanAndMarkMatches()) {
        gameState = 1; // More matches! Go back to crush phase
      } else {
        gameState = 0; // Board is quiet. Give controls back to player
      }
    }
  }

 public void display() {
    // Draw tiles first (background)
    for (int i = 0; i < rows; i++) for (int j = 0; j < cols; j++) grid[i][j].display();
    
    // Draw candies on top so they can slide over the grid seamlessly
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (grid[i][j].candy != null) grid[i][j].candy.display(tileSize * 0.75);
      }
    }
  }

  public void initializeBoard() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        float px = offsetX + j * tileSize;
        float py = offsetY + i * tileSize;
        grid[i][j] = new Tile(i, j, px, py, tileSize);
        
        int randomType = int(random(5));
        while (createsStartingMatch(i, j, randomType)) {
          randomType = int(random(5));
        }
        // Center the candy in the tile
        grid[i][j].candy = new Candy(randomType, px + tileSize/2, py + tileSize/2);
      }
    }
  }

  public boolean createsStartingMatch(int r, int c, int type) {
    if (c >= 2 && grid[r][c-1].candy != null && grid[r][c-2].candy != null &&
        grid[r][c-1].candy.type == type && grid[r][c-2].candy.type == type) return true;
    if (r >= 2 && grid[r-1][c].candy != null && grid[r-2][c].candy != null &&
        grid[r-1][c].candy.type == type && grid[r-2][c].candy.type == type) return true;
    return false;
  }

  public void handleMouseClick(int mx, int my) {
    if (gameState != 0) return; // Block clicks if the board is animating!

    int c = int((mx - offsetX) / tileSize);
    int r = int((my - offsetY) / tileSize);

    if (r >= 0 && r < rows && c >= 0 && c < cols) {
      Tile clickedTile = grid[r][c];

      if (firstSelected == null) {
        firstSelected = clickedTile;
        firstSelected.isSelected = true;
      } else {
        if (isAdjacent(firstSelected, clickedTile)) {
          swapCandies(firstSelected, clickedTile);
          
          if (scanAndMarkMatches()) {
            gameState = 1; // Start the breaking animation!
          } else {
            swapCandies(firstSelected, clickedTile); // Invalid, swap back
          }
        }
        firstSelected.isSelected = false;
        firstSelected = null;
      }
    }
  }

  public boolean isAdjacent(Tile t1, Tile t2) {
    int rDiff = abs(t1.r - t2.r);
    int cDiff = abs(t1.c - t2.c);
    return (rDiff == 1 && cDiff == 0) || (rDiff == 0 && cDiff == 1);
  }

  public void swapCandies(Tile t1, Tile t2) {
    Candy c1 = t1.getCandy();
    Candy c2 = t2.getCandy();
    t1.setCandy(c2);
    t2.setCandy(c1);

    // Instantly snap coordinates for the swap input to keep it feeling responsive
    if (c1 != null) {
      c1.x = t2.x + tileSize/2;
      c1.y = t2.y + tileSize/2;
      c1.setTarget(c1.x, c1.y);
    }
    if (c2 != null) {
      c2.x = t1.x + tileSize/2;
      c2.y = t1.y + tileSize/2;
      c2.setTarget(c2.x, c2.y);
    }
  }

  public boolean scanAndMarkMatches() {
    boolean foundMatch = false;
    
    // Reset flags
    for (int i=0; i<rows; i++) for (int j=0; j<cols; j++) 
      if (grid[i][j].candy != null) grid[i][j].candy.isMatched = false;

    // Horizontal
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols - 2; j++) {
        if (grid[i][j].candy == null) continue;
        int type = grid[i][j].candy.type;
        if (grid[i][j+1].candy != null && grid[i][j+2].candy != null &&
            grid[i][j+1].candy.type == type && grid[i][j+2].candy.type == type) {
          grid[i][j].candy.isMatched = true;
          grid[i][j+1].candy.isMatched = true;
          grid[i][j+2].candy.isMatched = true;
          foundMatch = true;
        }
      }
    }

    // Vertical
    for (int j = 0; j < cols; j++) {
      for (int i = 0; i < rows - 2; i++) {
        if (grid[i][j].candy == null) continue;
        int type = grid[i][j].candy.type;
        if (grid[i+1][j].candy != null && grid[i+2][j].candy != null &&
            grid[i+1][j].candy.type == type && grid[i+2][j].candy.type == type) {
          grid[i][j].candy.isMatched = true;
          grid[i+1][j].candy.isMatched = true;
          grid[i+2][j].candy.isMatched = true;
          foundMatch = true;
        }
      }
    }
    return foundMatch;
  }

  public void removeMatches() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (grid[i][j].candy != null && grid[i][j].candy.isMatched) {
          grid[i][j].candy = null; // Actually delete them from the board
          score += 10;
        }
      }
    }
  }

  public void applyGravity() {
    for (int j = 0; j < cols; j++) {
      int writeRow = rows - 1;
      for (int i = rows - 1; i >= 0; i--) {
        Candy c = grid[i][j].candy;
        if (c != null) {
          grid[writeRow][j].candy = c;
          if (writeRow != i) grid[i][j].candy = null;
          
          // The Magic: Update the candy's target destination to its new row!
          c.setTarget(grid[writeRow][j].x + tileSize/2, grid[writeRow][j].y + tileSize/2);
          writeRow--;
        }
      }
    }
  }

  void refillBoard() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (grid[i][j].candy == null) {
          float px = grid[i][j].x + tileSize/2;
          float targetPy = grid[i][j].y + tileSize/2;
          
          // Spawn the new candy WAY above the screen so it slides down dynamically
          float spawnPy = offsetY - (rows * tileSize) + (i * tileSize);
          
          Candy newCandy = new Candy(int(random(5)), px, spawnPy);
          newCandy.setTarget(px, targetPy);
          grid[i][j].candy = newCandy;
        }
      }
    }
  }
}
