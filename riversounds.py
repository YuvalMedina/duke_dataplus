import argparse
import random
from pythonosc import osc_message_builder
from pythonosc import udp_client
import socket
import time

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as pltdates
import datetime as dt

from main_functions import readFile, getData, plotGraph

#parameters:
path = "gpp_list"        #change to user input at some point!

myfile = pd.read_csv("csv_files/" + path + ".csv", header=None)
myfile[0] = pd.to_numeric(myfile[0])

myMean = np.mean(myfile)
myStd = np.std(myfile)
myMin = myMean - 4*myStd
myMax = myMean + 4*myStd
myRange = myMax - myMin

myfile = ((myfile - myMin)/myRange ) * 200 + 200

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default='127.0.0.1',
                        help="The ip of the OSC server")
    parser.add_argument("--port", type=int, default=57120,
                        help="The port the OSC server is listening on")
    args = parser.parse_args()

    client = udp_client.SimpleUDPClient(args.ip, args.port)

    for x in range(myfile.size):
        client.send_message("/print", myfile.iloc[x,0])
        time.sleep(0.001)
