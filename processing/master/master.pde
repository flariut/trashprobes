BlackHoleApplet blackholeapplet;
MatrixApplet matrixapplet;

// Espacio para declarar variables globales que se apliquen a todos
String[] lines_com;

int l_com;
float last_time = 0;
String last_mac = "";

Router rtr_aux;
Message msg_aux;
Particle prt_aux;

void update_file() {
  lines_com = loadStrings("../../databases/communication.csv");
}

void settings() {
}

void setup() {

  update_file();
  //l_msg = lines_msg.length;
  //l_rtr = lines_rtr.length;
  l_com = lines_com.length;


  blackholeapplet = new BlackHoleApplet(1);
  matrixapplet = new MatrixApplet(2);

  surface.setVisible(false);

}

void draw() {
  update_file();

  for (l_com = l_com; l_com < lines_com.length; l_com++) {
    if (lines_com[l_com].substring(0,3).equals("msg")) {
        msg_aux = new Message(lines_com[l_com]);

        if (msg_aux.timef - last_time > 30 || !last_mac.equals(msg_aux.smac)) {
          if (blackholeapplet.particles.size() < 150) {
            prt_aux = new Particle(blackholeapplet, msg_aux, blackholeapplet.bh);
            blackholeapplet.particles.add(prt_aux);
          }
          matrixapplet.matrix.insert_data(msg_aux, millis());
        }

        last_time = msg_aux.timef;
        last_mac = msg_aux.smac;
    } else {
        rtr_aux = new Router(lines_com[l_com]);
        matrixapplet.matrix.insert_data(rtr_aux, millis());
    }
  }
}
