'''

https://stackoverflow.com/questions/4256107/running-bash-commands-in-python

https://docs.python.org/3.4/library/csv.html

https://pypi.org/project/pygle/

https://www.genbeta.com/desarrollo/multiprocesamiento-en-python-threads-a-fondo-introduccion

/usr/share/wireshark/manuf
    esos son los manufacturers del mac adress

'''

import csv
#import googlemaps

from manuf import MacParser # Solución optimizada para la resolución de manuf
from bisect import bisect
from pygle import network

macparser = MacParser("../databases/manuf")

ltest = "  270 75.888345137 a8:7c:01:79:06:df → 5a:90:43:61:9a:c9 802.11 121 \
        Probe Request, SN=3251, FN=0, Flags=....R...C, SSID=TeleCentro Wifi"

DEF_CSV = 'communication.csv'

class Message:
    def __init__(self, line):
        self.splitted = line.strip().split(",")
        self.header = self.splitted[0].split()
        self.time = float(self.header[1])
        self.mac = self.header[2]
        self.other_int = int(self.header[6])
        self.sn = int(self.splitted[1][4:])
        self.ssid = self.splitted[4][6:] # Ojo con lo de los malformed packet
        self.manuf = "???"
        # Buscamos el manufacturer
        search = macparser.search(self.mac)
        if search != []:
            self.manuf = search[0].manuf


    def to_csv(self, file = DEF_CSV):
        with open('../databases/' + file, mode='a+') as msg_file:
            msg_writer = csv.writer(msg_file, quoting=csv.QUOTE_MINIMAL)
            msg_writer.writerow(["msg", self.time, self.mac, self.other_int,
                                 self.sn, self.manuf, self.ssid])

class User:

    def __init__(self, mac, routers = None):
        self.mac = mac
        if routers is None:
            self.routers = []
        else:
            self.routers = routers

    def from_csv():
        users = []
        with open('../databases/users.csv') as usr_file:
            usr_reader = csv.reader(usr_file, delimiter=',')
            for row in usr_reader:
                routers = [Router(r) for r in row[2:]]
                users.append(User(row[1], routers))
            return users

    def to_csv(self, file = DEF_CSV):
        with open('../databases/' + file, mode='a+') as usr_file:
            usr_write = csv.writer(usr_file, quoting=csv.QUOTE_MINIMAL)
            usr_write.writerow(["usr", self.mac] +
                                [r.ssid for r in self.routers])

    def add_router(self, router):
        if router.ssid not in self.routers:
            self.routers.append(router)
            return True
        else:
            return False

class Router:

    def __init__(self, ssid, lat = None, lon = None, places = None):
        self.ssid = ssid
        self.lat = lat
        self.lon = lon
        if places is None:
            self.places = []
        else:
            self.places = places
        self.wigle = {}

    def geolocal(self, write = False):
        # Ciudad de Buenos Aires y Cordones del Conurbano Bonaerense
        # -34.411228, -58.860738
        # -34.832414, -58.138041
        self.wigle = network.search(latrange1=-34.411228, longrange1=-58.860738,
                                    latrange2=-34.832414, longrange2=-58.138041,
                                    ssid=self.ssid)
        if self.wigle:
            results = self.wigle['totalResults']
            if results and results < 3:
                self.lat = self.wigle['results'][0]['trilat']
                self.lon = self.wigle['results'][0]['trilong']
                for i in range(0, results):
                    road = self.wigle['results'][i]['road']
                    housenm = self.wigle['results'][i]['housenumber']
                    if road and housenm:
                        self.places.append(road + " " + housenm)
                if write is not False:
                    if write is True:
                        self.to_csv()
                    elif '.csv' in write:
                        self.to_csv(write)
                print("### geolocal",self.ssid,"SUCCESS with",results,"results")
                return True
            else:
                if write is not False:
                    if write is True:
                        self.to_csv()
                    elif '.csv' in write:
                        self.to_csv(write)
                print("### geolocal",self.ssid,"with",results, "results")
                return False
        print("### geolocal failed")
        return False

    def gm_places(self):
        if self.lat is not None and self.lon is not None:
            pass
            #do some shit
        else:
            return False

    def from_csv():
        routers = []
        with open('../databases/routers.csv') as rtr_file:
            rtr_reader = csv.reader(rtr_file, delimiter=',')
            for row in rtr_reader:
                routers.append(Router(row[1], row[2], row[3], row[4:]))
        return routers

    def to_csv(self, file = DEF_CSV):

        with open('../databases/' + file, mode='a+') as rtr_file:
            rtr_writer = csv.writer(rtr_file, quoting=csv.QUOTE_MINIMAL)
            rtr_writer.writerow(["rtr", self.ssid, self.lat, self.lon] +
                                [p for p in self.places])
def some_other_func():
    pass
