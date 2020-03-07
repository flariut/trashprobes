# tr4sh_pr0b3s
Generative visuals and sounds based on 802.11b Probe Request vulnerability.

## Description
This project was made for UNTREF's Electronic Arts Laboratory I final practice work, and right now it's configured to run in my very specific setup.
The program combines a `tshark` command for starting the process of Wi-Fi sniffing and data collection from Probe Request paquets, then a Python module analyses it and consults Wigle geolocalization database with `pygle` library to get it ready for the Processing sketches to generate spacey visuals and sounds (which requires a modified `minim` library with a `level_peak()` function I wrote to allow a brickwall limiting of the ouput, but currently, I lost that bit of code because of an issue with my SSD).
The processes communicate with each other via `.csv` files, and it's required to have two wireless cards, one with internet connection and another running in Monitor mode.

## Development

Currently, this is no longer in active development and unless I need it I'm not updating it to work it again, and if I do, probably I will be changing the sound engine for a more reliable and useful one.
