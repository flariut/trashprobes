'''

https://docs.python.org/3/library/argparse.html
https://docs.python.org/3/library/subprocess.html
https://eli.thegreenplace.net/2017/interacting-with-a-long-running-child-process-in-python/


processing-java --sketch=folder --run

'''
import argparse
import psutil
import subprocess
import time
import os
import threading
#import shlex

from trashprobes import *

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Trash Probes Main Module.')
    parser.add_argument("--i", "-interface", help="wlan interface.")
    args = parser.parse_args()

    print("#\n# trash probes initializing...\n#\n")

    time.sleep(1)

    print("# executing processing visualizations...\n")

    processing = []
    for dir in [a for a in os.listdir("../processing") \
                if os.path.isdir("../processing/" + a)]:
        processing_command = ["processing-java",
                              "--sketch=../processing/" + dir, "--run"]
        try:
            processing.append(subprocess.Popen(processing_command, shell=False))
        except:
            print("#! ERROR while initializing " + dir + " visualization\n")
            #raise
    time.sleep(5)

    print("# starting tshark analysis...\n")
    tshark_command = ["tshark", "-o", "nameres.mac_name:FALSE", "-l", "-I",
                      "-i", args.i, "-Y", "wlan.ssid != 0",
                      "wlan type mgt subtype 0100"]
    try:
        tshark = subprocess.Popen(tshark_command, shell=False,
                                  stdout=subprocess.PIPE)
    except:
        print("#! ERROR while initializing tshark process\n")
        #raise
    time.sleep(3)

    print("# loading databases")
    u = User.from_csv()
    r = Router.from_csv()
    m = []

    print("# entering main loop... \n")

    tshark_file = open("../databases/tshark_output", mode="a+")
    t = []
    while(True):
        try:
            line = tshark.stdout.readline()
            if line == '' and tshark.poll() is not None:
                break
            if line:
                #print(line.strip())
                _line = line.decode("utf-8")
                #print(_line)
                tshark_file.write(_line)
                tshark_file.flush()
                m.append(Message(_line))
                m[-1].to_csv()
                m[-1].to_csv('messages.csv')
                if m[-1].mac not in [_u.mac for _u in u]:
                    u.append(User(m[-1].mac, [Router(m[-1].ssid)]))
                else:
                    index = [_u.mac for _u in u].index(m[-1].mac)
                    if m[-1].ssid not in [_r.ssid for _r in u[index].routers]:
                        u[index].add_router(Router(m[-1].ssid))

                if m[-1].ssid not in [_r.ssid for _r in r]:
                    router = Router(m[-1].ssid)
                    print("# calling geolocal with: " + router.ssid)
                    t.append(threading.Thread(target=router.geolocal,
                             args=(True,)))
                    t[-1].start()
                    r.append(router)
                else:
                    index = [_r.ssid for _r in r].index(m[-1].ssid)
                    #if r[index].lat is not None  and len(r[index].lon):
                    r[index].to_csv()

                #message = trashprobes.Message(line)
                #print("entra datita")
            rc = tshark.poll()

        except KeyboardInterrupt:
            break
        except:
            raise

    print("\n# saving databases...\n")
    # Overwrite cabeza
    with open('../databases/users.csv', mode='w') as usr_file:
        pass
    with open('../databases/routers.csv', mode='w') as rtr_file:
        pass
    for _u in u:
        _u.to_csv('users.csv')
    for _r in r:
        _r.to_csv('routers.csv')

    print("\n# terminating!\n")

    tshark.terminate()
    tshark_file.close()

    '''
    for p in processing:
        p.terminate()
    time.sleep(3)
    for proc in psutil.process_iter():
        if proc.name() == "java":
            proc.kill()
    '''
