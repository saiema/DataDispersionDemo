import java.util.List;
import java.util.LinkedList;
import java.util.Collections;

final int worldSize = 40;
final int cellSize = 20;
final int STROKE_WEIGHT_DEFAULT = 1;
final int STROKE_WEIGHT_WIDER = 2;
final int STROKE_WEIGHT_WIDEST = 4;
World world = null;
boolean update = true;
int validMaxSize;
final int EXTRA_RIGHT_SIZE = 280;
final int STATISTICS_GAP_DISTANCE = 20;

void settings() {
  size((worldSize*cellSize) + EXTRA_RIGHT_SIZE, worldSize*cellSize);
  validMaxSize = worldSize*cellSize;
}

void setup() {
  world = new World(worldSize);
}

void draw() {
  drawWorld();
}

void keyPressed() {
  switch(key) {
    case 'c':
    case 'C': {
      world.clearWorld();
      update = true;
      break;
    }
    case 'd':
    case 'D': {
      drawDistances();
      break;
    }
    case 's':
    case 'S': {
      printStatistics();
      break;
    }
  }
}

void mousePressed() {
  int rawXCoord = mouseX;
  int rawYCoord = mouseY;
  if (!isValidCoord(rawXCoord, rawYCoord))
    return;
  int xCoordByCells = floor(rawXCoord / cellSize);
  int yCoordByCells = floor(rawYCoord / cellSize);
  if (mouseButton == LEFT) {
    world.increaseCellContentAt(xCoordByCells, yCoordByCells);
  } else if (mouseButton == RIGHT) {
    world.decreaseCellContentAt(xCoordByCells, yCoordByCells);
  }
  update = true;
}

private boolean isValidCoord(int x, int y) {
  if (x < 0 || x > validMaxSize)
    return false;
  if (y < 0 || y > validMaxSize)
    return false;
  return true;
}

private void drawWorld() {
  if (!update)
    return;
  background(192);
  stroke(0, 0, 0);
  strokeWeight(STROKE_WEIGHT_DEFAULT);
  for (int hCoord = 0; hCoord < worldSize; hCoord++) {
    for (int vCoord = 0; vCoord < worldSize; vCoord++) {
      if (world.cellAtIsNotEmpty(hCoord, vCoord)) {
        fill(125, 218, 88);
      } else {
        fill(255, 255, 255);
      }
      rectMode(CORNER);
      rect(hCoord*cellSize, vCoord*cellSize, cellSize, cellSize);
      if (world.cellAtIsNotEmpty(hCoord, vCoord)) {
        textSize(12);
        textAlign(LEFT, TOP);
        fill(0, 0, 0);
        String countAsString = String.valueOf(world.cellContentAt(hCoord, vCoord));
        text(countAsString, hCoord*cellSize, vCoord*cellSize);
      }
    }
  }
  update = false;
}

private void drawDistances() {
  List<Pair<Integer, Integer>> liveCells = world.nonEmptyCells();
  strokeWeight(STROKE_WEIGHT_WIDER);
  stroke(254, 153, 0);
  for (int i = 0; i < liveCells.size(); i++) {
    for (int j = i + 1; j < liveCells.size(); j++) {
      Pair<Integer, Integer> p = liveCells.get(i);
      Pair<Integer, Integer> q = liveCells.get(j);
      int pXCoord = (p.fst() * cellSize) + (cellSize / 2);
        int pYCoord = (p.snd() * cellSize) + (cellSize / 2);
        int qXCoord = (q.fst() * cellSize) + (cellSize / 2);
        int qYCoord = (q.snd() * cellSize) + (cellSize / 2);
        line(pXCoord, pYCoord, qXCoord, qYCoord);
    }
  }
}

