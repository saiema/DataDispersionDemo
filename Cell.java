public class Cell {
  
  private int content;
  
  public static Cell createEmptyCell() {
    return new Cell(0);
  }
  
  public static Cell createCellWithContent(int content) {
    assert content >= 0;
    return new Cell(content);
  }
  
  private Cell(int content) {
    this.content = content;
  }
  
  public boolean isEmpty() {
    return content == 0;
  }
  
  public int count() {
    return this.content;
  }
  
  public void increment() {
    this.content++;
  }
  
  public void clear() {
    this.content = 0;
  }
  
  public void decrement() {
    if (this.content > 0)
      this.content--;
  }

}
