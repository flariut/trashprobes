class Matrix {
  PApplet parent;
  PFont myFont;
  int ltrsize, mx, my, txtClr;
  Mchar[][] cmatrix;

  Matrix(PApplet parent, int sx, int sy) {
    this.parent = parent;
    ltrsize = sx * sy / 40000;
    mx = sx / ltrsize;
    my = sy / ltrsize;

    myFont = createFont("FreeMono Bold", ltrsize);
    parent.textFont(myFont);
    parent.textAlign(LEFT, TOP);

    cmatrix = new Mchar[mx][my];
    for(int y = 0; y < my; y++) {
      for(int x = 0; x < mx; x++) {
        cmatrix[x][y] = new Mchar();
      }
    }
  }

  void insert_data(Message msg, float time) {
    int wx, wy;
    String data = msg.model + "→" + msg.probe_to;

    //wx = int(msg.randomx * mx);
    //wy = int(msg.randomy * my);
    wx = int(random(mx));
    wy = int(random(my));

    if(data.length() > mx){
      return;
    }

    while(wx + data.length() > mx) {
      wx--;
    }

    for(int i = 0; i < data.length(); i++) {
      cmatrix[wx+i][wy].set(data.charAt(i), msg.mac[3], msg.mac[4], msg.mac[5],
                            time);
    }
  }

  void insert_data(Router rtr, float time) {
    if (rtr.places.size() != 0) {
      for (String place : rtr.places) {
        int wx, wy;
        String data = rtr.ssid;

        data += "☻" + place;

        wx = int(random(mx));
        wy = int(random(my - 1));

        if(data.length() > mx){
          data.replaceAll(" ","");
        }

        while(wx + data.length() > mx && wx > 0) {
          wx--;
        }

        for(int i = 0, j = 0; i < data.length(); i++) {
          if(i >= mx) {
            cmatrix[wx+j][wy+1].set(data.charAt(i), 255, 0, 0, time);
            j++;
          } else {
            cmatrix[wx+i][wy+j].set(data.charAt(i), 255, 0, 0, time);
          }
        }
      }
    }
  }

  void update() {

    txtClr++;
    txtClr %= 360;

    for(int y = 0; y < my; y++) {
      for(int x = 0; x < mx; x++) {
        if (cmatrix[x][y].c != 0) {

          if (millis() - cmatrix[x][y].time >= 10*1000 && random(1) > 0.9) {
            cmatrix[x][y] = new Mchar();
          }

          parent.colorMode(RGB, 255, 255, 255);
          parent.fill(cmatrix[x][y].r, cmatrix[x][y].g, cmatrix[x][y].b);
          parent.text(cmatrix[x][y].c, x * ltrsize, y * ltrsize);

        } else {

          parent.colorMode(HSB, 360, 100, 100);
          parent.fill(txtClr, 80, 20);
          parent.text(char((int)random(33, 126)), x * ltrsize, y * ltrsize);

        }
      }
    }
  }

}

class Mchar {
  char c;
  int r, g, b;
  float time;

  Mchar() {
    c = 0;
    r = 0;
    g = 0;
    b = 0;
    time = 0;
  }

  Mchar(char c, int r, int g, int b, float time) {
    this.c = c;
    this.r = r;
    this.g = g;
    this.b = b;
    this.time = time;
  }

  void set(char c, int r, int g, int b, float time) {
    this.c = c;
    this.r = r;
    this.g = g;
    this.b = b;
    this.time = time;
  }

}