private void printStatistics() {
  int startingStatisticsXCoord = validMaxSize + STATISTICS_GAP_DISTANCE;
  final int TEXT_SIZE = 16;
  textSize(TEXT_SIZE);
  textAlign(LEFT, TOP);
  fill(0, 0, 0);
  List<Pair<Integer, Integer>> cells = world.nonEmptyCells();
  if (cells.size() < 2) {
    fill(228, 8, 10);
    text("You need to have at least two values\n", startingStatisticsXCoord, 0);
    return;
  }
  int totalCells = cells.size();
  int differentCells = differentCells(cells);
  List<Float> distances = calculateDistances(cells);
  //printDistances(distances);
  float mean = mean(distances);
  float sumOfSquares = sumOfSquares(distances, mean);
  float sampleVariance = sampleVariance(sumOfSquares, distances.size());
  float standardDeviation = sqrt(sampleVariance);
  float coefficientOfVariation = standardDeviation / mean;
  StringBuilder statisticsTextBuilder = new StringBuilder();
  statisticsTextBuilder.append("Diversity metrics:").append("\n");
  statisticsTextBuilder.append("Points: ").append(cells.size()).append("\n");
  statisticsTextBuilder.append("Distances: ").append(distances.size()).append("\n");
  statisticsTextBuilder.append("Simple value diversity: ").append(totalCells==0?"N/A":(String.format("%.4f", (float)differentCells/(float)totalCells))).append("\n");
  statisticsTextBuilder.append("Mean: ").append(String.format("%4f", mean)).append("\n");
  statisticsTextBuilder.append("Sum of Squares: ").append(String.format("%.4f", sumOfSquares)).append("\n");
  statisticsTextBuilder.append("Sample Variance: ").append(String.format("%.4f", sampleVariance)).append("\n");
  statisticsTextBuilder.append("Standard deviation: ").append(String.format("%.4f", standardDeviation)).append("\n");
  statisticsTextBuilder.append("Coefficient of Variation: ").append(String.format("%.4f", coefficientOfVariation)).append("%").append("\n");
  text(statisticsTextBuilder.toString(), startingStatisticsXCoord, 0);
  
  //--------------Box and whiskers plot---------------------
  final int scale = 10;
  float[] orderedDistances = new float[distances.size()];
  int i = 0;
  for (float v : order(distances)) {
    orderedDistances[i++] = v;
  }
  float minValue = orderedDistances[0];
  float maxValue = orderedDistances[orderedDistances.length - 1];
  float[] quartiles = quartiles(orderedDistances);
  float median = quartiles[Quartile.SECOND.relatedIndex()];
  float firstQuartile = quartiles[Quartile.FIRST.relatedIndex()];
  float thirdQuartile = quartiles[Quartile.THIRD.relatedIndex()];
  int statisticsLineCount = (int) statisticsTextBuilder.toString().lines().count();
  int statisticsPixelsHeightApproximation = statisticsLineCount * TEXT_SIZE;
  StringBuilder boxAndWhiskersBuilder = new StringBuilder();
  boxAndWhiskersBuilder.append("Box and Whiskers plot (values):").append("\n");
  boxAndWhiskersBuilder.append("Min: ").append(String.format("%.4f", minValue)).append("\n");
  boxAndWhiskersBuilder.append("Max: ").append(String.format("%.4f", maxValue)).append("\n");
  boxAndWhiskersBuilder.append("First Quartile: ").append(String.format("%.4f", firstQuartile)).append("\n");
  boxAndWhiskersBuilder.append("Second Quartile (median): ").append(String.format("%.4f", median)).append("\n");
  boxAndWhiskersBuilder.append("Third Quartile: ").append(String.format("%.4f", thirdQuartile)).append("\n");
  boxAndWhiskersBuilder.append("\n").append("Box and Whiskers Plot").append("\nusing scale of ").append(scale).append(":").append("\n");
  text(boxAndWhiskersBuilder.toString(), startingStatisticsXCoord, statisticsPixelsHeightApproximation + (STATISTICS_GAP_DISTANCE * 4));
  //Box and whiskers actual plot
  int boxAndWhiskersValuesLineCount = (int) boxAndWhiskersBuilder.toString().lines().count();
  int boxAndWhiskersValuesPixelsHeightApproximation = boxAndWhiskersValuesLineCount * TEXT_SIZE;
  int boxAndWhiskersMinYPos = statisticsPixelsHeightApproximation + ((STATISTICS_GAP_DISTANCE * 4) * 2) + boxAndWhiskersValuesPixelsHeightApproximation;
  int boxAndWhiskersXPos = validMaxSize + (EXTRA_RIGHT_SIZE / 4);
  int boxAndWhiskersWidth = EXTRA_RIGHT_SIZE / 4;
  strokeWeight(STROKE_WEIGHT_WIDEST);
  
  
  float minToFirstQuartileDistance = Math.abs(minValue - firstQuartile)*scale;
  float minToMedianDistance = Math.abs(minValue - median)*scale;
  float minToThirdQuartileDistance = Math.abs(minValue - thirdQuartile)*scale;
  float thirdQuartileToMaxDistance = Math.abs(thirdQuartile - maxValue)*scale;
  float minToMaxDistance = Math.abs(minValue - maxValue)*scale;
  
  
  stroke(0, 0, 0);
  
  //minToFirstQuartileWhisker
  line(  boxAndWhiskersXPos + boxAndWhiskersWidth / 2,
         boxAndWhiskersMinYPos,
         boxAndWhiskersXPos + boxAndWhiskersWidth / 2,
         boxAndWhiskersMinYPos + minToFirstQuartileDistance);
  
  //thirdQuartileToMaxWhisker
  line(  boxAndWhiskersXPos + boxAndWhiskersWidth / 2,
         boxAndWhiskersMinYPos + minToThirdQuartileDistance,
         boxAndWhiskersXPos + boxAndWhiskersWidth / 2,
         boxAndWhiskersMinYPos + minToThirdQuartileDistance + thirdQuartileToMaxDistance);
         
  //Box
  noFill();
  rectMode(CORNERS);
  rect(  boxAndWhiskersXPos,
         boxAndWhiskersMinYPos + minToFirstQuartileDistance,
         boxAndWhiskersXPos + boxAndWhiskersWidth,
         boxAndWhiskersMinYPos + minToThirdQuartileDistance);
  
  //min
  stroke(125, 218, 88);
  line(boxAndWhiskersXPos, boxAndWhiskersMinYPos, boxAndWhiskersXPos+boxAndWhiskersWidth, boxAndWhiskersMinYPos);
  
  //firstQuartile
  stroke(29, 13, 253);
  line(boxAndWhiskersXPos, boxAndWhiskersMinYPos + minToFirstQuartileDistance, boxAndWhiskersXPos+boxAndWhiskersWidth, boxAndWhiskersMinYPos + minToFirstQuartileDistance);
  
  //median
  stroke(228, 8, 10);
  line(boxAndWhiskersXPos, boxAndWhiskersMinYPos + minToMedianDistance, boxAndWhiskersXPos+boxAndWhiskersWidth, boxAndWhiskersMinYPos + minToMedianDistance);
  
  //thirdQuartile
  stroke(254, 153, 0);
  line(boxAndWhiskersXPos, boxAndWhiskersMinYPos + minToThirdQuartileDistance, boxAndWhiskersXPos+boxAndWhiskersWidth, boxAndWhiskersMinYPos + minToThirdQuartileDistance);
  
  
  
  //max
  stroke(125, 218, 88);
  line(boxAndWhiskersXPos, boxAndWhiskersMinYPos + minToMaxDistance, boxAndWhiskersXPos+boxAndWhiskersWidth, boxAndWhiskersMinYPos + minToMaxDistance);
}

