import ddf.minim.*;
import ddf.minim.ugens.*;

Minim minim;
AudioOutput out;

class BlackHoleApplet extends PApplet {

  int scr;
  float comp, level;

  PVector bh;

  ArrayList<Particle> particles = new ArrayList<Particle>();

  public BlackHoleApplet(int scr) {
    super();
    this.scr = scr;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    fullScreen(P2D, scr);
    //noSmooth();
  }
  public void setup() {
    background(5);

    minim = new Minim(this);
    out = minim.getLineOut(Minim.MONO, 2048);

    noCursor();
    println(width, height);
    bh = new PVector(width/2, height/2);


  }


  public void draw() {
    //background(5);
    blendMode(SUBTRACT);
    fill(5, 5, 5);
    rect(0, 0, width, height);
    blendMode(BLEND);

    //background(5);

    // Compression
    level = abs(out.mix.level_peak());

    if(level > 1) {
      comp = -20 * log10(level);
      out.setGain(comp);
      println("COMPRESSING", comp);
    } else if (out.getGain() < 0) {
      out.setGain(out.getGain() + 0.1);
    } else if (out.getGain() > 0) {
      out.setGain(0);
    }

    for(int i = 0; i < particles.size(); i++) {
      particles.get(i).update(bh);
      if (particles.get(i).absorbed) {
        particles.remove(i);
      }
    }

    noStroke();
    fill(0);
    ellipse(bh.x, bh.y, BHS, BHS);

    for(int i = 0; i < 50; i++) {
      noFill();
      stroke(0+i, 0+i, 0+i, 0 + i);
      //stroke(0 + i);
      //noStroke();
      ellipse(bh.x, bh.y, BHS + i, BHS + i);
    }

    for(int i = 0; i < 50; i++) {
      noFill();
      stroke(50-i, 50-i, 50-i, 50 - i);
      //noStroke();
      ellipse(bh.x, bh.y, BHS + 50 + i, BHS + 50 + i);
    }
  }
}
