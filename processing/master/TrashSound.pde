/*

  http://code.compartmental.net/minim/

*/

class TrashSound implements Instrument {

  //PApplet parent;

  Oscil osc;
  Noise noise;
  //Summer summer;
  ADSR  adsr;

  MoogFilter filter;

  float freq_real;

  TrashSound(int type, float amp, float freq, float atk, float dec,
             float suslvl, float rel) {

    //summer = new Summer();
    adsr = new ADSR(amp, atk, dec, suslvl, rel);


    switch (type) {

      case 0:
        // Noise medioso
        noise = new Noise(amp, Noise.Tint.PINK);
        filter = new MoogFilter(freq, 0.2, MoogFilter.Type.BP);
        noise.patch(filter).patch(adsr);
        break;
      case 1:
        // Percusivos graves
        osc = new Oscil(freq, amp, Waves.TRIANGLE);
        osc.patch(adsr);

        break;
      case 2:
        // Aguditos largos
        /* GranulateRandom(float grainLengthMin,
                           float spaceLengthMin,
                           float fadeLengthMin,
                           float grainLengthMax,
                           float spaceLengthMax,
                           float fadeLengthMax,
                           float minAmp,
                           float maxAmp)

        */
        osc = new Oscil(freq, amp, Waves.SINE);
        //chopper = new GranulateRandom(0.01, 0.01, 0.02, 0.02, 0.02, 0.03, 0.2, 0.25);
        osc.patch(adsr);
        break;
    }

  }


  void noteOn(float dur) {
    adsr.noteOn();
    adsr.patch(out);
  }

  void noteOff() {
    adsr.unpatchAfterRelease(out);
    adsr.noteOff();
  }
}