private List<Float> calculateDistances(List<Pair<Integer, Integer>> cells) {
  List<Float> distances = new LinkedList<>();
  for (int i = 0; i < cells.size(); i++) {
    for (int j = i + 1; j < cells.size(); j++) {
      Pair<Integer, Integer> a = cells.get(i);
      Pair<Integer, Integer> b = cells.get(j);
      distances.add(distance(a, b));
    }
  }
  return distances;
}

private int differentCells(List<Pair<Integer, Integer>> cells) {
  List<Pair<Integer, Integer>> differentCells = new LinkedList<>(cells); //<>//
  //printCells(differentCells);
  boolean reduced = true;
  int i = 0;
  while (i < differentCells.size()) {
    Pair<Integer, Integer> current = differentCells.get(i);
      int j = i + 1;
      while (j < differentCells.size()) {
        Pair<Integer, Integer> other = differentCells.get(j);
        if (current.fst().equals(other.fst()) && current.snd().equals(other.snd())) {
          differentCells.remove(j);
          reduced = true;
        } else {
          j++;
        }
      }
    i++;
  }
  //printCells(differentCells);
  return differentCells.size();
}

private void printCells(List<Pair<Integer, Integer>> cells) {
  System.out.println("Printing cells:");
  for (Pair<Integer, Integer> cell : cells) {
    System.out.println(cell.toString());
  }
  System.out.println("---------------");
}

private void printDistances(List<Float> distances) {
  System.out.println("Printing distances:");
  for (Float distance : distances) {
    System.out.println(distance);
  }
  System.out.println("------------------");
}

private float distance(Pair<Integer, Integer> a, Pair<Integer, Integer> b) {
  int xA = a.fst();
  int yA = a.snd();
  int xB = b.fst();
  int yB = b.snd();
  return sqrt(sq(xA - xB) + sq(yA - yB));
}

//Statistical functions
private float mean(List<Float> values) {
  assert values != null : "null argument";
  assert !values.isEmpty() : "empty values";
  assert !values.contains(null) : "null values";
  float sum = 0;
  for (float value : values)
    sum += value;
  return sum / (float) values.size();
}

private float sumOfSquares(List<Float> values, float mean) {
  assert values != null : "null argument";
  assert !values.isEmpty() : "empty values";
  assert !values.contains(null) : "null value";
  float sumOfSquares = 0;
  for (Float value : values) {
    sumOfSquares += sq(value - mean);
  }
  return sumOfSquares;
}

private float sampleVariance(float sumOfSquares, int n) {
  assert n >= 2 : "At least two values needed to calculate sampleVariance";
  return sumOfSquares / (float) (n - 1);
}

private List<Float> order(List<Float> values) {
  List<Float> ordered = new LinkedList<>(values);
  Collections.sort(ordered);
  return ordered;
}

private enum Quartile {
  FIRST {
    @Override
    int relatedIndex() {
      return 0;
    }
  },
  SECOND {
    @Override
    int relatedIndex() {
      return 1;
    }
  },
  THIRD {
    @Override
    int relatedIndex() {
      return 2;
    }
  };
  abstract int relatedIndex();
};

private float[] quartiles(float[] values) {
  float quartiles[] = new float[3];
  
  for (Quartile quartileType : Quartile.values()) {
    float quartile;
    int quartileLowerIndex =  (int) ((values.length + 1) * ((float) (quartileType.relatedIndex() + 1) * 25 / 100)) - 1;
    if (quartileLowerIndex % 1 == 0) {
      quartile = values[quartileLowerIndex];
    } else {
      int quartileUpperIndex = quartileLowerIndex + 1;
      quartile = (values[quartileLowerIndex] + values[quartileUpperIndex]) / 2;
    }
    quartiles[quartileType.relatedIndex()] =  quartile;
  }
  return quartiles;
}
