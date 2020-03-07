class Message {
  String time, model, probe_to, smac;
  String[] mac_address;
  float randomx, randomy, timef;
  int[] mac = new int[6];
  int other, sn;

  Message(String line) {
    String[] splitted = splitTokens(line, ",");
    time = splitted[1];
    timef = float(time);

    String[] time_splitted = splitTokens(time, ".");
    if (time_splitted[1].length() == 9) {
      randomx = float("0." + time_splitted[1].substring(1, 5));
      randomy = float("0." + time_splitted[1].substring(5, 9));
    } else {
      randomx = random(1);
      randomy = random(1);
    }

    smac = splitted[2];
    mac_address = splitTokens(smac, ":");
    for(int i = 0; i < 6; i++) {
      mac[i] = unhex(mac_address[i]);
    }

    other = int(splitted[3]);
    sn = int(splitted[4]);
    model = splitted[5];
    probe_to = splitted[6];
  }

}
