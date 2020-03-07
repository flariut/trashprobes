class MatrixApplet extends PApplet {
  int scr;
  int msg_s, rtr_s = 0;
  Matrix matrix;

  public MatrixApplet(int scr) {
    super();
    this.scr = scr;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    fullScreen(P2D, scr);
    //noSmooth();
  }

  public void setup() {
    noCursor();
    frameRate(10); // Anda demasiado rápido sino
    println(width, height);
    matrix = new Matrix(this, width, height);
  }

  public void draw() {
    background(0);

    matrix.update();

  }
}
