import java.util.List;
import java.util.LinkedList;

public class World {

  private final int size;
  private final Cell[][] world;

  public World(int size) {
    assert size > 0;
    this.size = size;
    this.world = new Cell[size][size];
    initializeWorld();
  }

  private void initializeWorld() {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        world[i][j] = Cell.createEmptyCell();
      }
    }
  }

  public int size() {
    return size;
  }

  public void increaseCellContentAt(int i, int j) {
    assert i >= 0 && i < size;
    assert j >= 0 && j < size;
    world[i][j].increment();
  }

  public void decreaseCellContentAt(int i, int j) {
    assert i >= 0 && i < size;
    assert j >= 0 && j < size;
    world[i][j].decrement();
  }
  
  public int cellContentAt(int i, int j) {
    assert i >= 0 && i < size;
    assert j >= 0 && j < size;
    return world[i][j].count();
  }

  public boolean cellAtIsNotEmpty(int i, int j) {
    assert i >= 0 && i < size;
    assert j >= 0 && j < size;
    return !world[i][j].isEmpty();
  }
  
  public void clearWorld() {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        world[i][j].clear();
      }
    }
  }
  
  public List<Pair<Integer, Integer>> nonEmptyCells() {
    List<Pair<Integer, Integer>> nonEmptyCells = new LinkedList<>();
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        for (int c = 1; c <= world[i][j].count(); c++) {
          nonEmptyCells.add(new Pair<Integer, Integer>(i, j));
        }
      }
    }
    return nonEmptyCells;
  }
  
}
