final int CM = 10;
//final float CT = 0.0002;
final float CT = 0.0002;
final int BHS = 150;
final int PS = 10;
final int VOICES = 20;
int voices_playing;
/*

Partículas irregulares, más grades
Agujero negro que sea medio 3d, o medio outer glow, o algo así
Tienen que dejar una estela
Órbitas que no sean 100% circulares
Circulitos alrededor de la partícula cuando suena
Letras se tienen que ir más rápido


*/
float log10 (float x) {
  return (log(x) / log(10));
}

class Particle {
  PApplet parent;

  // Visuales
  PVector pos, dis, ant;
  int r, g, b, npoints;
  float dm, init_h, init_d, t, v, msg_time, c, d, sum_manuf;
  float[] irr_a, irr_s;
  int sent;
  boolean absorbed, playing, stopped;

  // Sonido
  int type, c_size;
  float amp, gen_sound, freq, atk, dec, sus, suslvl, rel, duration, ptime, comp;


  Particle(PApplet parent, Message msg, PVector bh) {
    this.parent = parent;
    pos = new PVector(msg.randomx * parent.width, msg.randomy * parent.height);

    dis = PVector.sub(pos, bh);
    v = pos.heading();
    init_h = dis.heading();
    init_d = dis.mag();
    msg_time = msg.timef;
    t = 0;

    sent = round(random(1)) * 2 - 1;

    // Seteamos el color
    r = msg.mac[3];
    g = msg.mac[4];
    b = msg.mac[5];

    sum_manuf = msg.mac[0] + msg.mac[1] + msg.mac[2];

    npoints = round(sum_manuf/64);
    if (npoints < 3) npoints = 3;

    irr_a = new float[npoints];
    irr_s = new float[npoints];

    float check = 0;
    float shit, var;
    for(int i = 0; i < npoints - 1; i++) {
      irr_a[i] = check;
      check += TWO_PI / npoints * msg.mac[i%6] / 127;
    }
    irr_a[npoints-1] = (irr_a[npoints-1] + TWO_PI) / 2;
    irr_a = sort(irr_a);


    for(int i = 0; i < npoints; i++) {
      irr_s[i] = 1 + msg.mac[i%6] / 127;
    }


    // Sonido

    gen_sound = sum_manuf / 255.0 * (r + g + b);

    if (gen_sound <= 286 || gen_sound > 1434) {
      // Noise medioso
      // 0 565.8353 282.91766 1.9294118 1.4 0.6 0.25882354 4188.2354
      type = 0;

      atk = map(sum_manuf, 0, 765, 3, 5);
      dec = map(r, 0, 255, 3, 5);
      sus = map(g, 0, 255, 3, 5);
      rel = map(b, 0, 255, 3, 5);

      freq = gen_sound <= 286 ? gen_sound * 2 : gen_sound / 2;

      amp = 0.5;
      suslvl = 0.5 / 2;

    } else if (gen_sound <= 573) {
      // Percusivos graves
      // 1 80.20291 372.68234 0.01 0.12588236 0.23294118 0.141176s48 510.0
      type = 1;

      atk = 0.01;
      dec = map(r, 0, 255, 0.1, 0.2);
      sus = map(g, 0, 255, 0.1, 0.2);
      rel = map(b, 0, 255, 0.1, 0.2);
      freq = map(gen_sound, 286, 573, 40, 100);

      amp = 0.75;
      suslvl = 0.75 / 2;

    } else if (gen_sound <= 1434) {
      // Aguditos largos
      // 2 14824.076 988.35297 2.509804 3.2156863 4.901961 4.098039 14725.49
      type = 2;

      atk = map(sum_manuf, 0, 765, 3, 5);
      dec = map(r, 0, 255, 3, 5);
      sus = map(g, 0, 255, 3, 5);
      rel = map(b, 0, 255, 3, 5);

      freq = map(gen_sound, 573, 1434, 10000, 18000);

      amp = 0.25;
      suslvl = 0.25 / 2;

    }

    duration = (atk + dec + sus + rel) * 1000;

    this.play(); // Reproducir

  }

  void update(PVector bh) {
    ant = pos.copy();
    dm = dis.mag();

    if(playing && millis() - ptime >= duration) {
      voices_playing--;
      playing = false;
      c_size = 0;
    }


    //if (dm < BHS / 2 - PS * 3 / 2) {
    if (dm < BHS / 3) {
      stopped = true;
      if(playing) {
        voices_playing--;
      }
      absorbed = true;
      return;
    }

    c = init_d / dm;
    d = BHS / dm;
    v = v + CT * CM * c * c;

    dis.rotate(sent * CT * CM * c * c);

    if (!stopped) {
      pos.x = bh.x + dis.x;
      pos.y = bh.y + dis.y;
    }

    dis.setMag(init_d - v * v);


    if (playing) {
      parent.stroke(r, g, b);
      parent.noFill();
      parent.ellipse(pos.x, pos.y, PS*9 + c_size, PS*9 + c_size);
      c_size += 10;
    }


    parent.stroke(r, g, b);
    parent.fill(r, g, b);
    parent.pushMatrix();
    parent.translate(pos.x, pos.y);
    parent.rotate(parent.frameCount / (sent * CM * CM * c * c));
    this.irregularPolygon(0, 0, PS / c, npoints, irr_a, irr_s);
    parent.popMatrix();

    //parent.ellipse(pos.x, pos.y, PS, PS);
    //parent.line(ant.x, ant.y, pos.x, pos.y);


    float init_h_pi = (init_h < PI) ? init_h + PI : init_h - PI;
    if ((abs(dis.heading()-init_h) <= CT*CM*CM ||
        abs(dis.heading()-init_h_pi) <= CT*CM*CM) &&
        !playing) {
      this.play();
    }

    t += CT;

  }

  void polygon(float x, float y, float radius, int npoints) {

    float angle = TWO_PI / npoints;
    parent.beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
      float sx = x + cos(a) * radius;
      float sy = y + sin(a) * radius;
      parent.vertex(sx, sy);
    }
    parent.endShape(CLOSE);
  }

  void irregularPolygon(float x, float y, float radius,
                        int npoints, float[] irr_a, float[] irr_s) {


    parent.beginShape();

    for (int i = 0; i < npoints; i++) {
      float sx = x + cos(irr_a[i]) * radius * irr_s[i];
      float sy = y + sin(irr_a[i]) * radius * irr_s[i];
      parent.vertex(sx, sy);

    }
    parent.endShape(CLOSE);

  }

  void play() {

    comp = out.mix.level_peak() + amp;
    if (comp > 1) {
      // Lookahead-Compress
      comp = -20 * log10(comp);
      out.setGain(comp);
      println("LH-COMPRESSING", comp);
    }

    if(voices_playing < VOICES) {
      voices_playing++;
      playing = true;
      out.playNote(0, sus, new TrashSound(type, amp, freq, atk, dec, suslvl, rel));
      ptime = millis();
    }
  }

}
