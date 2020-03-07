class Router {
  /*
    Leer el CSV, asignar los datos internamente, etc...
  */
  String ssid;
  float lat, lon;
  ArrayList<String> places = new ArrayList<String>();

  Router(String line) {
    String[] splitted = splitTokens(line, ",");
    int l = splitted.length;
    ssid = splitted[1];
    if(l > 2) { // Si se pudo geolocalizar...
      lat = float(splitted[2]);
      lon = float(splitted[3]);
      for(int i = 4; i < l; i++) {
        places.add(splitted[i]);
      }
    }
  }

}
