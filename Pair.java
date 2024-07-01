public class Pair<A, B> {
  private A fst;
  private B snd;
  
  public Pair(A fst, B snd) {
    this.fst = fst;
    this.snd = snd;
  }
  
  public void fst(A fst) {
    this.fst = fst;
  }
  
  public A fst() {
    return fst;
  }
  
  public void snd(B snd) {
    this.snd = snd;
  }
  
  public B snd() {
    return snd;
  }
  
  @Override
  public String toString() {
    return "(" + String.valueOf(fst) + ", " + String.valueOf(snd) + ")";
  }

}
